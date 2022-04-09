import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/model/NotificationModel.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/pages/EventPage.dart';
import 'package:codenova_reminders/pages/HabitPage.dart';
import 'package:codenova_reminders/pages/TaskDetailPage.dart';
import 'package:codenova_reminders/utils/global.dart';
import 'package:codenova_reminders/widgets/CustomListTile.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final List<NotificationModel> notifications;

  CalendarPage({this.tasks, this.notifications});
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  CalendarController _calendarController;
  SharedPreferences prefs;
  List<Task> _tasks = List<Task>(), _selectedDayTasks = List<Task>();
  List<NotificationModel> _notifications = List<NotificationModel>();
  Map<DateTime, List> _mapList;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _calendarController = CalendarController();
    setTasksAndGroup(widget.tasks);
    _notifications = widget.notifications;
  }

  Future setTasksAndGroup(List<Task> newTasks) async {
    setState(() {
      _tasks = newTasks;
      _mapList = groupBy(_tasks, (Task task) => task.type == TASK_EVENT_TYPE ? Task.dateOnly(task.formattedDateTime()) : Task.dateOnly(DateTime.now())).cast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(tr('calendar'), style: textTheme.bodyText1,),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(LineAwesomeIcons.plus), 
              tooltip: tr('create'),
              onPressed: () => showBarModalBottomSheet(
                context: context, 
                barrierColor: Colors.black38,
                builder: (context, controller) => _buildListofAddTask(context),
              )
            ),
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            onDaySelected: (DateTime day, List tasks) => _onDaySelected(day, tasks),
            calendarController: _calendarController,
            locale: Localizations.localeOf(context).languageCode,
            events: _mapList,
            availableCalendarFormats: {
              CalendarFormat.month : tr('month'),
              CalendarFormat.twoWeeks : tr('twoWeeks'),
              CalendarFormat.week : tr('week')
            },
            startingDayOfWeek: Localizations.localeOf(context) == supportedLocales.first ? StartingDayOfWeek.monday : StartingDayOfWeek.sunday,
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.black54,
          ),
          SizedBox(height: textTheme.caption.fontSize,),
          Expanded(
            child: _buildTaskList(context)
          )
        ],
      ),
    );
  }

  Future _onDaySelected(DateTime dateTime, List tasks) async {
    setState(() => _selectedDayTasks = List<Task>.from(tasks));
    _selectedDayTasks.sort((a, b) => Task.timeToDouble(a.formattedTime()).compareTo(Task.timeToDouble(b.formattedTime())));
  }

  Future storeNewTask(Task task) async {
    if(mounted) {
      _tasks.add(task);
      await setTasksAndGroup(_tasks);
      await storeTasksToStorage();
    }
    switch (task.type) {
      case TASK_EVENT_TYPE:
        if(task.formattedDateTime().compareTo(DateTime.now()) > 0)
          await _scheduleNotification(task);
        break;
      case TASK_HABIT_TYPE:
        await _showWeeklyAtDayAndTime(task);
        break;
      default: break;
    }
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

  Future storeNewNotification(NotificationModel notification) async {
    prefs = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        _notifications.add(notification);
      });
    }

    prefs.setString("notifications", NotificationModel.encodeNotifications(_notifications));
  }

  Future storeTasksToStorage() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("tasks", Task.encodeTasks(_tasks));
  }

  Widget _buildListofAddTask(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              Task task = await showBarModalBottomSheet<Task>(
                context: context,
                // topRadius: Radius.circular(textTheme.headline6.fontSize),
                duration: Duration(milliseconds: 500),
                elevation: 27,
                barrierColor: Theme.of(context).primaryColor,
                builder: (context, scrollController) => HabitPage(lastTaskID: _tasks.isNotEmpty ? _tasks.last.id : 0,),
              );
              if(task != null)
                await storeNewTask(task);
            } ,
            child: Padding(
              padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
              child: Row(
                children: <Widget>[
                  Icon(LineAwesomeIcons.calendar),
                  SizedBox(width: textTheme.bodyText1.fontSize,),
                  Text(tr('newHabit'))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              Task task = await showBarModalBottomSheet<Task>(
                context: context,
                // topRadius: Radius.circular(textTheme.headline6.fontSize),
                duration: Duration(milliseconds: 500),
                elevation: 27,
                barrierColor: Theme.of(context).primaryColor,
                builder: (context, scrollController) => EventPage(lastTaskID: _tasks.isNotEmpty ? _tasks.last.id : 0),
              );
              if(task != null)
                await storeNewTask(task);
            } ,
            child: Padding(
              padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
              child: Row(
                children: <Widget>[
                  Icon(LineAwesomeIcons.calendar_plus_o),
                  SizedBox(width: textTheme.bodyText1.fontSize,),
                  Text(tr('newTask'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      children: _selectedDayTasks
        .map((task) => Padding(
          padding: EdgeInsets.fromLTRB(textTheme.bodyText2.fontSize, 0, textTheme.bodyText2.fontSize, textTheme.bodyText2.fontSize),
          child: CustomListTile(
            onTap: () async {
              List<Task> newTasks = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailPage(tasks: _tasks, taskID: task.id, notifications: _notifications,)));
              if(mounted && newTasks != null) {
                await setTasksAndGroup(newTasks);
                await storeTasksToStorage();
              }
            },
            elevation: 0,
            color: task.formattedColor().withOpacity(0.9),
            padding: 8.0,
            leading: Text(task.emoji, style: textTheme.headline6,),
            title: Text(task.title, style: textTheme.bodyText1.copyWith(color: Colors.white),),
            subtitle: Text(task.formattedTime().format(context), style: textTheme.bodyText2.copyWith(color: Colors.white))
          ),
        )).toList(),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}