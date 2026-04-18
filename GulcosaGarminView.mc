// =============================================================================
// GulcosaGarminView.mc
// Vista principal: dibuja la glucosa en la pantalla del reloj
// =============================================================================

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class GulcosaGarminView extends WatchUi.View {

    // Estado interno
    private var _glucoseValue as Number?;
    private var _timestamp    as Number?;
    private var _status       as Symbol;  // :loading | :ok | :connectionError | :authError

    // Umbrales (mg/dL)
    private const LOW_THRESHOLD  as Number = 70;
    private const HIGH_THRESHOLD as Number = 180;

    function initialize() {
        View.initialize();
        _status = :loading;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Llamado desde App cuando llegan datos nuevos
    function updateDisplay(value as Number?, timestamp as Number?, status as Symbol) as Void {
        _glucoseValue = value;
        _timestamp    = timestamp;
        _status       = status;
    }

    function onUpdate(dc as Dc) as Void {
        // Fondo negro siempre
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        if (_status == :loading) {
            _drawLoading(dc, cx, cy);
        } else if (_status == :connectionError) {
            _drawError(dc, cx, cy, "Sin conexión");
        } else if (_status == :authError) {
            _drawError(dc, cx, cy, "Error de acceso");
        } else {
            _drawGlucose(dc, cx, cy);
        }
    }

    // ── Dibuja el valor de glucosa ───────────────────────────────────────────
    private function _drawGlucose(dc as Dc, cx as Number, cy as Number) as Void {
        if (_glucoseValue == null) { return; }
        var value = _glucoseValue as Number;

        // Color según rango
        var glucoseColor;
        if (value < LOW_THRESHOLD) {
            glucoseColor = Graphics.COLOR_RED;          // Hipo → rojo
        } else if (value > HIGH_THRESHOLD) {
            glucoseColor = Graphics.COLOR_ORANGE;       // Hiper → naranja
        } else {
            glucoseColor = Graphics.COLOR_GREEN;        // Normal → verde
        }

        // Círculo de fondo con el color del estado
        dc.setColor(glucoseColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 60);

        // Número de glucosa
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 30, Graphics.FONT_NUMBER_HOT,
                    value.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // Unidades
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 30, Graphics.FONT_SMALL,
                    "mg/dL", Graphics.TEXT_JUSTIFY_CENTER);

        // Tiempo desde la última lectura
        _drawTimestamp(dc, cx, dc.getHeight() - 20);

        // Etiqueta de alerta si aplica
        if (value < LOW_THRESHOLD) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, 15, Graphics.FONT_SMALL,
                        "▼ BAJA", Graphics.TEXT_JUSTIFY_CENTER);
        } else if (value > HIGH_THRESHOLD) {
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, 15, Graphics.FONT_SMALL,
                        "▲ ALTA", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // ── Dibuja el tiempo desde la última lectura ─────────────────────────────
    private function _drawTimestamp(dc as Dc, cx as Number, y as Number) as Void {
        if (_timestamp == null) { return; }

        var now     = Time.now().value();
        var elapsed = ((now - _timestamp) / 60).toNumber(); // en minutos
        var text    = "hace " + elapsed.toString() + " min";

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, y, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Estado de carga ──────────────────────────────────────────────────────
    private function _drawLoading(dc as Dc, cx as Number, cy as Number) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_MEDIUM,
                    "Cargando...", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Estado de error ──────────────────────────────────────────────────────
    private function _drawError(dc as Dc, cx as Number, cy as Number, msg as String) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 20, Graphics.FONT_SMALL,
                    "⚠", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 10, Graphics.FONT_XTINY,
                    msg, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
