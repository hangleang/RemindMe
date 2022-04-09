import 'dart:ui';

import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/pages/RootPage.dart';
import 'package:codenova_reminders/themes/themes.dart';
import 'package:codenova_reminders/widgets/CustomTextField.dart';
import 'package:codenova_reminders/widgets/GradientButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  TextEditingController _nicknameController;
  SharedPreferences prefs;
  PageController _themeController;
  double _currentTheme = 0;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _nicknameController.selection = TextSelection.fromPosition(TextPosition(offset: _nicknameController.text.length));
    _themeController = PageController(initialPage: 0, viewportFraction: 1/3);
    _themeController.addListener(() {
      setState(() {
        _currentTheme = _themeController.page == null ? 0 : _themeController.page;
      });
    });
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
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accentColor, primaryColor]
            )
          ),
          child: Padding(
            padding: EdgeInsets.all(textTheme.headline6.fontSize),
            child: Column(
              children: <Widget>[   
                Spacer(flex: 7,),
                // SizedBox(height: textTheme.headline3.fontSize,),
                Text(APP_NAME, style: textTheme.headline3.copyWith(color: Colors.white), textAlign: TextAlign.center,),
                Spacer(flex: 3,),
                // SizedBox(height: textTheme.headline6.fontSize,),
                Text(tr('niceToMeet'), style: textTheme.bodyText1.copyWith(color: Colors.white), textAlign: TextAlign.center,),
                SizedBox(height: textTheme.bodyText1.fontSize,),
                CustomTextField(
                  controller: _nicknameController,
                  hintText: tr('urNickname') + "...",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyText1.copyWith(color: Colors.white),
                  hintStyle: textTheme.bodyText1.copyWith(color: Colors.white),
                  showCounter: true,
                  showCursor: true,
                  maxLength: 27,
                  onChanged: (value) => {
                    setState(() {
                      _nicknameController.text = value;
                    })
                  },
                  onSubmitted: (value) async => await saveNickname(),
                ),
                Expanded(
                  flex: 14,
                  child: Container(
                    alignment: Alignment.center,
                    child: PageView(
                      controller: _themeController,
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                      children: THEMES.map((e) => _buildThemeAvatar(context, THEMES.indexOf(e))).toList(),
                    ),
                  ),
                ),
                GradientButton(
                  onPressed: _nicknameController.text.trim() == "" ? null : () async {
                    await saveNickname();
                    Navigator.of(context).pushReplacement(MaterialWithModalsPageRoute(builder: (context) => RootPage()));
                  }, 
                  width: screenWidth * .8,
                  height: screenHeight * .1,
                  text: Text(tr('done'), style: textTheme.subtitle1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                  gradient: LinearGradient(colors: [accentColor, primaryColor]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeAvatar(BuildContext context, int index) {
    // final TextTheme textTheme = Theme.of(context).textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth / 3,
      child: Center(
        child: GestureDetector(
          onTap: () {
            _themeController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.ease);
            ThemeProvider.controllerOf(context).setTheme(index.toString());
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70, width: 3),
                    borderRadius: BorderRadius.circular(60),
                    gradient: LinearGradient(
                      begin: Alignment.topRight, end: Alignment.bottomLeft,
                      colors: THEMES.elementAt(index)
                    ),
                  ),
                  child: Container(),
                ),
              ),
              SizedBox(
                height: getThemeAvatarHeight(index, _currentTheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getThemeAvatarHeight(int index, double centerIndex) {
    double minHeight = 40;
    double centerHeight = 70;
    double maxHeight = 100;
    var diff = (centerIndex - index).abs();

    if (index < centerIndex) {
      if (diff > 1) {
        return minHeight;
      }
      return lerpDouble(minHeight, centerHeight, 1 - diff);
    } else {
      if (diff > 1) {
        return maxHeight;
      }
      return lerpDouble(centerHeight, maxHeight, diff);
    }
  }

  Future saveNickname() async {
    prefs = await SharedPreferences.getInstance();
    String nickname = _nicknameController.text;
    await prefs.setString('nickname', nickname);
  }

  // Future<int> getThemeID() async {
  //   prefs = await SharedPreferences.getInstance();
  //   String themeID = prefs.getString('themeID');
  //   return themeID != "" ? int.parse(themeID) : 0;
  // }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}