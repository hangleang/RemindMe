import 'package:auto_animated/auto_animated.dart';
import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/pages/EventPage.dart';
import 'package:codenova_reminders/pages/HabitPage.dart';
import 'package:codenova_reminders/pages/TaskDetailPage.dart';
import 'package:codenova_reminders/themes/themes.dart';
import 'package:codenova_reminders/shared/Error404.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<Tab> tabs = [
  Tab(
    child: Center(
      child: Text("ថ្ងៃនេះ"),
    ),
  ),
  Tab(
    child: Center(
      child: Text("ប្រតិទិន"),
    ),
  ),
];

class CustomInnerTabsPage extends StatefulWidget {
  @override
  _CustomInnerTabsPageState createState() => _CustomInnerTabsPageState();
}

class _CustomInnerTabsPageState extends State<CustomInnerTabsPage>{
  GlobalKey<ScaffoldState> _scaffoldKey;
  final ScrollController scrollController = ScrollController();
  SharedPreferences prefs;
  List<Task> tasks = List<Task>();
  String nickName;
  final options = LiveOptions(
    // Start animation after (default zero)
    // delay: Duration(seconds: 1),

    // Show each item through (default 250)
    showItemInterval: Duration(milliseconds: 500),

    // Animation duration (default 250)
    showItemDuration: Duration(seconds: 1),

    // Animations starts at 0.05 visible
    // item fraction in sight (default 0.025)
    visibleFraction: 0.05,

    // Repeat the animation of the appearance 
    // when scrolling in the opposite direction (default false)
    // To get the effect as in a showcase for ListView, set true
    reAnimateOnVisibility: true,
  );
  final ScrollController _tasksScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    fetchNickName();
    fetchTasks();
  }
  
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    final bgColor = Theme.of(context).backgroundColor;
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: DefaultTabController(
          length: tabs.length,
          child: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  centerTitle: false,
                  backgroundColor: bgColor,
                  elevation: 0,
                  expandedHeight: 200,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: textTheme.headline6,
                            children: [
                              TextSpan(text: greeting() + ",\n", style: textTheme.bodyText1.copyWith(color: Colors.black54, fontWeight: FontWeight.bold)),
                              TextSpan(text: nickName, style: textTheme.headline6)
                            ]
                          ),
                        ),
                        IconButton(
                          icon: Icon(LineAwesomeIcons.plus), 
                          onPressed: () {
                            showBarModalBottomSheet(
                              context: context, 
                              barrierColor: Colors.black38,
                              builder: (context, controller) => _buildListofAddTask(context),
                            );
                          }
                        )
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(100.0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: textTheme.bodyText1.fontSize, vertical: textTheme.bodyText2.fontSize),
                      child: TabBar(
                        unselectedLabelColor: primaryColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: THEMES.first
                          ),
                          borderRadius: BorderRadius.circular(textTheme.headline6.fontSize),
                          color: primaryColor
                        ),
                        tabs: tabs,
                      ),
                    ),
                  ),
                  pinned: true,
                  forceElevated: innerBoxIsScrolled,
                ),
              ];
            },
            body: Padding(
              padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
              child: TabBarView(
                children: [
                  mounted && tasks.length > 0 ? 
                  CustomScrollView(
                    controller: _tasksScrollController,
                    slivers: <Widget>[
                      LiveSliverList.options(
                        options: options,
                        controller: _tasksScrollController,
                        itemCount: tasks.length,
                        itemBuilder: (context, index, animation) {
                          final task = tasks.elementAt(index);

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
                              child: GestureDetector(
                                onTap: () async {
                                  List<Task> newTasks = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailPage(tasks: tasks, taskID: task.id)));
                                  if(mounted)
                                    setState(() {
                                      tasks = newTasks;
                                    });
                                }, 
                                child: Container(
                                  margin: EdgeInsets.only(bottom: textTheme.bodyText1.fontSize),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(textTheme.bodyText1.fontSize),
                                    color: task.formattedColor().withOpacity(0.9),
                                  ),
                                  child: ListTile(
                                    leading: Text(task.emoji, style: textTheme.headline6,),
                                    title: Text(task.title, style: textTheme.bodyText1.copyWith(color: Colors.white),),
                                    subtitle: task.type == TASK_EVENT_TYPE ? Text(TimeOfDay.fromDateTime(task.formattedDateTime()).format(context), style: textTheme.bodyText2.copyWith(color: Colors.white)) : Text(task.formattedTime().format(context), style: textTheme.bodyText2.copyWith(color: Colors.white)),
                                    contentPadding: EdgeInsets.all(textTheme.caption.fontSize),
                                    // trailing: Container(
                                    //   width: textTheme.bodyText1.fontSize,
                                    //   height: textTheme.bodyText1.fontSize,
                                    //   decoration: BoxDecoration(
                                    //     shape: BoxShape.circle,
                                    //     color: NOTIFICATION_STATUS_COLORS[task.status],
                                    //     border: Border.all(color: Colors.white, width: 2)
                                    //   ),
                                    // ),
                                  ),
                                ),
                              )
                            ),
                          );
                        },
                      ),
                    ]
                  )
                  : Error404(),
                  Icon(LineAwesomeIcons.calendar),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchTasks() async {
    //===========test=======
    
    // var tmp = [{"title" : "ABC", "date" : "10/06/2020"}, {"title" : "ABC", "date" : "10/06/2020"}];
    // setStorage("Tasks", tmp);
    // sleep(new Duration(seconds: 2));

    // loadStorageData();

    // print(tasks);
    // for(int i=0; i<tasks.length; i++){
    //   print(tasks[i]);
    // }

    //===========test=======

    prefs = await SharedPreferences.getInstance();
    String strTasks = prefs.getString("tasks");
    List<Task> newTasks = Task.decodeTasks(strTasks);
    if(mounted)
      setState(() {
        tasks = newTasks;
      });
    // prefs.setString("tasks", null);
  }

  Future<void> fetchNickName() async {
    prefs = await SharedPreferences.getInstance();
    if(mounted)
      setState(() {
        nickName = prefs.getString('nickname');
      });
  }

  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'អរុណ​សួស្តី';
    }
    if (hour < 17) {
      return 'ទិវាសួស្ដី';
    }
    return 'សាយ័ណ្ហសួស្ដី';
  }

  Future<void> storeNewTask(Task task) async {
    prefs = await SharedPreferences.getInstance();
    if(mounted)
      setState(() {
        tasks.add(task);
      });

    prefs.setString("tasks", Task.encodeTasks(tasks));
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
                builder: (context, scrollController) => HabitPage(lastTaskID: tasks.last?.id ?? 0),
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
                  Text("បង្កើតទម្លាប់")
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
                builder: (context, scrollController) => EventPage(lastTaskID: tasks.last?.id ?? 0),
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
                  Text("បង្កើតព្រឹត្តិការណ៍")
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}