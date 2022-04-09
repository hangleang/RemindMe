import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/model/Task.dart';
import 'package:codenova_reminders/themes/themes.dart';
import 'package:codenova_reminders/widgets/CustomRoundedBox.dart';
import 'package:codenova_reminders/widgets/CustomTextField.dart';
import 'package:codenova_reminders/widgets/GradientButton.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class EventPage extends StatefulWidget {
  final int lastTaskID; 
  final Task task;

  EventPage({@required this.lastTaskID, this.task});
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _titleController;
  DateTime _date;
  TimeOfDay _time;
  Color _color;
  Emoji _emoji;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _titleController = TextEditingController(text: widget.task?.title);
    _date = widget.task?.formattedDateTime() ?? DateTime.now();
    _time = widget.task?.formattedTime() ?? TimeOfDay.now();
    _color = widget.task?.formattedColor();
    _emoji = Emoji(name: null, emoji: widget.task != null ? widget.task.emoji : "🙂");
  }
  
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).accentColor;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: false,
          body: ListView(
            padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(widget.task != null ? tr('editTask') : tr('newTask'), style: textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),),
                  IconButton(
                    icon: Icon(LineAwesomeIcons.times_circle), 
                    tooltip: tr('close'),
                    splashColor: Colors.transparent,
                    iconSize: textTheme.headline6.fontSize,
                    onPressed: () => Navigator.of(context).pop()
                  ),
                ],
              ),
              SizedBox(height: textTheme.bodyText1.fontSize,),
              CustomTextField(
                controller: _titleController,
                hintText: tr('enter') + tr('title'),
                onChanged: (String value) {
                  setState(() {
                    _titleController.text = value;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: textTheme.subtitle1.fontSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showEmojiPicker(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: textTheme.headline3.fontSize,
                            height: textTheme.headline3.fontSize,
                            decoration: BoxDecoration(
                              color: _color ?? primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(_emoji.emoji, style: textTheme.headline6,),
                          ),
                        ),
                        SizedBox(width: textTheme.subtitle1.fontSize),
                        Text(tr('icon'), style: textTheme.subtitle1,)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            showColorPicker(context);
                          },
                          child: Container(
                            width: textTheme.headline3.fontSize,
                            height: textTheme.headline3.fontSize,
                            decoration: BoxDecoration(
                              color: _color ?? primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: textTheme.subtitle1.fontSize),
                        Text(tr('color'), style: textTheme.subtitle1,),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: textTheme.subtitle1.fontSize, bottom: textTheme.subtitle2.fontSize),
                child: Text(tr('startedDateTime'), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        showRoundedDatePicker(
                          context: context, 
                          theme: Theme.of(context).copyWith(primaryColor: _color ?? primaryColor, accentColor: _color ?? primaryColor),
                          initialDate: _date, 
                          firstDate: DateTime.now().subtract(Duration(days: 1)), 
                          borderRadius: textTheme.bodyText1.fontSize,
                        ).then((DateTime value) => {
                          if(value != null)
                            setState(() {
                              _date = value;
                            })
                        });
                      },
                      child: CustomRoundedBox(
                        child: Text(DateFormat("dd MMM yyyy", Localizations.localeOf(context).languageCode).format(_date), style: textTheme.bodyText1,)
                      )
                    ),
                  ),
                  SizedBox(width: textTheme.bodyText1.fontSize,),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).push(showPicker(
                          context: context,
                          value: _time,
                          onChange: (TimeOfDay time) => {
                            setState(() {
                              _time = time;
                            })
                          },
                          accentColor: _color ?? primaryColor,
                          okText: tr('ok'),
                          cancelText: tr('cancel')
                        ));
                      },
                      child: CustomRoundedBox(
                        child: Text(_time.format(context), style: textTheme.bodyText1,)
                      )
                    ),
                  ),
                ],
              ),
              Container(
                height: screenHeight * .4,
                alignment: Alignment.bottomCenter,
                child: GradientButton(
                  onPressed: _titleController.text.trim() == "" ? null : () async {
                    Navigator.of(context).pop(await saveTask(context));
                  }, 
                  width: screenWidth * .8,
                  height: screenHeight * .1,
                  text: Text(tr('save'), style: textTheme.subtitle1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                  gradient: LinearGradient(colors: [accentColor, primaryColor]),
                ),
              )
            ],
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          // floatingActionButton: GradientButton(
          //   onPressed: _titleController.text.trim() == "" ? null : () {
          //     Navigator.pop(context);
          //   }, 
          //   width: screenWidth * .8,
          //   height: screenHeight * .1,
          //   text: Text("រក្សាទុក", style: textTheme.subtitle1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
          //   gradient: LinearGradient(colors: [accentColor, primaryColor]),
          // ),
        ),
      ),
    );
  }

  Future<void> showColorPicker(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;
    final Color primaryColor = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      child: AlertDialog(
        title: Text(tr('choose') + tr('color'), style: textTheme.bodyText1,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(textTheme.bodyText1.fontSize)
        ),
        content: BlockPicker(
          availableColors: THEMES.map((e) => e.last).toList(),
          pickerColor: _color ?? primaryColor,
          onColorChanged: (color) {
            setState(() => _color = color);
            Navigator.of(context).pop();
          },
          itemBuilder: (color, isCurrentColor, changeColor) => GestureDetector(
            onTap: () => changeColor(),
            child: Container(
              padding: EdgeInsets.all(textTheme.caption.fontSize),
              decoration: BoxDecoration(
                color: isCurrentColor ? Colors.black12 : Colors.transparent,
                borderRadius: BorderRadius.circular(textTheme.bodyText1.fontSize)
              ),
              child: Container(
                width: textTheme.headline6.fontSize,
                height: textTheme.headline6.fontSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle
                ),
                child: isCurrentColor ? Icon(LineAwesomeIcons.check, color: Colors.white) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showEmojiPicker(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;

    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text(tr('choose') + tr('icon'), style: textTheme.bodyText1,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(textTheme.bodyText1.fontSize))
        ),
        insetPadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
        contentPadding: EdgeInsets.zero,
        content: EmojiPicker(
          numRecommended: 10,
          onEmojiSelected: (emoji, category) {
            setState(() {
              _emoji = emoji;
            });
            Navigator.pop(context);
          },
        ),
      )
    );
  }

  Future<Task> saveTask(BuildContext context) async {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Task(
      id: widget.task?.id ?? widget.lastTaskID + 1,
      title: _titleController.text,
      color: Task.colorToHex(_color ?? primaryColor),
      emoji: _emoji.emoji,
      startedDateTime: Task.dateTimeToString(_date, _time),
      startedTime: Task.time24Format(_time.format(context)),
      type: TASK_EVENT_TYPE
    );
  }
}