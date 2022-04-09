import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/pages/RootPage.dart';
import 'package:codenova_reminders/pages/WelcomePage.dart';
import 'package:codenova_reminders/themes/app_themes.dart';
import 'package:codenova_reminders/themes/themes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';

import 'model/ReceivedNotification.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

Future initNotifications() async {
  AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:(id, title, body, payload) async {
      didReceiveLocalNotificationSubject.add(ReceivedNotification(
        id: id, title: title, body: body, payload: payload, createdAt: DateTime.now())
      );
    });
  InitializationSettings initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  await initNotifications();

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: supportedLocales,
      // startLocale: supportedLocales.first,
      fallbackLocale: supportedLocales.last,
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      // onThemeChanged: (oldTheme, newTheme) => _setThemeID(newTheme.id),
      saveThemesOnChange: true,
      loadThemeOnInit: true,
      themes: THEMES.map((e) => AppTheme(
        id: THEMES.indexOf(e).toString(),
        data: AppThemes.lightTheme.copyWith(
          primaryColor: e[1],
          accentColor: e[0]
        ),
        description: THEMES.indexOf(e).toString()
      )).toList(),
      child: ThemeConsumer(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: APP_NAME,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            theme: Theme.of(context),
            home: FutureBuilder<bool>(
              future: haveNickname(),
              builder: (context, snapshot) {
                if(snapshot.hasData) 
                  if(snapshot.data)
                    return RootPage();
                  else
                    return WelcomePage();
                return CircularProgressIndicator();
              },
            ),
          ),
        )
      )
    );
  }

  // _setThemeID(String id) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString("themeID", id);
  // }

  Future<bool> haveNickname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("nickname") != null;
  }
}