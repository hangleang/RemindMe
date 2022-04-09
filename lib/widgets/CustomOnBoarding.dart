import 'package:codenova_reminders/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class CustomOnBoarding extends StatefulWidget {
  @override
  _CustomOnBoardingState createState() => _CustomOnBoardingState();
}

class _CustomOnBoardingState extends State<CustomOnBoarding> {
  PageController _pageController;
  int _numPage = 3;
  int _currentPage;

  List<Widget> _buildPageIndicators() {
    List<Widget> res = [];
    for(int i = 0; i < _numPage; i++) 
      res.add(i == _currentPage ? _indicator(true) : _indicator(false));
    return res;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(microseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.black26,
        borderRadius: BorderRadius.all(Radius.circular(12.0))
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: THEMES.first
            )
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: textTheme.headline6.fontSize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        if (_pageController.hasClients) 
                          _pageController.animateToPage(
                            _numPage - 1,
                            duration: Duration(microseconds: 500), 
                            curve: Curves.ease
                          );
                      });
                    }, 
                    child: Text("រំលង", style: textTheme.bodyText1,)
                  ),
                ),
                Container(
                  height: screenHeight * .7,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (page) => {
                      setState(() {
                        _currentPage = page;
                      })
                    },
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/images/welcome.png") 
                          ),
                          Text("សូមស្វាគមន៍", style: textTheme.headline5,),
                          Text("Welcome to Reminders App", style: textTheme.bodyText1,)
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/images/plan.png") 
                          ),
                          Text("អ្នកគ្រប់គ្រងភារកិច្ច", style: textTheme.headline5,),
                          Text("Task Management", style: textTheme.bodyText1,)
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/images/time-management.png") 
                          ),
                          Text("អ្នកគ្រប់គ្រងពេលវេលា", style: textTheme.headline5,),
                          Text("Time Management", style: textTheme.bodyText1,)
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicators(),
                ),
                _currentPage != _numPage - 1 ?
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomRight,
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          if (_pageController.hasClients) 
                            _pageController.animateToPage(
                              ++_currentPage,
                              duration: Duration(microseconds: 500), 
                              curve: Curves.ease
                            );  
                        });
                      }, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("បន្ទាប់", style: textTheme.bodyText1,),
                          SizedBox(width: 10,),
                          Icon(
                            LineAwesomeIcons.angle_right,  
                            color: Colors.white,
                          )
                        ],
                      )
                    ),
                  )
                ) : Container()
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPage - 1 ? GestureDetector(
        onTap: () => print("ចាប់ផ្តើម"),
        child: Container(
          height: textTheme.headline1.fontSize,
          width: double.infinity,
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(textTheme.subtitle1.fontSize),
              child: Text(
                "ចាប់ផ្តើម",
                style: textTheme.subtitle1
              ),
            ),
          ),
        ),
      )
    : Text(""),
    );
  }
}