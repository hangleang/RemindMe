import 'package:auto_animated/auto_animated.dart';
import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/model/NotificationModel.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/pages/EventPage.dart';
import 'package:codenova_reminders/pages/HabitPage.dart';
import 'package:codenova_reminders/pages/TaskDetailPage.dart';
import 'package:codenova_reminders/shared/Error404.dart';
import 'package:codenova_reminders/utils/global.dart';
import 'package:codenova_reminders/widgets/CustomListTile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  final List<Task> tasks;
  final List<NotificationModel> notifications;

  HomePage({this.tasks, this.notifications});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  GlobalKey<ScaffoldState> _scaffoldKey;
  ScrollController _scrollController;
  SharedPreferences prefs;
  List<Task> _tasks = List<Task>(), _recentUpcomingTasks = List<Task>();
  List<NotificationModel> _notifications = List<NotificationModel>();
  String _nickName;
  final _options = LiveOptions(
    showItemInterval: Duration(milliseconds: 500),
    showItemDuration: Duration(seconds: 1),
    visibleFraction: 0.05,
    // reAnimateOnVisibility: true,
  );

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _scrollController = ScrollController();
    fetchNickName();
    setTasksAndFilter(widget.tasks);
    _notifications = widget.notifications;
  }

  String greeting() {
    final int hour = TimeOfDay.now().hour;
    if (hour < 12) {
      return tr('morning');
    }
    if (hour < 17) {
      return tr('afternoon');
    }
    return tr('evening');
  }

  Future fetchNickName() async {
    prefs = await SharedPreferences.getInstance();
    if(mounted)
      setState(() {
        _nickName = prefs.getString('nickname');
      });
  }

  Future<List<Task>> setTasksAndFilter(List<Task> newTasks) async {
    List<Task> temp = newTasks.where((el) => (el.repeatDays != null ? el.repeatDays.elementAt(convertDateToWeekdayIndex(DateTime.now())) : el.isToday()) && (Task.timeToMinutes(el.formattedTime()) - Task.timeToMinutes(TimeOfDay.now())).abs() <= 2 * TimeOfDay.minutesPerHour).toList();
    temp.sort((a, b) => Task.timeToDouble(a.formattedTime()).compareTo(Task.timeToDouble(b.formattedTime())));
    setState(() {
      _tasks = newTasks;
      _recentUpcomingTasks = temp;
    });
    return _recentUpcomingTasks;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final Color primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Padding(
            padding: EdgeInsets.only(left: textTheme.bodyText1.fontSize, right: 8.0),
            child: AppBar(
              centerTitle: false,
              elevation: 0,
              flexibleSpace: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      style: textTheme.headline6,
                      children: [
                        TextSpan(text: greeting() + ",\n", style: textTheme.bodyText1.copyWith(color: Colors.black54, fontWeight: FontWeight.bold)),
                        TextSpan(text: _nickName, style: textTheme.headline6)
                      ]
                    ),
                  ),
                  Text(DateFormat("dd MMM yyyy", Localizations.localeOf(context).languageCode).format(DateTime.now()), style: textTheme.bodyText1),
                  IconButton(
                    icon: Icon(LineAwesomeIcons.plus), 
                    tooltip: tr('create'),
                    onPressed: () => showBarModalBottomSheet(
                      context: context, 
                      barrierColor: Colors.black38,
                      builder: (context, controller) => _buildListofAddTask(context),
                    )
                  )
                ],
              ),
            ),
          ), 
        ),
        body: FutureBuilder(
          future: setTasksAndFilter(_tasks),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            if(snapshot.hasData && snapshot.data.isNotEmpty) 
              return CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  LiveSliverList.options(
                    options: _options,
                    controller: _scrollController,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index, animation) {
                      final Task task = snapshot.data.elementAt(index);
                      return FadeTransition(
                        opacity: Tween<double>(
                          begin: 0,
                          end: 1,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(textTheme.bodyText2.fontSize, 0, textTheme.bodyText2.fontSize, textTheme.bodyText2.fontSize),
                            child: CustomListTile(
                              onTap: () async {
                                List<Task> newTasks = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailPage(taskID: task.id, tasks: _tasks, notifications: _notifications,)));
                                if(mounted && newTasks != null) {
                                  await setTasksAndFilter(newTasks);
                                  await storeTasksToStorage();
                                }
                              },
                              elevation: 0,
                              color: task.formattedColor().withOpacity(0.9),
                              leading: Text(task.emoji, style: textTheme.headline6,),
                              title: Text(task.title, style: textTheme.bodyText1.copyWith(color: Task.timeToDouble(task.formattedTime()) < Task.timeToDouble(TimeOfDay.now()) ? Colors.white60 : Colors.white),),
                              subtitle: Text(task.formattedTime().format(context), style: textTheme.bodyText2.copyWith(color: Task.timeToDouble(task.formattedTime()) < Task.timeToDouble(TimeOfDay.now()) ? Colors.white60 : Colors.white))
                            ),
                          ),
                        ),
                      );
                    },
                  ) 
                ],
              );
            else
              return Error404(text: tr('noTasksYet'),);
          })
      ),
    );
  }

  Future storeNewTask(Task task) async {
    prefs = await SharedPreferences.getInstance();
    if(mounted) {
      _tasks.add(task);
      await setTasksAndFilter(_tasks);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}