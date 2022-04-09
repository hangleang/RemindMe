import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/main.dart';
import 'package:codenova_reminders/model/NotificationModel.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/pages/EventPage.dart';
import 'package:codenova_reminders/utils/global.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HabitPage.dart';

class TaskDetailPage extends StatefulWidget {
  final List<Task> tasks;
  final List<NotificationModel> notifications;
  final int taskID;

  TaskDetailPage({@required this.taskID, this.tasks, this.notifications});
  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  SharedPreferences prefs;
  List<Task> _tasks = List<Task>();
  List<NotificationModel> _notifications = List<NotificationModel>();
  Task _task;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
    _notifications = widget.notifications;
    _task = _tasks.firstWhere((element) => element.id == widget.taskID, orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        textTheme: textTheme,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left), 
          tooltip: tr('back'),
          onPressed: () => Navigator.pop(context, _tasks),
        ),
        title: Text(tr('taskDetail'), style: textTheme.bodyText1,),
        actions: <Widget>[
          IconButton(
            icon: Icon(LineAwesomeIcons.pencil), 
            tooltip: tr('edit'),
            onPressed: () async {
              Task editedTask = await showBarModalBottomSheet<Task>(
                context: context,
                // topRadius: Radius.circular(textTheme.headline6.fontSize),
                duration: Duration(milliseconds: 500),
                elevation: 27,
                barrierColor: Theme.of(context).primaryColor,
                builder: (context, scrollController) => _task.type == TASK_HABIT_TYPE ? HabitPage(lastTaskID: _tasks.isNotEmpty ? _tasks.last.id : 0, task: _task,) : EventPage(lastTaskID: _tasks.isNotEmpty ? _tasks.last.id : 0, task: _task,),
              );

              if(editedTask != null) {
                _notifications.forEach((noti) { 
                  if(_task.id == noti.taskID) {
                    flutterLocalNotificationsPlugin.cancel(noti.id);
                  }
                });
                await updateTask(editedTask);
                await storeTasksToStorage();

                switch (_task.type) {
                  case TASK_EVENT_TYPE:
                    if(_task.formattedDateTime().compareTo(DateTime.now()) > 0)
                      await _scheduleNotification(_task);
                    break;
                  case TASK_HABIT_TYPE:
                    await _showWeeklyAtDayAndTime(_task);
                    break;
                  default: break;
                }
                await setNotifications();
              }
            }
          ),
          IconButton(
            icon: Icon(LineAwesomeIcons.trash), 
            tooltip: tr('delete'),
            onPressed: () async {
              bool option = await showDialog(
                context: context,
                builder: (context) => _buildAlertDialog(context),
              );
              
              if(option != null && option) {
                _notifications.forEach((noti) { 
                  if(noti.taskID == _task.id) {
                    flutterLocalNotificationsPlugin.cancel(noti.id);
                  }
                });
                _notifications.removeWhere((noti) => noti.taskID == _task.id);
                await setNotifications();
                await removeTask();
                Navigator.pop(context, _tasks);
              }
            }
          ),
          SizedBox(width: textTheme.caption.fontSize,)
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyText1,
                children: [
                  TextSpan(text: tr('title') + tr('colon') + "   "),
                  TextSpan(text: _task.title)
                ]
              )
            ),
          ),
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyText1,
                children: [
                  TextSpan(text: tr('icon') + tr('colon') + "   "),
                  TextSpan(text: _task.emoji, style: textTheme.headline6)
                ]
              )
            ),
          ),
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: Row(
              children: <Widget>[
                Text(tr('color') + tr('colon'), style: textTheme.bodyText1,),
                SizedBox(width: textTheme.bodyText1.fontSize,),
                Container(
                  width: textTheme.headline4.fontSize,
                  height: textTheme.headline4.fontSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _task.formattedColor().withOpacity(0.9)
                  ),
                )
              ],
            ),
          ),
          _task.type == TASK_EVENT_TYPE ?
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyText1,
                children: [
                  TextSpan(text: tr('startedDateTime') + tr('colon') + "   "),
                  TextSpan(text: DateFormat("dd MMM yyyy hh:mm a", Localizations.localeOf(context).languageCode).format(_task.formattedDateTime())),
                ]
              )
            ),
          ) : 
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyText1,
                children: [
                  TextSpan(text: tr('startedTime') + tr('colon') + "   "),
                  TextSpan(text: _task.formattedTime().format(context))
                ]
              )
            ),
          ),
          _task.type == TASK_HABIT_TYPE ? 
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyText1,
                children: [
                  TextSpan(text: tr('repeatEvery') + tr('colon') + "   "),
                  TextSpan(text: displayRepeatDays(_task)),
                ]
              )
            ),
          ) : Container(),
          _task.repeatEvery != null ?
          Padding(
            padding: EdgeInsets.all(textTheme.bodyText2.fontSize),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyText1,
                children: [
                  TextSpan(text: tr('remindEvery') + tr('colon') + "   "),
                  TextSpan(text: _task.formattedRepeatEvery().inHours.toString() + plural('hours', _task.formattedRepeatEvery().inHours) + " "),
                  TextSpan(text: (_task.formattedRepeatEvery().inMinutes % 60).toString() + plural('minutes', (_task.formattedRepeatEvery().inMinutes % 60)))
                ]
              )
            ),
          ) : Container(),
        ],
      ),
    );
  }

  String displayRepeatDays(Task task) {
    String result = "";
    List<bool> temp = List<bool>.from(task.repeatDays);
    if(temp.every((e) => e)) result = tr('everyDay');
    else if(temp.getRange(1, temp.length - 1).every((e) => e) && !temp.first && !temp.last) result = tr('weekdays');
    else if(temp.getRange(1, temp.length - 1).every((e) => !e) && temp.first && temp.last) result = tr('weekends');
    else {
      for(int i = 0; i < temp.length; i++)
       if(temp.elementAt(i))
        result += longWeekdays.elementAt(i) + ", ";
      result = result.substring(0, result.length - 2);
    }
    return result;
  }

  Future _scheduleNotification(Task task) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Event Channel ID',
      'Event Notification',
      'Event Desc');
    IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    int notificationID = _notifications.isNotEmpty ? _notifications.last.id + 1 : 1;
    await flutterLocalNotificationsPlugin.schedule(
      notificationID,
      task.emoji + " - " + task.title,
      DateFormat("dd MMM yyyy hh:mm a", Localizations.localeOf(context).languageCode).format(task.formattedDateTime()),
      task.formattedDateTime(),
      platformChannelSpecifics,
      payload: task.id.toString()+","+notificationID.toString(),
      androidAllowWhileIdle: true
    );

    NotificationModel notification = NotificationModel(id: _notifications.isNotEmpty ? _notifications.last.id + 1 : 1, taskID: task.id, createdAt: NotificationModel.dateTimeToString(DateTime.now()));
    await storeNewNotification(notification);
  }

  Future _showWeeklyAtDayAndTime(Task task) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Habit Channel ID',
      'Habit Notification',
      'Habit Desc');
    IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    for(int i = 0; i < task.repeatDays.length; i++) {
      if(task.repeatDays[i]) {
        int notificationID = _notifications.isNotEmpty ? _notifications.last.id + 1 : 1;
        await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
          notificationID,
          task.emoji + " - " + task.title,
          displayRepeatDays(task)+" "+tr('at')+" "+task.formattedTime().format(context),
          Day.values.elementAt(i),
          Time(task.formattedTime().hour, task.formattedTime().minute),
          platformChannelSpecifics,
          payload: task.id.toString()+","+notificationID.toString()
        );

        NotificationModel notification = NotificationModel(id: _notifications.isNotEmpty ? _notifications.last.id + 1 : 1, taskID: task.id, createdAt: NotificationModel.dateTimeToString(DateTime.now()));
        await storeNewNotification(notification);
      }
    }
  }

  Future updateTask(Task editedTask) async {
    if(mounted)
      setState(() {
        _tasks = _tasks.map((Task t) => t == _task ? editedTask : t).toList();
        _task = editedTask;
      });
  }

  Future storeTasksToStorage() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("tasks", Task.encodeTasks(_tasks));
  }

  Future removeTask() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.removeWhere((Task t) => t == _task);
    });
    prefs.setString("tasks", Task.encodeTasks(_tasks));
  }
  
  Future storeNewNotification(NotificationModel notification) async {
    prefs = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        _notifications.add(notification);
      });
    }

    prefs.setString("notifications", NotificationModel.encodeNotifications(_notifications));
  }

  Future setNotifications() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("notifications", NotificationModel.encodeNotifications(_notifications));
  }

  Widget _buildAlertDialog(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(tr('deleteTask'), textAlign: TextAlign.center,),
      titleTextStyle: textTheme.bodyText1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
      ),
      actions: <Widget>[
        FlatButton(onPressed: () => Navigator.pop(context, false), child: Text(tr('cancel'), style: textTheme.button.copyWith(color: Colors.grey),)),
        FlatButton(onPressed: () => Navigator.pop(context, true), child: Text(tr('ok'), style: textTheme.button.copyWith(color: Colors.red),)),
      ],
    );
  }

}