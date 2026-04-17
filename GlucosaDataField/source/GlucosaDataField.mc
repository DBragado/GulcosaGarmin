import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Timer;
using LibreLinkUp;

class GlucosaDataFieldApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function getInitialView() { return [new GlucosaDataView()]; }
}

class GlucosaDataView extends WatchUi.DataField {

    private var _glucosa   as Number?  = null;
    private var _token     as String?  = null;
    private var _patientId as String?  = null;
    private var _timer     as Timer.Timer;

    function initialize() {
        DataField.initialize();
        _timer = new Timer.Timer();
    }

    function onLayout(dc as Dc) as Void {
        _timer.start(method(:onTick), 5000, false);
    }

    function onTick() as Void {
        _timer.start(method(:onTick), 60000, false);
        _token     = Application.Storage.getValue("df_token");
        _patientId = Application.Storage.getValue("df_patient_id");

        if (_token != null && _patientId != null) {
            LibreLinkUp.fetchGlucose(_token, _patientId, method(:onGlucoseReceived));
        } else {
            var email    = Application.Properties.getValue("llu_email");
            var password = Application.Properties.getValue("llu_password");
            LibreLinkUp.login(email, password, method(:onLoginReceived));
        }
    }

    function onLoginReceived(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            _token     = data["data"]["authTicket"]["token"];
            _patientId = data["data"]["user"]["id"];
            Application.Storage.setValue("df_token", _token);
            Application.Storage.setValue("df_patient_id", _patientId);
            LibreLinkUp.fetchGlucose(_token, _patientId, method(:onGlucoseReceived));
        }
        data = null;
    }

    function onGlucoseReceived(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            _glucosa = data["data"]["connection"]["glucoseMeasurement"]["Value"];
        }
        data = null;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx    = dc.getWidth() / 2;
        var cy    = dc.getHeight() / 2;
        var texto = (_glucosa != null) ? _glucosa.toString() : "--";

        if (_glucosa == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        } else if (_glucosa < 70) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else if (_glucosa > 180) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(cx, cy, Graphics.FONT_NUMBER_HOT, texto, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 36, Graphics.FONT_TINY, "mg/dL", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
