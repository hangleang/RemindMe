import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final double padding, elevation;
  final Widget leading, title, subtitle, trailing;
  final Color color;
  final Function onTap;

  CustomListTile({this.padding, this.elevation = 7, this.title, this.subtitle, this.leading, this.trailing, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CardTheme cardTheme = Theme.of(context).cardTheme;

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding ?? textTheme.caption.fontSize)
      ),
      child: Container(
        padding: EdgeInsets.all(padding ?? textTheme.caption.fontSize * 2 / 3),
        decoration: BoxDecoration(
          color: color ?? cardTheme.color,
          borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
        ),
        child: ListTile(
          onTap: onTap,
          leading: leading ?? null,
          title: title ?? null,
          subtitle: subtitle ?? null,
          trailing: trailing ?? null,
        )
      ),
    );
  }
}