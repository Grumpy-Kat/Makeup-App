import 'package:flutter/material.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import '../globals.dart' as globals;
import '../Widgets/SizedSafeArea.dart';
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;
import '../localizationIO.dart';

class TutorialScreen extends StatefulWidget {
  @override
  TutorialScreenState createState() => TutorialScreenState();
}

class TutorialScreenState extends State<TutorialScreen> {
  IndexController _controller = IndexController();

  int _curr = 0;
  int _count = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.bgColor,
      resizeToAvoidBottomInset: false,
      body: SizedSafeArea(
        builder: (context, screenSize) {
          return Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  color: theme.primaryColor,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20, right: 20, top: 3),
                  child: Text('${getString('screen_tutorial')}', style: theme.primaryTextBold),
                ),
              ),
              Expanded(
                flex: 8,
                child: TransformerPageView(
                  pageSnapping: true,
                  itemCount: _count + 1,
                  index: _curr,
                  onPageChanged: (int i) {
                    setState(() {
                      this._curr = i;
                    });
                    if(_curr == _count) {
                      onFinished();
                    }
                  },
                  loop: false,
                  controller: _controller,
                  transformer: PageTransformerBuilder(
                    builder: (Widget child, TransformInfo info) {
                      Widget child;
                      switch(_curr) {
                        case 0:
                          child = getScreen0();
                          break;
                        case 1:
                          child = getScreen1();
                          break;
                        case 2:
                          child = getScreen2();
                          break;
                        case 3:
                          child = getScreen3();
                          break;
                        case 4:
                          child = getScreen4();
                          break;
                        default:
                          child =  Container();
                          break;
                      }
                      return ParallaxContainer(
                        position: info.position,
                        translationFactor: 300.0,
                        child: child,
                      );
                    }
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: getNavigation(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget getNavigation() {
    List<Widget> row = [];
    for(int i = 0; i < _count; i++) {
      row.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            (i == _curr) ? Icons.radio_button_on : Icons.radio_button_off,
            size: theme.secondaryIconSize,
            color: theme.secondaryTextColor,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: FlatButton(
            onPressed: onFinished,
            child: Text(
              getString('tutorial_skip'),
              style: theme.primaryTextSecondary,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            children: row,
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: FlatButton(
            onPressed: () {
              setState(() {
                _controller.next(animation: true);
                this._curr++;
              });
            },
            child: Icon(
              Icons.arrow_forward_ios,
              size: theme.tertiaryIconSize,
              color: theme.tertiaryTextColor,
            ),
          ),
        ),
      ]
    );
  }

  Widget getScreen0() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        '${getString('tutorial_screen0_0')}\n\n'
        '${getString('tutorial_screen0_1')}',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen1() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        '${getString('tutorial_screen1_0')}\n\n'
        '${getString('tutorial_screen1_1')}',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen2() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        '${getString('tutorial_screen2_0')}\n\n'
        '${getString('tutorial_screen2_1')}\n\n'
        '${getString('tutorial_screen2_2')}',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen3() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        '${getString('tutorial_screen3_0')}\n\n'
        '${getString('tutorial_screen3_1')}\n\n'
        '${getString('tutorial_screen3_2')}\n\n'
        '${getString('tutorial_screen3_3')}',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen4() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        '${getString('tutorial_screen4_0')}\n\n'
        '${getString('tutorial_screen4_1')}',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  void onFinished() {
    if(globals.hasDoneTutorial) {
      //already finished tutorial, most likely coming from settings page
      navigation.pop(context, false);
    } else {
      //first time finishing tutorial, new user
      navigation.pushReplacement(
        context,
        Offset(1, 0),
        routes.ScreenRoutes.AllSwatchesScreen,
        routes.routes['/allSwatchesScreen'](context),
      );
    }
    globals.hasDoneTutorial = true;
  }
}
