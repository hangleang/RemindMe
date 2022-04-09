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
import 'package:flutter_switch/flutter_switch.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:weekday_selector/weekday_selector.dart';

class HabitPage extends StatefulWidget {
  final int lastTaskID;
  final Task task; 

  HabitPage({@required this.lastTaskID, this.task});
  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _titleController;
  List<bool> _repeatWeekdays;
  TimeOfDay _time;
  Color _color;
  Emoji _emoji;
  bool _isRepeatEvery;
  int _repeatEveryHours;
  int _repeatEveryMinutes;

  final List<String> shortWeekdays = [
    tr('shortSun'),
    tr('shortMon'),
    tr('shortTues'),
    tr('shortWed'),
    tr('shortThurs'),
    tr('shortFri'),
    tr('shortSat')
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _repeatWeekdays = widget.task != null ? List<bool>.from(widget.task.repeatDays) : List.filled(7, true);
    _time = widget.task?.formattedTime() ?? TimeOfDay.now();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _color = widget.task?.formattedColor();
    _emoji = Emoji(name: null, emoji: widget.task?.emoji ?? "🙂");
    _isRepeatEvery = widget.task?.repeatEvery != null;
    _repeatEveryHours = widget.task?.repeatEvery != null ? widget.task.formattedRepeatEvery().inHours : 0;
    _repeatEveryMinutes = widget.task?.repeatEvery != null ? widget.task.formattedRepeatEvery().inMinutes % 60 : 0;
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
                  Text(widget.task != null ? tr('editHabit') : tr('newHabit'), style: textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold),),
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
                padding: EdgeInsets.only(top: textTheme.subtitle1.fontSize),
                child: Text(tr('repeatEvery'), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),),
              ),
              WeekdaySelector(
                elevation: textTheme.bodyText2.fontSize,
                selectedFillColor: _color ?? primaryColor,
                onChanged: (int day) {
                  final index = day % 7;
                  setState(() {
                    _repeatWeekdays[index] = !_repeatWeekdays[index];
                  });
                },
                shortWeekdays: shortWeekdays,
                values: _repeatWeekdays,
              ),
              Padding(
                padding: EdgeInsets.only(top: textTheme.subtitle1.fontSize, bottom: textTheme.subtitle2.fontSize),
                child: Text(tr('startedTime'), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),),
              ),
              GestureDetector(
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
                    is24HrFormat: false,
                    okText: tr('ok'),
                    cancelText: tr('cancel')
                  ));
                },
                child: CustomRoundedBox(
                  child: Text(_time.format(context), style: textTheme.bodyText1,)
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: textTheme.subtitle1.fontSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(tr('remindEvery'), style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),),
                    FlutterSwitch(
                      activeColor: _color ?? primaryColor,
                      inactiveColor: Colors.black12,
                      width: screenWidth * 0.16,
                      value: _isRepeatEvery,
                      onToggle: (bool val) {
                        setState(() {
                          _isRepeatEvery = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              _isRepeatEvery ? 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(plural('hours', 2), style: textTheme.bodyText2,),
                        SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: RadioButtonGroup(
                            labels: availableHours.map((e) => e.toString()).toList(),
                            orientation: GroupedButtonsOrientation.HORIZONTAL,
                            picked: _repeatEveryHours.toString(),
                            labelStyle: textTheme.bodyText1,
                            onChange: (String selected, int index) => setState(() => _repeatEveryHours = availableHours.elementAt(index)),
                            itemBuilder: (radioButton, label, index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              alignment: Alignment.center,
                              width: textTheme.headline3.fontSize,
                              height: textTheme.headline3.fontSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: availableHours.elementAt(index) == _repeatEveryHours ? _color ?? primaryColor : Colors.black12
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Text(availableHours.elementAt(index).toString(), style: textTheme.bodyText1.copyWith(color: availableHours.elementAt(index) == _repeatEveryHours ? Colors.white : Colors.black,)),
                                  Opacity(
                                    opacity: 0,
                                    child: radioButton
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: textTheme.bodyText1.fontSize,
                  ),
                  Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(plural('minutes', 2), style: textTheme.bodyText2,),
                        SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: RadioButtonGroup(
                            labels: availableMinutes.map((e) => e.toString()).toList(),
                            orientation: GroupedButtonsOrientation.HORIZONTAL,
                            picked: _repeatEveryMinutes.toString(),
                            labelStyle: textTheme.bodyText1,
                            onChange: (String selected, int index) => setState(() => _repeatEveryMinutes = availableMinutes.elementAt(index)),
                            itemBuilder: (radioButton, label, index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 3),
                              alignment: Alignment.center,
                              width: textTheme.headline3.fontSize,
                              height: textTheme.headline3.fontSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: availableMinutes.elementAt(index) == _repeatEveryMinutes ? _color ?? primaryColor : Colors.black12
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Text(availableMinutes.elementAt(index).toString(), style: textTheme.bodyText1.copyWith(color: availableMinutes.elementAt(index) == _repeatEveryMinutes ? Colors.white : Colors.black),),
                                  Opacity(
                                    opacity: 0,
                                    child: radioButton
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ) : Container(),
              SizedBox(
                height: screenHeight * .1,
              ),
              Center(
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
                child: isCurrentColor ? Icon(LineAwesomeIcons.check, color: Colors.white) : Text(""),
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
      startedTime: Task.time24Format(_time.format(context)),
      repeatDays: _repeatWeekdays,
      repeatEvery: _isRepeatEvery && _repeatEveryHours + _repeatEveryMinutes > 0 ? Task.repeatEveryToString(Duration(hours: _repeatEveryHours, minutes: _repeatEveryMinutes)) : null,
      type: TASK_HABIT_TYPE,
    );
  }
}