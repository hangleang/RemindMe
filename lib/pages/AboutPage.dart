import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
            Text(tr('about'), style: textTheme.headline6.copyWith(color: Colors.black), textAlign: TextAlign.center,),
            Padding(padding: EdgeInsets.only(left: 10, right: 10), child:
              Text("Google LLC is an United States based multinational technology company that specializes in Internet-related services and products, which include online advertising technologies, a search engine, cloud computing, software, and hardware.", 
                style: textTheme.bodyText1.copyWith(color: Colors.black), textAlign: TextAlign.justify),
            )
          ],
        )
        
      )
    );
  }
}