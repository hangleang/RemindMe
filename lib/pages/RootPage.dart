import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/main.dart';
import 'package:codenova_reminders/model/NotificationModel.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/pages/CalendarPage.dart';
import 'package:codenova_reminders/pages/SettingPage.dart';
import 'package:codenova_reminders/pages/StatsPage.dart';
import 'package:codenova_reminders/pages/HomePage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flashy_tab_bar/flashy_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  SharedPreferences prefs;
  List<Task> _tasks = List<Task>();
  List<NotificationModel> _notifications = List<NotificationModel>();
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    fetchTasks();
    fetchNotifications();
    _selectedIndex = 0;
    _requestIOSPermissions();
    // _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  Future fetchTasks() async {
    prefs = await SharedPreferences.getInstance();
    List<Task> tasks = Task.decodeTasks(prefs.getString("tasks"));
    if(tasks.isNotEmpty) 
      setState(() {
        _tasks = tasks;
      });
    // prefs.setString('tasks', null);
    // prefs.setString('notifications', null);
  }

  Future fetchNotifications() async {
    prefs = await SharedPreferences.getInstance();
    List<NotificationModel> notifications = NotificationModel.decodeNotifications(prefs.getString("notifications"));
    if(notifications.isNotEmpty) {
      setState(() {
        _notifications = notifications;
      });
    }
  }

  Future getSeletedIndex() async {
    return _selectedIndex;
  }

  void _requestIOSPermissions() async {
    flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  }

  // void _configureDidReceiveLocalNotificationSubject() {
  //   didReceiveLocalNotificationSubject.stream
  //       .listen((ReceivedNotification receivedNotification) async {
  //     await showDialog(
  //       context: context,
  //       builder: (BuildContext context) => CupertinoAlertDialog(
  //         title: receivedNotification.title != null
  //             ? Text(receivedNotification.title)
  //             : null,
  //         content: receivedNotification.body != null
  //             ? Text(receivedNotification.body)
  //             : null,
  //         actions: [
  //           CupertinoDialogAction(
  //             isDefaultAction: true,
  //             child: Text('Ok'),
  //             onPressed: () async {
  //               Navigator.of(context, rootNavigator: true).pop();
  //               await Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) =>
  //                       TaskDetailPage(taskID: int.parse(receivedNotification.payload), tasks: _tasks, notifications: _notifications,),
  //                 ),
  //               );
  //             },
  //           )
  //         ],
  //       ),
  //     );
  //     // NotificationModel notification = NotificationModel(id: receivedNotification.id, taskID: int.parse(receivedNotification.payload), createdAt: receivedNotification.createdAt.toString());
  //     // await storeNewNotification(notification);
  //   });
  // }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      Task task = _tasks.firstWhere((element) => element.id == int.parse(payload.split(',')[0]), orElse: () => null);
      NotificationModel notification = _notifications.firstWhere((element) => element.id == int.parse(payload.split(',')[1]), orElse: null);
      if(notification != null && task != null) {
        showDialog<bool>(
          context: context,
          builder: (BuildContext context) => _buildAlertDialog(task, context)
        ).then((isAccept) async {
          if(isAccept)
            notification.status = NOTIFICATION_ACCEPTED_STATUS;
          else if(!isAccept)
            notification.status = NOTIFICATION_MISSED_STATUS;
          notification.selectedAt = NotificationModel.dateTimeToString(DateTime.now());
          await updateNotication(notification);
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => TaskDetailPage(taskID: task.id, tasks: _tasks, notifications: _notifications,)),
          // );
        });
      }
    }, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    // final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;\
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: getSeletedIndex(),
        builder: (context, snapshot) {
          if(snapshot.hasData) 
            return [
              HomePage(tasks: _tasks, notifications: _notifications,),
              CalendarPage(tasks: _tasks, notifications: _notifications,),
              StatsPage(tasks: _tasks, notifications: _notifications),
              SettingPage()
            ].elementAt(snapshot.data);
          return Center(child: CircularProgressIndicator());
        } 
      ),
      bottomNavigationBar: FlashyTabBar(
        animationDuration: Duration(milliseconds: 400),
        selectedIndex: _selectedIndex,
        showElevation: true, // use this to remove appBar's elevation
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: Icon(LineAwesomeIcons.home),
            title: Text(tr('tasks')),
            activeColor: primaryColor
          ),
          FlashyTabBarItem(
            icon: Icon(LineAwesomeIcons.calendar),
            title: Text(tr('calendar')),
            activeColor: primaryColor
          ),
          FlashyTabBarItem(
            icon: Icon(LineAwesomeIcons.pie_chart),
            title: Text(tr('stats')),
            activeColor: primaryColor
          ),
          FlashyTabBarItem(
            icon: Icon(LineAwesomeIcons.cog),
            title: Text(tr('settings')),
            activeColor: primaryColor
          ),
        ],
      )
    );
  }

  Widget _buildAlertDialog(Task task, BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color primaryColor = Theme.of(context).primaryColor;

    return AlertDialog(
      title: Text(task.emoji + " "+ task.title, style: textTheme.bodyText1, textAlign: TextAlign.center,),
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: textTheme.bodyText2,
          children: [
            TextSpan(text: tr('doThisTask?') + "\n"),
            TextSpan(text: tr('noteDoThisTask'), style: textTheme.caption)
          ]
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
      ),
      actions: <Widget>[
        FlatButton.icon(onPressed: () => Navigator.pop(context, false), icon: Icon(LineAwesomeIcons.times_circle, color: Colors.red,), label: Text(tr('cancel'), style: textTheme.button.copyWith(color: Colors.red),)),
        FlatButton.icon(onPressed: () => Navigator.pop(context, true), icon: Icon(LineAwesomeIcons.check_circle), label: Text(tr('ok'), style: textTheme.button.copyWith(color: primaryColor),)),
      ],
    );
  }

  Future updateNotication(NotificationModel notification) async {
    prefs = await SharedPreferences.getInstance();
    List<NotificationModel> notifications = _notifications.map((NotificationModel n) => n == notification ? notification : n).toList();
    if(mounted)
      setState(() {
        _notifications = notifications;
      });
    prefs.setString("notifications", NotificationModel.encodeNotifications(notifications));
  }

  // @override
  // void dispose() {
  //   didReceiveLocalNotificationSubject.close();
  //   selectNotificationSubject.close();
  //   super.dispose();
  // }
}