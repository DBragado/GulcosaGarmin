import Toybox.Background;
import Toybox.Application;
using LibreLinkUp;

function getServiceDelegate() as BackgroundServiceDelegate {
    return new GlucosaBackgroundService();
}

class GlucosaBackgroundService extends BackgroundServiceDelegate {

    function initialize() {
        BackgroundServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var token     = Application.Storage.getValue("llu_token");
        var patientId = Application.Storage.getValue("llu_patient_id");

        if (token != null && patientId != null) {
            LibreLinkUp.fetchGlucose(token, patientId, method(:onGlucoseReceived));
        } else {
            var email    = Application.Properties.getValue("llu_email");
            var password = Application.Properties.getValue("llu_password");
            LibreLinkUp.login(email, password, method(:onLoginReceived));
        }
    }

    function onLoginReceived(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            var token     = data["data"]["authTicket"]["token"];
            var patientId = data["data"]["user"]["id"];
            Application.Storage.setValue("llu_token", token);
            Application.Storage.setValue("llu_patient_id", patientId);
            LibreLinkUp.fetchGlucose(token, patientId, method(:onGlucoseReceived));
        }
        data = null;
    }

    function onGlucoseReceived(responseCode as Number, data as Dictionary?) as Void {
        if (responseCode == 200 && data != null) {
            var glucosa = data["data"]["connection"]["glucoseMeasurement"]["Value"];
            Application.Storage.setValue("glucosa_mgdl", glucosa);
        }
        data = null;
        Background.exit(null);
    }
}
