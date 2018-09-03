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

        var timeString = Lang.format(
            "$1$:$2$",
            [
                numericTime.hour,
                numericTime.min.format("%02d")
            ]
        );
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setText(timeString);

        //WeekAndBateryLabel
        var calculatedWeekNumber = getIsoWeek(numericTime);
        var weekNumberText = "W" + calculatedWeekNumber.format("%02d");

        var repportedBatteryLevel = System
            .getSystemStats()
            .battery
            .format("%02d") ;
        var batteryPercentage = repportedBatteryLevel + "%";

        var spacing = "        ";
        var weekAndBatteryView = View.findDrawableById("WeekAndBateryLabel");
        weekAndBatteryView.setText(weekNumberText + spacing + batteryPercentage);

        //DayLabel
        var dayView = View.findDrawableById("DayLabel");
        dayView.setText(getDayOfWeekLong(numericTime));

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
    function getDayOfWeekLong(gregorianTime){
        // Did you know we 1-index everything, but arrays are still 0-indexed?
        return days[gregorianTime.day_of_week - 1];
    }

    var weekNumber = 1;
    var weekNumberUpdatedOnDay = -1;
    // Returns the ISO week for a given point in time.
    function getIsoWeek(timestamp_gregorian_short){
        if(weekNumberUpdatedOnDay != timestamp_gregorian_short.day_of_week){ // Only check for week number changes once per day
            if(weekNumberUpdatedOnDay != -1 && timestamp_gregorian_short.day_of_week != 2){
                // No need to updae if we have obtained a value and today is not a monday (week number only changes on mondays)
                return weekNumber;
            }
            weekNumberUpdatedOnDay = timestamp_gregorian_short.day_of_week;

            // System.println(Time.now().value()); // Time now in unix time

            var todaysDayNumber = getOrdinalDate(timestamp_gregorian_short);
            // System.println(todaysDayNumber);
            var dayOfWeek = timestamp_gregorian_short.day_of_week - 1;
            if(dayOfWeek == 0){
                dayOfWeek = 7;
            }
            // System.println(dayOfWeek);
            weekNumber = (todaysDayNumber - dayOfWeek + 10) / 7;
            // System.println(weekNumber);

            // Handle end/beginning of year special cases:
            if(weekNumber < 1){
                // We are in the last week of the previous year
                weekNumber = numberOfWeeksInYear(timestamp_gregorian_short.year -1);
            }
            else if(weekNumber == 53){
                // We might be in the first week of the next year, have to check:
                if (numberOfWeeksInYear(timestamp_gregorian_short.year != 53)) {
                    weekNumber = 1;
                }
            }
        }
        return weekNumber;
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
