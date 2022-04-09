import 'package:codenova_reminders/constants/constants.dart';
import 'package:flutter/material.dart';

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  final DateTime createdAt;
  final int status; // 0: pending, 1: accepted, 2: missed, 3: late

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
    this.createdAt,
    this.status = NOTIFICATION_PENDING_STATUS
  });
}