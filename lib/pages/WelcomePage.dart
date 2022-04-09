import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/pages/OnBoardingPage.dart';
import 'package:codenova_reminders/widgets/CustomListTile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class WelcomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).accentColor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentColor, primaryColor]
          )
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(textTheme.headline5.fontSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                Text(APP_NAME, style: textTheme.headline3.copyWith(color: Colors.white)),
                Text(tr('appDesc'), style: textTheme.bodyText1.copyWith(color: Colors.white),),
                Spacer(),
                Column(
                  children: supportedLocales.map((Locale locale) => CustomListTile(
                    onTap: () => context.locale = locale,
                    leading: CircleAvatar(
                      backgroundImage: AssetImage("assets/images/${locale.languageCode}_flag.png"),
                    ),
                    title: Text(tr("${locale.languageCode}Lang"), style: textTheme.bodyText1,),
                    trailing: context.locale == locale ? Icon(LineAwesomeIcons.check_circle, size: textTheme.headline5.fontSize,) : null,
                    padding: textTheme.caption.fontSize * 2 / 3,
                  )).toList(),
                ),
                FlatButton(
                  onPressed: () => {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OnBoardingPage()))
                  }, 
                  child: Text(tr('letsTry'), style: textTheme.bodyText1.copyWith(color: Colors.white)),
                  padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}