// =============================================================================
// GulcosaGarminApp.mc
// Punto de entrada principal de la aplicación GulcosaGarmin
// =============================================================================

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;

class GulcosaGarminApp extends Application.AppBase {

    // Timer para actualizaciones periódicas (cada 5 minutos)
    private var _updateTimer as Timer.Timer;

    // Referencia al view principal
    private var _mainView as GulcosaGarminView?;

    function initialize() {
        AppBase.initialize();
        _updateTimer = new Timer.Timer();
    }

    // Primer arranque de la app
    function onStart(state as Dictionary?) as Void {
        // Cargar credenciales guardadas
        DataStore.loadCredentials();

        // Lanzar primera petición inmediatamente
        LibreApi.fetchGlucose(method(:onGlucoseUpdate), method(:onApiError));

        // Actualizar cada 5 minutos (300.000 ms)
        _updateTimer.start(method(:onTimerTick), 300000, true);
    }

    function onStop(state as Dictionary?) as Void {
        _updateTimer.stop();
    }

    // Devuelve la vista inicial
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var view = new GulcosaGarminView();
        _mainView = view;
        return [view];
    }

    // Callback del timer → lanza nueva petición a la API
    function onTimerTick() as Void {
        LibreApi.fetchGlucose(method(:onGlucoseUpdate), method(:onApiError));
    }

    // Callback con datos de glucosa correctos
    function onGlucoseUpdate(data as Dictionary) as Void {
        var glucoseValue = data["value"] as Number;
        var timestamp    = data["timestamp"] as Number;

        // Guardar en DataStore
        DataStore.saveReading(glucoseValue, timestamp);

        // Comprobar alertas
        AlertManager.check(glucoseValue);

        // Actualizar pantalla
        if (_mainView != null) {
            (_mainView as GulcosaGarminView).updateDisplay(glucoseValue, timestamp, :ok);
        }
        WatchUi.requestUpdate();
    }

    // Callback de error de API
    function onApiError(errorCode as Number) as Void {
        var status = errorCode == 401 ? :authError : :connectionError;
        if (_mainView != null) {
            (_mainView as GulcosaGarminView).updateDisplay(null, null, status);
        }
        WatchUi.requestUpdate();
    }
}

// Punto de entrada global requerido por Connect IQ
function getApp() as GulcosaGarminApp {
    return Application.getApp() as GulcosaGarminApp;
}
