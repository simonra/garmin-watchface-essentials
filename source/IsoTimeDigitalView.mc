using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage;

class IsoTimeDigitalView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
        not24Hour = !System.getDeviceSettings().is24Hour;
        // Load strings
        weekAbbreviated = WatchUi.loadResource(Rez.Strings.week);
        monday = WatchUi.loadResource(Rez.Strings.monday);
        tuesday = WatchUi.loadResource(Rez.Strings.tuesday);
        wednesday = WatchUi.loadResource(Rez.Strings.wednesday);
        thursday = WatchUi.loadResource(Rez.Strings.thursday);
        friday = WatchUi.loadResource(Rez.Strings.friday);
        saturday = WatchUi.loadResource(Rez.Strings.saturday);
        sunday = WatchUi.loadResource(Rez.Strings.sunday);
//        Storage.setValue("weekNumber", weekNumber);
//        Storage.setValue("weekNumberUpdatedOnDay", weekNumberUpdatedOnDay);
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        not24Hour = !System.getDeviceSettings().is24Hour;
        // Load strings
        weekNumber = Storage.getValue("weekNumber");
        weekNumberUpdatedOnDay = Storage.getValue("weekNumberUpdatedOnDay");
        weekAbbreviated = WatchUi.loadResource(Rez.Strings.week);
        monday = WatchUi.loadResource(Rez.Strings.monday);
        tuesday = WatchUi.loadResource(Rez.Strings.tuesday);
        wednesday = WatchUi.loadResource(Rez.Strings.wednesday);
        thursday = WatchUi.loadResource(Rez.Strings.thursday);
        friday = WatchUi.loadResource(Rez.Strings.friday);
        saturday = WatchUi.loadResource(Rez.Strings.saturday);
        sunday = WatchUi.loadResource(Rez.Strings.sunday);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        Storage.setValue("weekNumber", weekNumber);
        Storage.setValue("weekNumberUpdatedOnDay", weekNumberUpdatedOnDay);
    }

    // String settings
    // Load them to variables in memory rather than scrape them of the disk all the time.
    var weekAbbreviated = "Wk";
    var monday = "Monday";
    var tuesday = "Tuesday";
    var wednesday = "Wednesday";
    var thursday = "Thursday";
    var friday = "Friday";
    var saturday = "Saturday";
    var sunday = "Sunday";
    // Other settings
    var not24Hour = false;

    // Update the view
    function onUpdate(dc) {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        // TimeLabel
        var hour = now.hour;
        if(not24Hour){
            hour = now.hour % 12;
            if(hour == 0){
                hour = 12;
            }
        }
        else {
            hour = hour.format("%02d");
        }
        var timeString = Lang.format(
            "$1$:$2$",
            [
                hour,
                now.min.format("%02d")
            ]
        );
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setText(timeString);

        //DateLabel
        var dateView = View.findDrawableById("DateLabel");
        var dateText = Lang.format(
            "$1$-$2$-$3$",
            [
                now.year,
                now.month.format("%02d"),
                now.day.format("%02d")
            ]
        );
        dateView.setText(dateText);

        //WeekLabel
        var calculatedWeekNumber = getIsoWeek(now, dateText);
        var weekNumberText = weekAbbreviated + calculatedWeekNumber.format("%02d");
        var weekView = View.findDrawableById("WeekLabel");
        weekView.setText(weekNumberText);

        // BatteryLabel
        var repportedBatteryLevel = System
            .getSystemStats()
            .battery
            .format("%02d") ;
        var batteryPercentage = repportedBatteryLevel + "%";

        var batteryView = View.findDrawableById("BatteryLabel");
        batteryView.setText(batteryPercentage);
//        batteryView.setText("100%");

        //DayLabel
        var dayView = View.findDrawableById("DayLabel");
        dayView.setText(getDayOfWeekLong(now));

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

    function getDayOfWeekLong(gregorianTime){
        switch (gregorianTime.day_of_week) {
            case 2:
                return monday;
                break;
            case 3:
                return tuesday;
                break;
            case 4:
                return wednesday;
                break;
            case 5:
                return thursday;
                break;
            case 6:
                return friday;
                break;
            case 7:
                return saturday;
                break;
            case 1:
                return sunday;
                break;
            default:
                return "NoDayFound";
                break;
        }
    }

    var weekNumber = 1;
    var weekNumberUpdatedOnDay = "";
    function getIsoWeek (timestamp_gregorian_short, dateAsText) {
        // Only check for week number changes once per day
        if(!dateAsText.equals(weekNumberUpdatedOnDay)){
            var dateUtil = new DateUtilsIso();
            weekNumber = dateUtil.calculateWeekNumber(timestamp_gregorian_short);
            dateUtil = null;

            weekNumberUpdatedOnDay = dateAsText;
        }
        return weekNumber;
    }
}
