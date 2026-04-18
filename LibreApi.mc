// =============================================================================
// LibreApi.mc
// Cliente para la API no oficial de LibreLinkUp (Abbott FreeStyle Libre)
//
// FLUJO:
//   1. POST /llu/auth/login  → obtener token de sesión
//   2. GET  /llu/connections  → obtener lista de conexiones (pacientes)
//   3. GET  /llu/connections/{patientId}/graph → obtener lectura actual
// =============================================================================

import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;

module LibreApi {

    // URL base de la API (Europa)
    // Otras regiones: api-us.libreview.io, api-ap.libreview.io
    private const BASE_URL as String = "https://api-eu.libreview.io";
    private const API_VERSION as String = "4.7";
    private const PRODUCT     as String = "llu.ios";

    // Token de sesión en memoria (se pierde al reiniciar la app)
    private var _authToken as String?;

    // Callbacks en curso
    private var _successCallback as Method?;
    private var _errorCallback   as Method?;

    // ── Punto de entrada público ─────────────────────────────────────────────

    // Obtiene la glucosa actual. Llama a successCb({value, timestamp}) o errorCb(code)
    function fetchGlucose(successCb as Method, errorCb as Method) as Void {
        _successCallback = successCb;
        _errorCallback   = errorCb;

        var email    = DataStore.getEmail();
        var password = DataStore.getPassword();

        if (email == null || email.equals("") || password == null || password.equals("")) {
            // Sin credenciales → error de auth
            if (_errorCallback != null) {
                (_errorCallback as Method).invoke(401);
            }
            return;
        }

        if (_authToken != null) {
            // Ya tenemos token → ir directo a las conexiones
            _getConnections();
        } else {
            // Necesitamos autenticarnos primero
            _login(email, password);
        }
    }

    // ── Paso 1: Login ────────────────────────────────────────────────────────

    private function _login(email as String, password as String) as Void {
        var url  = BASE_URL + "/llu/auth/login";
        var body = {
            "email"    => email,
            "password" => password
        };

        var options = {
            :method      => Communications.HTTP_REQUEST_METHOD_POST,
            :headers     => _buildHeaders(null),
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        Communications.makeWebRequest(url, body, options, method(:onLoginResponse));
    }

    function onLoginResponse(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            var authData = data["data"];
            if (authData != null) {
                var authTicket = authData["authTicket"];
                if (authTicket != null) {
                    _authToken = authTicket["token"] as String;
                    _getConnections();
                    return;
                }
            }
        }
        // Error de autenticación
        _authToken = null;
        _invokeError(responseCode == 200 ? 401 : responseCode);
    }

    // ── Paso 2: Obtener conexiones ───────────────────────────────────────────

    private function _getConnections() as Void {
        var url = BASE_URL + "/llu/connections";
        var options = {
            :method       => Communications.HTTP_REQUEST_METHOD_GET,
            :headers      => _buildHeaders(_authToken),
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Communications.makeWebRequest(url, null, options, method(:onConnectionsResponse));
    }

    function onConnectionsResponse(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 401) {
            // Token expirado → renovar
            _authToken = null;
            var email    = DataStore.getEmail();
            var password = DataStore.getPassword();
            if (email != null && password != null) {
                _login(email, password);
            } else {
                _invokeError(401);
            }
            return;
        }

        if (responseCode == 200 && data != null) {
            var connections = data["data"] as Array?;
            if (connections != null && connections.size() > 0) {
                var firstConnection = connections[0] as Dictionary;
                var patientId = firstConnection["patientId"] as String?;
                if (patientId != null) {
                    _getGlucoseGraph(patientId);
                    return;
                }
            }
        }
        _invokeError(responseCode);
    }

    // ── Paso 3: Obtener lectura de glucosa ───────────────────────────────────

    private function _getGlucoseGraph(patientId as String) as Void {
        var url = BASE_URL + "/llu/connections/" + patientId + "/graph";
        var options = {
            :method       => Communications.HTTP_REQUEST_METHOD_GET,
            :headers      => _buildHeaders(_authToken),
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Communications.makeWebRequest(url, null, options, method(:onGraphResponse));
    }

    function onGraphResponse(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            var graphData = data["data"] as Dictionary?;
            if (graphData != null) {
                var connection = graphData["connection"] as Dictionary?;
                if (connection != null) {
                    var glucoseMeasurement = connection["glucoseMeasurement"] as Dictionary?;
                    if (glucoseMeasurement != null) {
                        var value     = glucoseMeasurement["Value"]     as Number?;
                        var timestamp = glucoseMeasurement["Timestamp"] as Number?;
                        if (value != null) {
                            var result = {
                                "value"     => value,
                                "timestamp" => timestamp != null ? timestamp : Time.now().value()
                            };
                            _invokeSuccess(result);
                            return;
                        }
                    }
                }
            }
        }
        _invokeError(responseCode);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private function _buildHeaders(token as String?) as Dictionary {
        var headers = {
            "Content-Type"      => "application/json",
            "version"           => API_VERSION,
            "product"           => PRODUCT,
            "Accept-Encoding"   => "gzip",
            "cache-control"     => "no-cache"
        };
        if (token != null) {
            headers["Authorization"] = "Bearer " + token;
        }
        return headers;
    }

    private function _invokeSuccess(data as Dictionary) as Void {
        if (_successCallback != null) {
            (_successCallback as Method).invoke(data);
        }
    }

    private function _invokeError(code as Number) as Void {
        if (_errorCallback != null) {
            (_errorCallback as Method).invoke(code);
        }
    }
}
