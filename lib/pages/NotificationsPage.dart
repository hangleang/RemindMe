import 'package:codenova_reminders/model/NotificationModel.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/widgets/CustomListTile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class NotificationsPage extends StatelessWidget {
  final List<NotificationModel> notifications;
  final List<Task> tasks;
  final String title;

  NotificationsPage({@required this.notifications, @required this.tasks, @required this.title});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left), 
          tooltip: tr('back'),
          onPressed: () => Navigator.pop(context, tasks),
        ),
        title: Text(title, style: textTheme.bodyText1,)
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: notifications.length,
        itemBuilder: (context, index) => _listNotiSection(context, index),
      ),
    );
  }

  Widget _listNotiSection(BuildContext context, int index) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Task task = tasks.firstWhere((task) => notifications[index].taskID == task.id, orElse: () => null);

      if(task != null)
        return CustomListTile(
          // onTap: () async {
          //   List<Task> newTasks = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailPage(taskID: task.id, tasks: _tasks, notifications: _notifications,)));
          //   if(mounted && newTasks != null)
          //     setState(() {
          //       _tasks = newTasks;
          //     });
          // },
          elevation: 0,
          padding: 0,
          color: task.formattedColor().withOpacity(0.9),
          leading: Text(task.emoji, style: textTheme.headline6,),
          title: Text(task.title, style: textTheme.bodyText1.copyWith(color: Colors.white),),
          subtitle: Text(task.formattedTime().format(context), style: textTheme.bodyText2.copyWith(color: Colors.white))
        );
      return Container();
  }
}