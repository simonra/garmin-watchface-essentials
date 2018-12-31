using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;

class DateUtilsIso {
    // Returns the ISO week for a given point in time.
    function calculateWeekNumber(timestamp_gregorian_short){
        var todaysDayNumber = getOrdinalDate(timestamp_gregorian_short);

        var dayOfWeek = timestamp_gregorian_short.day_of_week - 1;
        if(dayOfWeek == 0){
            dayOfWeek = 7;
        }

        var calculatedWeekNumber = Math.floor((todaysDayNumber - dayOfWeek + 10) / 7);

        // Handle end/beginning of year special cases:
        if(calculatedWeekNumber < 1){
            // We are in the last week of the previous year
            calculatedWeekNumber = numberOfWeeksInYear(timestamp_gregorian_short.year -1);
        }
        else if(calculatedWeekNumber == 53){
            // We might be in the first week of the next year, have to check:
            if (numberOfWeeksInYear(timestamp_gregorian_short.year) != 53) {
                calculatedWeekNumber = 1;
            }
        }
        return calculatedWeekNumber;
    }

    // Obtain the position of a given day in a year. For instance the 1st of January
    // would be be first day of the year (1), and the second of february would be day 33.
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
    hidden function p(year) {
        return (year + Math.floor(year/4) - Math.floor(year/100) + Math.floor(year/400)) % 7;
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
