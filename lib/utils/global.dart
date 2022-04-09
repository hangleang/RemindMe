
import 'dart:convert';
// import 'dart:js';
import 'package:codenova_reminders/constants/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

setStorage(storageName, data) async{
  print("setStorage");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(APP_PREFIX + storageName, json.encode(data));
}

loadSorage(storageName) async{
    print("loadSorage");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(APP_PREFIX + storageName);
    return data;
}

bool checkIsNullValue(dynamic value) {
  return [null, "null", 0, "0", "", []].contains(value);
}

  void recentMonday()
  {
    var monday = 1;
    var now = new DateTime.now();
    while(now.weekday != monday)
    {
        now = now.subtract(new Duration(days: 1));
    }
    print('====recent Monday: $now =====');
  }

  void convertDateToWeekday(){
    var now = new DateTime.now();
    var day = DateFormat('EEEE').format(now);
    print('===today is: $day ====');
  }

  int convertDateToWeekdayIndex(DateTime dateTime){
    var index = (dateTime.weekday == DateTime.sunday ? 0 : dateTime.weekday);
    // var index = dateTime.weekday % 7;
    // print('===today index: $index ====');
    return index;
  }

List <String> longWeekdays = [
  tr('longSun'),
  tr('longMon'),
  tr('longTues'),
  tr('longWed'),
  tr('longThurs'),
  tr('longFri'),
  tr('longSat'),
];