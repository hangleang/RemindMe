import 'package:flutter/material.dart';

class CustomRoundedBox extends StatelessWidget {
  final double padding;
  final Widget child;

  CustomRoundedBox({this.padding, @required this.child});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(padding ?? textTheme.caption.fontSize),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(padding ?? textTheme.caption.fontSize)
      ),
      child: child
    );
  }
}