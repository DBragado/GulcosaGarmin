// =============================================================================
// DataStore.mc
// Persistencia local usando Application.Storage de Connect IQ
// Guarda: credenciales, última lectura de glucosa
// =============================================================================

import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

module DataStore {

    // Claves de almacenamiento
    private const KEY_EMAIL     as String = "libre_email";
    private const KEY_PASSWORD  as String = "libre_password";
    private const KEY_LAST_VAL  as String = "last_glucose_value";
    private const KEY_LAST_TS   as String = "last_glucose_timestamp";

    // Cache en memoria (para esta sesión)
    private var _email    as String?;
    private var _password as String?;

    // ── Credenciales ─────────────────────────────────────────────────────────

    // Carga las credenciales desde el almacenamiento persistente
    function loadCredentials() as Void {
        _email    = Application.Storage.getValue(KEY_EMAIL)    as String?;
        _password = Application.Storage.getValue(KEY_PASSWORD) as String?;
    }

    function getEmail() as String? {
        return _email;
    }

    function getPassword() as String? {
        return _password;
    }

    // Guarda las credenciales de forma persistente
    function saveCredentials(email as String, password as String) as Void {
        _email    = email;
        _password = password;
        Application.Storage.setValue(KEY_EMAIL,    email);
        Application.Storage.setValue(KEY_PASSWORD, password);
    }

    function clearCredentials() as Void {
        _email    = null;
        _password = null;
        Application.Storage.deleteValue(KEY_EMAIL);
        Application.Storage.deleteValue(KEY_PASSWORD);
    }

    // ── Lecturas de glucosa ──────────────────────────────────────────────────

    // Guarda la última lectura en persistencia
    function saveReading(value as Number, timestamp as Number) as Void {
        Application.Storage.setValue(KEY_LAST_VAL, value);
        Application.Storage.setValue(KEY_LAST_TS,  timestamp);
    }

    // Recupera la última lectura (útil al reiniciar la app)
    function getLastReading() as Dictionary? {
        var value     = Application.Storage.getValue(KEY_LAST_VAL) as Number?;
        var timestamp = Application.Storage.getValue(KEY_LAST_TS)  as Number?;
        if (value != null) {
            return { "value" => value, "timestamp" => timestamp };
        }
        return null;
    }
}
