import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Text text;
  final Color textColor;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const GradientButton({
    Key key,
    @required this.text,
    this.gradient,
    this.textColor,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FlatButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      textColor: textColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(height / 2)),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: onPressed != null ? gradient : LinearGradient(colors: [Colors.black12, Colors.black26]), 
          borderRadius: BorderRadius.all(Radius.circular(height / 2)),
        ),
        child: Center(child: text)
      ),
    );
  }
}