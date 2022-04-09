import 'dart:ui';

const String APP_NAME = "Reminders";

const List<Locale> supportedLocales = [
  const Locale('km', 'KH'), // Khmer
  const Locale('en', 'US'), // English
];

const int TASK_HABIT_TYPE = 1;
const int TASK_EVENT_TYPE = 2;

const int NOTIFICATION_PENDING_STATUS = 0;
const int NOTIFICATION_ACCEPTED_STATUS = 1;
const int NOTIFICATION_MISSED_STATUS = 2;
const int NOTIFICATION_LATE_STATUS = 3;

const String APP_PREFIX = "CN";

const List<int> availableHours = [
  0, 1, 2
];

const List<int> availableMinutes = [
  0, 15, 30, 45
];
