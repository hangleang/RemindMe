import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final Color primaryColor = Theme.of(context).primaryColor;
    // final Color accentColor = Theme.of(context).accentColor;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        textTheme: textTheme,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LineAwesomeIcons.angle_left), 
          tooltip: tr('back'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [accentColor, primaryColor]
        //   )
        // ),
        child: ListView(
          children: <Widget>[
            Text(tr('contact'), style: textTheme.headline6.copyWith(color: Colors.black), textAlign: TextAlign.center,),
            Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10), 
              child: Text("Phone:", style: textTheme.bodyText1.copyWith(color: Colors.grey[700]), textAlign: TextAlign.left),
            ),
            Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 5), 
              child: Text("855 96 4444 204", style: textTheme.bodyText1.copyWith(color: Colors.black), textAlign: TextAlign.left),
            ),
            Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10), 
              child: Text("Email:", style: textTheme.bodyText1.copyWith(color: Colors.grey[700]), textAlign: TextAlign.left),
            ),
            Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 5), 
              child: Text("codenova.info@gmail.com", style: textTheme.bodyText1.copyWith(color: Colors.black), textAlign: TextAlign.left),
            ),
            Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 10), 
              child: Text("Website:", style: textTheme.bodyText1.copyWith(color: Colors.grey[700]), textAlign: TextAlign.left),
            ),
            Padding(padding: EdgeInsets.only(left: 10, right: 10, top: 5), 
              child: Text("www.codenovative.com", style: textTheme.bodyText1.copyWith(color: Colors.black), textAlign: TextAlign.left),
            )
          ],
        )
        
      )
    );
  }
}