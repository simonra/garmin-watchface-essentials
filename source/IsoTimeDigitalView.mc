using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;

class IsoTimeDigitalView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setText(timeString);
        
        /*
        //WeekNumberLabel
        var weekNumberView = View.findDrawableById("WeekNumberLabel");
        weekNumberView.setText("W-01");
        
        // BateryLabel
        var batteryView = View.findDrawableById("WeekNumberLabel");
        batteryView.setText("100%");
        */
        
        //WeekAndBateryLabel
        var spacing = "       ";
        var weekNumber = "W01";
        var batteryPercentage = "100%";
        var weekAndBatteryView = View.findDrawableById("WeekAndBateryLabel");
        weekAndBatteryView.setText(weekNumber + spacing + batteryPercentage);
        
        //DayLabel
        var dayView = View.findDrawableById("DayLabel");
        dayView.setText("Monday");
        
        //DateLabel
        var dateView = View.findDrawableById("DateLabel");
        dateView.setText("2018-08-31");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
