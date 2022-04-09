import 'dart:convert';
import 'package:codenova_reminders/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  int id;
  int taskID;
  String createdAt;
  String selectedAt;
  int status; // 0: pending, 1: accepted, 2: missed, 3: late

  NotificationModel({
    @required this.id,
    @required this.taskID,
    @required this.createdAt,
    this.selectedAt,
    this.status = NOTIFICATION_PENDING_STATUS
  });

  factory NotificationModel.fromJson(Map<String, dynamic> jsonData) {
    return NotificationModel(
      id: jsonData['id'],
      taskID: jsonData['taskID'],
      createdAt: jsonData['createdAt'],
      selectedAt: jsonData['selectedAt'],
      status: jsonData['status']
    );
  }

  static Map<String, dynamic> toJson(NotificationModel notification) => {
    'id': notification.id,
    'taskID': notification.taskID,
    'createdAt': notification.createdAt,
    'selectedAt': notification.selectedAt,
    'status': notification.status
  };

  static String encodeNotifications(List<NotificationModel> notifications) => json.encode(
    notifications
      .map<Map<String, dynamic>>((notification) => NotificationModel.toJson(notification))
      .toList(),
  );

  static List<NotificationModel> decodeNotifications(String notifications) {
    if(notifications != null)
      return (json.decode(notifications) as List<dynamic>)
        .map<NotificationModel>((item) => NotificationModel.fromJson(item))
        .toList();
    return List<NotificationModel>();
  }

  static DateTime dateTime(DateTime date, TimeOfDay time) => DateTime(date.year, date.month, date.day, time.hour, time.minute);

  static String dateTimeToString(DateTime date) => DateFormat("yyyy-MM-dd HH:mm:ss").format(date);

  DateTime formattedCreatedAt() => DateFormat("yyyy-MM-dd HH:mm:ss").parse(this.createdAt);

  DateTime formattedSelectedAt() => DateFormat("yyyy-MM-dd HH:mm:ss").parse(this.selectedAt);

  static DateTime dateOnly(DateTime dateTime) => DateTime(dateTime.year, dateTime.month, dateTime.day);
}
