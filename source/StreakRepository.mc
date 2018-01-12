using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage;
using Toybox.ActivityMonitor;


class StreakRepository {
    var percentCompleteToday = 0;
    var activeMinutesLimit = 15.0;

    var currentStreak;
    var longestStreak;

    function load(){
        var streak = streakFromHistory();

        var storedStreak = Streak.empty();
        //var storedStreak = Streak.load("current");

        streak.add(storedStreak);
        streak.save("current");

        var todayStreak = streakFromToday();
        if(streak.isActive){
            streak.add(todayStreak);
         }
         else {
            streak = todayStreak;
         }

        currentStreak = streak;

        longestStreak = Streak.load("longest");
        if(streak.length() > longestStreak.length()) {
            longestStreak = streak;
            longestStreak.save("longest");
        }

    }


    function streakFromToday() {
        var s = Streak.empty();
        var currentDay = ActivityMonitor.getInfo();
        var isActiveToday = currentDay.activeMinutesDay.total >= activeMinutesLimit;
        if(isActiveToday) {
            s.setActiveOn(Time.today());
            percentCompleteToday = 1;
        }
        else {
            percentCompleteToday = currentDay.activeMinutesDay.total / activeMinutesLimit;
        }
        return s;
    }

    function streakFromHistory(){
        var streak = Streak.empty();
        var hist = ActivityMonitor.getHistory();
        for (var i = hist.size()-1; i >= 0; i--) {
            var element = hist[i];
            var day = element.startOfDay;
            if (element.activeMinutes.total > activeMinutesLimit) {
                streak.setActiveOn(day);
            }
            else {
                streak.reset(day);
            }
        }
        return streak;
    }


}