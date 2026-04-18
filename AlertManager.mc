// =============================================================================
// AlertManager.mc
// Gestiona las alertas de hipoglucemia e hiperglucemia con vibración y texto
// =============================================================================

import Toybox.Attention;
import Toybox.Lang;
import Toybox.WatchUi;

module AlertManager {

    // Umbrales
    private const LOW_THRESHOLD  as Number = 70;   // mg/dL
    private const HIGH_THRESHOLD as Number = 180;  // mg/dL

    // Evitar alertas repetidas en el mismo rango
    private var _lastAlertType as Symbol = :none;  // :none | :low | :high | :normal

    // ── Punto de entrada: evaluar el valor actual ────────────────────────────
    function check(value as Number) as Void {
        if (value < LOW_THRESHOLD) {
            if (_lastAlertType != :low) {
                _lastAlertType = :low;
                _triggerLowAlert(value);
            }
        } else if (value > HIGH_THRESHOLD) {
            if (_lastAlertType != :high) {
                _lastAlertType = :high;
                _triggerHighAlert(value);
            }
        } else {
            // Glucosa en rango normal → resetear estado
            _lastAlertType = :normal;
        }
    }

    // ── Alerta de hipoglucemia ───────────────────────────────────────────────
    private function _triggerLowAlert(value as Number) as Void {
        // Vibración: 3 pulsos cortos y urgentes
        if (Attention has :vibrate) {
            var pattern = [
                new Attention.VibeProfile(100, 200),  // Intensidad 100%, 200ms
                new Attention.VibeProfile(0,   100),  // Pausa 100ms
                new Attention.VibeProfile(100, 200),
                new Attention.VibeProfile(0,   100),
                new Attention.VibeProfile(100, 400)   // Pulso largo al final
            ];
            Attention.vibrate(pattern);
        }

        // Notificación en pantalla
        _showAlert("⚠ GLUCOSA BAJA", value.toString() + " mg/dL", :low);
    }

    // ── Alerta de hiperglucemia ──────────────────────────────────────────────
    private function _triggerHighAlert(value as Number) as Void {
        // Vibración: 2 pulsos largos
        if (Attention has :vibrate) {
            var pattern = [
                new Attention.VibeProfile(80, 400),  // Intensidad 80%, 400ms
                new Attention.VibeProfile(0,  200),
                new Attention.VibeProfile(80, 400)
            ];
            Attention.vibrate(pattern);
        }

        _showAlert("↑ GLUCOSA ALTA", value.toString() + " mg/dL", :high);
    }

    // ── Mostrar popup de alerta en el reloj ──────────────────────────────────
    private function _showAlert(title as String, body as String, type as Symbol) as Void {
        // En Connect IQ usamos WatchUi.showAlert si está disponible (SDK >= 3.4)
        // En versiones anteriores simplemente se dibuja en el onUpdate del View
        if (WatchUi has :showAlert) {
            WatchUi.showAlert(new WatchUi.Alert({
                :timeout => 3000,         // 3 segundos
                :font    => Graphics.FONT_MEDIUM,
                :text    => title + "\n" + body,
                :fgcolor => type == :low ? Graphics.COLOR_RED : Graphics.COLOR_ORANGE,
                :bgcolor => Graphics.COLOR_BLACK
            }));
        }
    }
}
