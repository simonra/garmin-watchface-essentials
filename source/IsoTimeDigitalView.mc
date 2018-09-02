using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

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
    	var now = Time.now();
    	var numericTime = Gregorian.info(now, Time.FORMAT_SHORT);
    	var descriptiveTime = Gregorian.info(now, Time.FORMAT_LONG);
        // Get and show the current time
//        var clockTime = System.getClockTime();
        var timeString = Lang.format(
        	"$1$:$2$",
        	[
        		numericTime.hour,
        		numericTime.min.format("%02d")
        	]
        );
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
        var spacing = "        ";
        var weekNumber = "W52";
        var batteryPercentage = "100%";
        var weekAndBatteryView = View.findDrawableById("WeekAndBateryLabel");
        weekAndBatteryView.setText(weekNumber + spacing + batteryPercentage);
        
        //DayLabel
        var dayView = View.findDrawableById("DayLabel");
        dayView.setText(getDayOfWeekLong(numericTime));
//        dayView.setText("Monday");
        
        //DateLabel
        var dateView = View.findDrawableById("DateLabel");
        var dateText = Lang.format(
        	"$1$-$2$-$3$",
        	[
        		numericTime.year,
        		numericTime.month.format("%02d"),
        		numericTime.day.format("%02d")
    		]
    	);
    	dateView.setText(dateText);

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
    
    const days = [
    	"Sunday", // So wrong to say that a week starts in the middle of the week-end, but for moronic design decision reasons it's like this now
    	"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday"
	];
    function getDayOfWeekLong(georgianTime){
//    	System.println(georgianTime.day_of_week);
		// Did you know we 1-index everything, but arrays are still 0-indexed?
    	return days[georgianTime.day_of_week - 1];
    }

}
