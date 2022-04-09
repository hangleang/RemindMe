import 'dart:ui';
import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/pages/AboutPage.dart';
import 'package:codenova_reminders/pages/ContactPage.dart';
import 'package:codenova_reminders/themes/themes.dart';
import 'package:codenova_reminders/widgets/CustomListTile.dart';
import 'package:codenova_reminders/widgets/CustomTextField.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:share_it/share_it.dart';
import 'dart:io' show Platform;

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  SharedPreferences prefs;
  TextEditingController _nicknameController;
  PageController _themeController;
  bool isEditing;
  int langIndex;
  String nickName;
  double _currentTheme = 0;
  String platformOS = 'android';
  String playStoreLink = 'http://codenovative.com/';
  String appStoreLink = 'http://codenovative.com/';
  String shareLink = '';

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    isEditing = false;
    nickName = "";
    _nicknameController = TextEditingController();
    fetchNickName(); 
    // fetchThemeIndex();
    _themeController = PageController(initialPage: 0, viewportFraction: 1/3);
    _themeController.addListener(() {
      setState(() {
        _currentTheme = _themeController.page == null ? 0 : _themeController.page;
      });
    });

    shareLink = playStoreLink;
    if (Platform.isIOS) {
      shareLink = appStoreLink;
    }

  }


  Future fetchNickName() async {
    prefs = await SharedPreferences.getInstance();
    if(mounted)
      setState(() {
        nickName = prefs.getString('nickname');
        _nicknameController.text = nickName;
      });
  }

  // Future fetchThemeIndex() async {
  //   prefs = await SharedPreferences.getInstance();
  //     setState(() {
  //       _currentTheme = double.parse(prefs.getString('themeID'));
  //     });
  // }

  Future setNewNickname(String newNickname) async {
    if(mounted && newNickname.trim() != "")
      setState(() {
        nickName = newNickname;
      });
    
    prefs = await SharedPreferences.getInstance();
    prefs.setString("nickname", nickName);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).accentColor;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentColor, primaryColor]
          )
        ),
        child: ListView(
          padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
          children: <Widget>[
            SizedBox(height: textTheme.headline6.fontSize,),
            // Spacer(flex: 3,),
            Text(APP_NAME, style: textTheme.headline3.copyWith(color: Colors.white), textAlign: TextAlign.center,),
            SizedBox(height: textTheme.headline6.fontSize,),
            // Spacer(flex: 3,),
            CustomListTile(
              leading: Icon(LineAwesomeIcons.user, size: 38),
              title: isEditing ? CustomTextField(
                controller: _nicknameController,
                onChanged: (value) => {
                  setState(() {
                    _nicknameController.text = value;
                  })
                },
                onSubmitted: (value) => setNewNickname(value),
                contentPadding: 8.0,
              ) : Text(nickName, style: textTheme.bodyText1,),
              trailing: IconButton(
                icon: Icon(isEditing ? LineAwesomeIcons.check_circle : LineAwesomeIcons.pencil, size: textTheme.headline6.fontSize,), 
                tooltip: isEditing ? tr('save') : tr('edit'),
                onPressed: _nicknameController.text.trim() == "" ? null :
                  () async {
                    setState(() => isEditing = !isEditing);
                    if(!isEditing) {
                      await setNewNickname(_nicknameController.text);
                    }
                  }
              ),
              padding: textTheme.bodyText2.fontSize
            ),
            SizedBox(height: textTheme.bodyText1.fontSize),
            CustomListTile(
              onTap: () async {
                Locale newLocale = await showBarModalBottomSheet<Locale>(
                  context: context, 
                  barrierColor: Colors.black38,
                  builder: (context, controller) => _buildListofAddTask(context),
                );

                if(newLocale != null)
                  context.locale = newLocale;
              },
              leading: Icon(LineAwesomeIcons.globe, size: 38,),
              title: Text(tr('lang'), style: textTheme.bodyText1,),
              subtitle: Text(context.locale == supportedLocales.first ? tr('kmLang') : tr('enLang'), style: textTheme.bodyText2,),
              trailing: Icon(LineAwesomeIcons.angle_right),
            ),
            SizedBox(height: textTheme.bodyText1.fontSize),
            CustomListTile(
              onTap: () async {
                await showBarModalBottomSheet(
                  context: context,
                  // topRadius: Radius.circular(textTheme.headline6.fontSize),
                  duration: Duration(milliseconds: 500),
                  elevation: 27,
                  barrierColor: Theme.of(context).primaryColor,
                  builder: (context, scrollController) => ContactPage(),
                );
              },
              leading: Icon(LineAwesomeIcons.phone, size: 38),
              title: Text(tr('contact'), style: textTheme.bodyText1,),
              trailing: Icon(LineAwesomeIcons.angle_right),
            ),
            SizedBox(height: textTheme.bodyText1.fontSize),
            CustomListTile(
              onTap: () async {},
              leading: Icon(LineAwesomeIcons.question_circle, size: 38),
              title: Text(tr('help'), style: textTheme.bodyText1,),
              trailing: Icon(LineAwesomeIcons.angle_right),
            ),
            SizedBox(height: textTheme.bodyText1.fontSize),
            CustomListTile(
              onTap: () async {
                await showBarModalBottomSheet(
                  context: context,
                  // topRadius: Radius.circular(textTheme.headline6.fontSize),
                  duration: Duration(milliseconds: 500),
                  elevation: 27,
                  barrierColor: Theme.of(context).primaryColor,
                  builder: (context, scrollController) => AboutPage(),
                );
              },
              leading: Icon(LineAwesomeIcons.info_circle, size: 38),
              title: Text(tr('about'), style: textTheme.bodyText1,),
              trailing: Icon(LineAwesomeIcons.angle_right),
            ),
            SizedBox(height: textTheme.bodyText1.fontSize),
            CustomListTile(
              onTap: () async {
                ShareIt.link(url: shareLink, androidSheetTitle: APP_NAME);
              },
              leading: Icon(LineAwesomeIcons.share_alt, size: 38),
              title: Text(tr('share'), style: textTheme.bodyText1,),
              trailing: Icon(LineAwesomeIcons.angle_right),
            ),
            // SizedBox(height: textTheme.bodyText1.fontSize),
            // CustomListTile(
            //   title: Text(tr('darkMode'), style: textTheme.bodyText1),
            //   subtitle: Text(isDarkmode ? tr('enabled') : tr('disabled'), style: textTheme.bodyText2),
            //   trailing: FlutterSwitch(
            //     activeColor: primaryColor,
            //     width: screenWidth * 0.15,
            //     value: isDarkmode,
            //     onToggle: (bool val) {
            //       setState(() {
            //         isDarkmode = val;
            //       });
            //     },
            //   ),              
            // ), 
            SizedBox(height: textTheme.bodyText1.fontSize),
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(textTheme.bodyText1.fontSize)
              ),
              child: PageView(
                controller: _themeController,
                scrollDirection: Axis.horizontal,
                pageSnapping: true,
                children: THEMES.map((e) => _buildThemeAvatar(context, THEMES.indexOf(e))).toList(),
              ),
            ), 
          ],
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

  Widget _buildListofAddTask(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      child: Padding(
        padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: supportedLocales.map((Locale locale) => CustomListTile(
            onTap: () {
              Navigator.pop(context, locale);
            },
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/images/${locale.languageCode}_flag.png"),
            ),
            title: Text(tr("${locale.languageCode}Lang"), style: textTheme.bodyText1,),
            trailing: context.locale == locale ? Icon(LineAwesomeIcons.check_circle, size: textTheme.headline5.fontSize,) : null,
            padding: textTheme.caption.fontSize * 2 / 3,
          )).toList(),
        ),
      ),
    );
  }
}