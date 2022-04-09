import 'package:codenova_reminders/constants/constants.dart';
import 'package:codenova_reminders/pages/UserInfoPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).accentColor;

    return Scaffold(
      body: Center(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "សូមស្វាគមន៍",
              image: Center(
                child: Image.asset("assets/images/welcome.png"),
              ),
              body: "Welcome to " + APP_NAME + " App",
              decoration: PageDecoration(
                titleTextStyle: textTheme.headline6.copyWith(color: Colors.white),
                bodyTextStyle: textTheme.bodyText1.copyWith(color: Colors.white, fontFamily: "ProductSans"),
                boxDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accentColor, primaryColor]
                  )
                ),
              )
            ),
            PageViewModel(
              title: "អ្នកគ្រប់គ្រងកិច្ចការ",
              body: "Task Management",
              image: Center(
                child: Image.asset("assets/images/plan.png"),
              ),
              decoration: PageDecoration(
                titleTextStyle: textTheme.headline6.copyWith(color: Colors.white),
                bodyTextStyle: textTheme.bodyText1.copyWith(color: Colors.white),
                boxDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accentColor, primaryColor]
                  )
                ),
              )
            ),
            PageViewModel(
              title: "អ្នកគ្រប់គ្រងពេលវេលា",
              body: "Time Management",
              image: Center(
                child: Image.asset("assets/images/time-management.png"),
              ),
              decoration: PageDecoration(
                titleTextStyle: textTheme.headline6.copyWith(color: Colors.white),
                bodyTextStyle: textTheme.bodyText1.copyWith(color: Colors.white),
                boxDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accentColor, primaryColor]
                  )
                ),
              ), 
            ),
          ],
          onDone: () => {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserInfoPage()))
          },
          showSkipButton: true,
          showNextButton: true,
          skip: Text(tr('skip'), style: textTheme.bodyText1.copyWith(color: Colors.white),),
          next: Text(tr('next'), style: textTheme.bodyText1.copyWith(color: Colors.white),),
          done: Text(tr('done'), style: textTheme.bodyText1.copyWith(color: Colors.white)),
          dotsDecorator: DotsDecorator(
            size: Size.square(10.0),
            activeSize: Size(20.0, 10.0),
            activeColor: Colors.white,
            color: Colors.black26,
            spacing: EdgeInsets.symmetric(horizontal: 5.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0)
            )
          ),
        ),
      )
    );
  }
}