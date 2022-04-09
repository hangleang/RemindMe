
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Error404 extends StatelessWidget {

  final String text;
  Error404({this.text = ""});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final bgColor = Theme.of(context).backgroundColor;
    // final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(textTheme.bodyText1.fontSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: screenWidth * .8,
              child: Lottie.asset('assets/animations/cat.json')
            ),
            Text(text, style: textTheme.button, textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}