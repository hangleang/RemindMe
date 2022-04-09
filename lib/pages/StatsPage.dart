import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/model/NotificationModel.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/pages/NotificationsPage.dart';
import 'package:codenova_reminders/pages/TaskDetailPage.dart';
import 'package:codenova_reminders/shared/Error404.dart';
import 'package:codenova_reminders/themes/themes.dart';
import 'package:codenova_reminders/widgets/CustomListTile.dart';
import 'package:codenova_reminders/widgets/CustomRoundedBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatefulWidget {
  final List<Task> tasks;
  final List<NotificationModel> notifications;

  StatsPage({this.tasks, this.notifications});
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  SharedPreferences prefs;
  DateTime _date;
  int touchedIndex;
  List<Task> _tasks = List<Task>();
  List<NotificationModel> _notifications = List<NotificationModel>();
  List<NotificationModel> _currentNotifications = List<NotificationModel>();
  List<NotificationModel> _acceptedNotifications = List<NotificationModel>();
  List<NotificationModel> _pendingNotifications = List<NotificationModel>();
  List<NotificationModel> _missedNotifications = List<NotificationModel>();
  List<int> _groupNotificationsLength = List<int>();
  final List<String> _groupNotiTaskStatus = [
    tr('pendingTasks'),
    tr('acceptedTasks'),
    tr('missedTasks')
  ];
  final List<String> _groupNotiStatus = [
    tr('pending'),
    tr('accepted'),
    tr('missed')
  ];

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _date = DateTime.now();
    _tasks = widget.tasks;
    filterAndSortNotifications(widget.notifications);
  }

  Future filterAndSortNotifications(List<NotificationModel> notifications) async {
    setState(() {
      _notifications = notifications;
      _currentNotifications = notifications.where((noti) => NotificationModel.dateOnly(noti.formattedCreatedAt()) == NotificationModel.dateOnly(_date)).toList();
      _currentNotifications.sort((a, b) => a.formattedCreatedAt().compareTo(b.formattedCreatedAt()));
      _acceptedNotifications = _currentNotifications.where((element) => element.status == NOTIFICATION_ACCEPTED_STATUS).toList();
      _pendingNotifications = _currentNotifications.where((element) => element.status == NOTIFICATION_PENDING_STATUS).toList();
      _missedNotifications = _currentNotifications.where((element) => element.status == NOTIFICATION_MISSED_STATUS).toList();
      _groupNotificationsLength = [
        _pendingNotifications.length,
        _acceptedNotifications.length,
        _missedNotifications.length
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    final Color primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: textTheme.bodyText1.fontSize),
            child: AppBar(
              elevation: 0,
              flexibleSpace: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(tr('stats'), style: textTheme.bodyText1,),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      DateTime datetime = await showRoundedDatePicker(
                        context: context, 
                        theme: Theme.of(context).copyWith(primaryColor: primaryColor, accentColor: primaryColor),
                        initialDate: _date,  
                        lastDate: DateTime.now(),
                        borderRadius: textTheme.bodyText1.fontSize,
                      );

                      if(datetime != null) {
                        setState(() {
                          _date = datetime;
                        });
                        filterAndSortNotifications(_notifications);
                      }
                    },
                    child: CustomRoundedBox(
                      child: Row(
                        children: <Widget>[
                          Text(DateFormat("dd MMM yyyy", Localizations.localeOf(context).languageCode).format(_date), style: textTheme.bodyText1,),
                          SizedBox(width: 4.0,),
                          Icon(LineAwesomeIcons.angle_down, size: textTheme.bodyText1.fontSize,)
                        ],
                      )
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
          child: _currentNotifications.isNotEmpty ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // chart section
              Row(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _groupNotiStatus.map((notiStatus) => Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: textTheme.headline6.fontSize,
                            width: textTheme.headline6.fontSize,
                            decoration: BoxDecoration(
                              color: NOTIFICATION_STATUS_COLORS[_groupNotiStatus.indexOf(notiStatus)],
                              shape: BoxShape.circle
                            ),
                          ),
                          SizedBox(width: 8.0,),
                          Text(notiStatus, style: textTheme.caption,),
                        ],
                      ),
                    )).toList()
                  ),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: textTheme.headline6.fontSize,
                        sections: showingSections(),
                        pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse.touchInput is FlLongPressEnd ||
                                pieTouchResponse.touchInput is FlPanEnd) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = pieTouchResponse.touchedSectionIndex;
                            }
                          });
                        }),
                      ),
                      swapAnimationDuration: Duration(milliseconds: 500),
                    ),
                  ),
                ],
              ),

              // pending section
              _pendingNotifications.isNotEmpty ? Container(
                margin: EdgeInsets.symmetric(vertical: textTheme.caption.fontSize),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: textTheme.bodyText1.fontSize),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_groupNotiTaskStatus.elementAt(NOTIFICATION_PENDING_STATUS) + " (" + _pendingNotifications.length.toString() + ")", style: textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage(notifications: _pendingNotifications, tasks: _tasks, title: _groupNotiTaskStatus.elementAt(NOTIFICATION_PENDING_STATUS)))), 
                      child: Text(tr('seeAll'), style: textTheme.caption,)
                    )
                  ],
                ),
              ) : Container(),
              SizedBox(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _pendingNotifications.take(3).length,
                  itemBuilder: (BuildContext context, int index) => _listNotiSection(context, index, _pendingNotifications)
                ),
              ),

              // accepted section
              _acceptedNotifications.isNotEmpty ? Container(
                margin: EdgeInsets.symmetric(vertical: textTheme.caption.fontSize),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: textTheme.bodyText1.fontSize),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_groupNotiTaskStatus.elementAt(NOTIFICATION_ACCEPTED_STATUS)+ " (" + _acceptedNotifications.length.toString() + ")", style: textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage(notifications: _acceptedNotifications, tasks: _tasks, title: _groupNotiTaskStatus.elementAt(NOTIFICATION_ACCEPTED_STATUS)))),  
                      child: Text(tr('seeAll'), style: textTheme.caption,)
                    )
                  ],
                ),
              ) : Container(),
              SizedBox(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _acceptedNotifications.take(3).length,
                  itemBuilder: (BuildContext context, int index) => _listNotiSection(context, index, _acceptedNotifications)
                ),
              ),

              // missed section
              _missedNotifications.isNotEmpty ? Container(
                margin: EdgeInsets.symmetric(vertical: textTheme.caption.fontSize),
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: textTheme.bodyText1.fontSize),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_groupNotiTaskStatus.elementAt(NOTIFICATION_MISSED_STATUS)+ " (" + _missedNotifications.length.toString() + ")", style: textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage(notifications: _missedNotifications, tasks: _tasks, title: _groupNotiTaskStatus.elementAt(NOTIFICATION_MISSED_STATUS)))),  
                      child: Text(tr('seeAll'), style: textTheme.caption,)
                    )
                  ],
                ),
              ) : Container(),
              SizedBox(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: _missedNotifications.take(3).length,
                  itemBuilder: (BuildContext context, int index) => _listNotiSection(context, index, _missedNotifications)
                ),
              ),
            ],
          ) : Error404(text: tr('noReports'))
        ),
      ),
    );
  }

  Widget _listNotiSection(BuildContext context, int index, List<NotificationModel> notifications) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Task task = _tasks.firstWhere((task) => notifications[index].taskID == task.id, orElse: () => null);

      if(task != null)
        return CustomListTile(
          onTap: () async {
            List<Task> newTasks = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailPage(taskID: task.id, tasks: _tasks, notifications: _notifications,)));
            if(mounted && newTasks != null)
              setState(() {
                _tasks = newTasks;
              });
          },
          elevation: 0,
          padding: 0,
          color: task.formattedColor().withOpacity(0.9),
          leading: Text(task.emoji, style: textTheme.headline6,),
          title: Text(task.title, style: textTheme.bodyText1.copyWith(color: Colors.white),),
          subtitle: Text(task.formattedTime().format(context), style: textTheme.bodyText2.copyWith(color: Colors.white))
        );
      return Container();
  }

  List<PieChartSectionData> showingSections() {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return _groupNotificationsLength.map((e) {
      final isTouched = _groupNotificationsLength.indexOf(e) == touchedIndex;
      final double fontSize = isTouched ? textTheme.bodyText1.fontSize : textTheme.bodyText2.fontSize;
      final double radius = isTouched ? 60 : 50;  
      final String value = (e * 100 / _currentNotifications.length).toStringAsFixed(1);

      return PieChartSectionData(
        color: NOTIFICATION_STATUS_COLORS[_groupNotificationsLength.indexOf(e)],
        value: num.parse(value),
        title: value+"%",
        radius: radius,
        titleStyle: textTheme.bodyText2.copyWith(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
      );
    }).toList();
  }
}