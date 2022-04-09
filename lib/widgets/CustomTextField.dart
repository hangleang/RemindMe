import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle style;
  final String hintText;
  final TextStyle hintStyle;
  final TextInputType textInputType;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final double contentPadding;
  final bool showCounter;
  final bool showCursor;
  final bool readOnly;
  final int maxLength;
  final Function onChanged;
  final Function onSubmitted;

  CustomTextField({@required this.controller, this.style, this.hintText, this.hintStyle, this.textInputType = TextInputType.text, this.textCapitalization = TextCapitalization.words, this.textAlign = TextAlign.start, this.contentPadding, this.showCounter = false, this.showCursor = true, this.readOnly = false, this.maxLength = 255, this.onChanged, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return TextField(
      onChanged: (value) => onChanged(value),
      onSubmitted: (text) => onSubmitted(text),
      cursorColor: primaryColor,
      controller: controller,
      keyboardType: textInputType,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      style: style ?? textTheme.bodyText1,
      showCursor: showCursor,
      readOnly: readOnly,
      // maxLength: maxLength,
      // buildCounter: (context, {currentLength, isFocused, maxLength}) {
      //   if(isFocused && controller.text != "" && showCounter)
      //     return Container(
      //       transform: Matrix4.translationValues(0.0, -90.0, 0.0),
      //       child: DecoratedBox(
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(textTheme.caption.fontSize)
      //         ),
      //         child: Padding(
      //           padding: EdgeInsets.all(textTheme.caption.fontSize / 2),
      //           child: RichText(
      //             text: TextSpan(
      //               style: textTheme.caption,
      //               children: [
      //                 TextSpan(text: currentLength.toString(), style: textTheme.caption.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
      //                 TextSpan(text: "/" + maxLength.toString())
      //               ]
      //             ),
      //           ),
      //         )
      //       ),
      //     );
      //   return Container(
      //     transform: Matrix4.translationValues(0.0, -90.0, 0.0),
      //     child: Text("")
      //   );
      // },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? textTheme.bodyText1,
        contentPadding: EdgeInsets.all(contentPadding ?? textTheme.bodyText2.fontSize),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(style != null ? style.fontSize : textTheme.bodyText1.fontSize),
          borderSide: BorderSide(
            width: 0, 
            style: BorderStyle.none,
          ),
        ),  
      ),
    );
  }
}