import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task {
  int id;
  String title;
  String color;
  String emoji;
  String startedDateTime; // for occasion only
  // DateTime enedDate; // for occasion only
  String startedTime;
  // TimeOfDay enedTime;
  List repeatDays; // for habit only
  String repeatEvery; // for habit
  int minAlertBeforeTask; // 0min -> 30mins
  int type; // 1: habit, 2: occasion

  Task({
    @required this.id,
    @required this.title,
    @required this.color,
    @required this.emoji,
    this.startedDateTime,
    // this.enedDate,
    this.startedTime,
    // @required this.enedTime,
    this.repeatDays,
    this.repeatEvery,
    this.minAlertBeforeTask = 15,
    @required this.type
  });

  factory Task.fromJson(Map<String, dynamic> jsonData) {
    return Task(
      id: jsonData['id'],
      title: jsonData['title'],
      color: jsonData['color'],
      emoji: jsonData['emoji'],
      startedDateTime: jsonData['startedDateTime'],
      // enedDate: jsonData['enedDate'],
      startedTime: jsonData['startedTime'],
      // enedTime: jsonData['enedTime'],
      repeatDays: jsonData['repeatDays'],
      repeatEvery: jsonData['repeatEvery'],
      // minAlertBeforeTask: jsonData['minAlertBeforeTask'],
      type: jsonData['type']
    );
  }

  static Map<String, dynamic> toJson(Task task) => {
    'id': task.id,
    'title': task.title,
    'color': task.color,
    'emoji': task.emoji,
    'startedDateTime': task.startedDateTime,
    // 'enedDate': task.enedDate,
    'startedTime': task.startedTime,
    // 'enedTime': task.enedTime,
    'repeatDays': task.repeatDays,
    'repeatEvery': task.repeatEvery,
    'minAlertBeforeTask': task.minAlertBeforeTask,
    'type': task.type
  };

  static String encodeTasks(List<Task> tasks) => json.encode(
    tasks
      .map<Map<String, dynamic>>((task) => Task.toJson(task))
      .toList(),
  );

  static List<Task> decodeTasks(String tasks) {
    if(tasks != null)
      return (json.decode(tasks) as List<dynamic>)
        .map<Task>((item) => Task.fromJson(item))
        .toList();
    return List<Task>();
  }

  static String colorToHex(Color color) => '#${color.value.toRadixString(16)}';

  Color formattedColor() {
    this.color = color.replaceAll("#", "");
    if (color.length == 6) {
      color = "FF" + color;
    }
    if (color.length == 8) {
      return Color(int.parse("0x$color"));
    }
    return Color.fromRGBO(0, 0, 0, 0);
  }
  static DateTime dateTime(DateTime date, TimeOfDay time) => DateTime(date.year, date.month, date.day, time.hour, time.minute);

  static String dateTimeToString(DateTime date, TimeOfDay time) => DateFormat("yyyy-MM-dd HH:mm:ss").format(Task.dateTime(date, time));

  DateTime formattedDateTime() => DateFormat("yyyy-MM-dd HH:mm:ss").parse(startedDateTime);

  static DateTime dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool isToday() {
    final DateTime now = DateTime.now();
    return now.day == this.formattedDateTime().day &&
      now.month == this.formattedDateTime().month &&
      now.year == this.formattedDateTime().year;
  }
  static double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;

  static int timeToMinutes(TimeOfDay myTime) => myTime.hour * TimeOfDay.minutesPerHour + myTime.minute;

  static String time24Format(String time12Format) {
    final DateTime date = DateFormat.jm().parse(time12Format);
    return DateFormat("HH:mm").format(date);
  }

  TimeOfDay formattedTime() => TimeOfDay(hour:int.parse(startedTime.split(":")[0]),minute: int.parse(startedTime.split(":")[1]));

  static String repeatEveryToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }

  Duration formattedRepeatEvery() {
    int hours = 0;
    int minutes = 0;
    List<String> parts = repeatEvery.split(':');
    hours = int.parse(parts[0]);
    minutes = int.parse(parts[1]);
    // if (parts.length > 2) {
    //   hours = int.parse(parts[parts.length - 3]);
    // }
    // if (parts.length > 1) {
    //   minutes = int.parse(parts[parts.length - 2]);
    // }
    return Duration(hours: hours, minutes: minutes);
  }
}
