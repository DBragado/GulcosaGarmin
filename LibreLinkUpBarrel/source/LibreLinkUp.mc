import Toybox.Communications;
import Toybox.Application;

module LibreLinkUp {

    const API_HOST = "api-eu.libreview.io";

    function login(email as String, password as String, callback as Method) as Void {
        var url = "https://" + API_HOST + "/llu/auth/login";
        var params = {
            "email"    => email,
            "password" => password
        };
        var options = {
            :method       => Communications.HTTP_REQUEST_METHOD_POST,
            :headers      => {
                "Content-Type"    => "application/json",
                "product"         => "llu.ios",
                "version"         => "4.7.0",
                "Accept-Encoding" => "gzip"
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Communications.makeWebRequest(url, params, options, callback);
    }

    function fetchGlucose(token as String, patientId as String, callback as Method) as Void {
        var url = "https://" + API_HOST + "/llu/connections/" + patientId + "/graph";
        var options = {
            :method       => Communications.HTTP_REQUEST_METHOD_GET,
            :headers      => {
                "Authorization"   => "Bearer " + token,
                "product"         => "llu.ios",
                "version"         => "4.7.0",
                "Accept-Encoding" => "gzip"
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        Communications.makeWebRequest(url, null, options, callback);
    }
}
