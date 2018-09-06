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
        weekNumber = Storage.getValue("weekNumber");
        weekNumberUpdatedOnDay = Storage.getValue("weekNumberUpdatedOnDay");
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        Storage.setValue("weekNumber", weekNumber);
        Storage.setValue("weekNumberUpdatedOnDay", weekNumberUpdatedOnDay);
    }

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
        var weekAbbreviated = WatchUi.loadResource(Rez.Strings.week);
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
                return WatchUi.loadResource(Rez.Strings.monday);
                break;
            case 3:
                return WatchUi.loadResource(Rez.Strings.tuesday);
                break;
            case 4:
                return WatchUi.loadResource(Rez.Strings.wednesday);
                break;
            case 5:
                return WatchUi.loadResource(Rez.Strings.thursday);
                break;
            case 6:
                return WatchUi.loadResource(Rez.Strings.friday);
                break;
            case 7:
                return WatchUi.loadResource(Rez.Strings.saturday);
                break;
            case 1:
                return WatchUi.loadResource(Rez.Strings.sunday);
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
        if(weekNumberUpdatedOnDay != dateAsText){
            weekNumberUpdatedOnDay = dateAsText;
            weekNumber = calculateIsoWeek(timestamp_gregorian_short);
        }
        return weekNumber;
    }

    // Returns the ISO week for a given point in time.
    function calculateIsoWeek(timestamp_gregorian_short){
        var todaysDayNumber = getOrdinalDate(timestamp_gregorian_short);

        var dayOfWeek = timestamp_gregorian_short.day_of_week - 1;
        if(dayOfWeek == 0){
            dayOfWeek = 7;
        }
        var calculatedWeekNumber = (todaysDayNumber - dayOfWeek + 10) / 7;

        // Handle end/beginning of year special cases:
        if(calculatedWeekNumber < 1){
            // We are in the last week of the previous year
            calculatedWeekNumber = numberOfWeeksInYear(timestamp_gregorian_short.year -1);
        }
        else if(calculatedWeekNumber == 53){
            // We might be in the first week of the next year, have to check:
            if (numberOfWeeksInYear(timestamp_gregorian_short.year != 53)) {
                calculatedWeekNumber = 1;
            }
        }
        return calculatedWeekNumber;
    }

    function getOrdinalDate (timestamp_gregorian_short) {
        var calculatedOrdinalValue = timestamp_gregorian_short.day;
        switch (timestamp_gregorian_short.month) {
            case 1:
                // No need to add anything if we're in january
                break;
            case 2:
                // February
                calculatedOrdinalValue += 31;
                break;
            case 3:
                // March
                calculatedOrdinalValue += 59;
                break;
            case 4:
                // April
                calculatedOrdinalValue += 90;
                break;
            case 5:
                // May
                calculatedOrdinalValue += 120;
                break;
            case 6:
                // June
                calculatedOrdinalValue += 151;
                break;
            case 7:
                // July
                calculatedOrdinalValue += 181;
                break;
            case 8:
                // August
                calculatedOrdinalValue += 212;
                break;
            case 9:
                // September
                calculatedOrdinalValue += 243;
                break;
            case 10:
                // October
                calculatedOrdinalValue += 273;
                break;
            case 11:
                // November
                calculatedOrdinalValue += 304;
                break;
            case 12:
                // December
                calculatedOrdinalValue += 334;
            default:
                break;
        }
        if(isLeapYear(timestamp_gregorian_short.year) && timestamp_gregorian_short.month > 2){
            calculatedOrdinalValue += 1;
        }
        return calculatedOrdinalValue;
    }

    function numberOfWeeksInYear (year) {
        var given = p(year);
        var preceding = p(year - 1);
        if(given == 4 || preceding == 3){
            return 53;
        }
        return 52;
    }
    function p(year) {
        // Note: This relies on monkey c's integer division discarding any remainder.
        // All the divisions have to be floored.
        return (year + year/4 - year/100 + year/400) % 7;
    }

    function isLeapYear (year) {
        if(year % 4 != 0){
            return false;
        }
        if(year % 100 != 0){
            return true;
        }
        if(year % 400 != 0){
            return false;
        }
        return true;
    }
}
