import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Application;
import Toybox.Background;
import Toybox.System;
import Toybox.Time;

class GlucosaWatchFaceApp extends Application.AppBase {

    function initialize() { AppBase.initialize(); }

    function onStart(state as Dictionary?) as Void {
        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new GlucosaView()];
    }
}

class GlucosaView extends WatchUi.WatchFace {

    function initialize() { WatchFace.initialize(); }
    function onLayout(dc as Dc) as Void {}

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        var clockTime = System.getClockTime();
        var hora = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 40, Graphics.FONT_NUMBER_THAI_HOT, hora, Graphics.TEXT_JUSTIFY_CENTER);

        var glucosa = Application.Storage.getValue("glucosa_mgdl");
        var texto   = (glucosa != null) ? glucosa.toString() + " mg/dL" : "-- mg/dL";

        if (glucosa == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        } else if (glucosa < 70) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else if (glucosa > 180) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(cx, cy + 20, Graphics.FONT_LARGE, texto, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
