import 'package:flutter/material.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import '../globals.dart' as globals;
import '../Widgets/SizedSafeArea.dart';
import '../theme.dart' as theme;
import '../navigation.dart' as navigation;
import '../routes.dart' as routes;

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
                  child: Text('Tutorial', style: theme.primaryTextBold),
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
              'Skip',
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
        'First, click on the plus button to add your palettes. The screen will have more directions if you press the help icon in the top left corner.\n\n'
        'Once you\'ve finished, you can return to the "All Swatches" screen and scroll through all the added swatches.',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen1() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        'Tap on a swatch to get information about, such as the color, finish, brand, palette, and shade name, if entered.\n\n'
        'Click on the "More..." button to see more information about it. That screen will also allow you to change any information about, such as the tags and rating. You can also delete a swatch from there.',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen2() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        'Double tap on a swatch to add it to "Today\'s Look."\n\n'
        'Once you add, you will see the swatch appear in the bottommost bar. You can double tap on the bar to open the full look screen. On this screen you can save the look or clear it. You can also edit by adding or removing swatches. That screen will have more directions if you press the help icon in the top left corner.\n\n'
        'You will also see another bar open with recommended swatches from your collection to add to your look. You can interact with them the same way you would any other swatch.',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen3() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        'Click on the menu icon in top left to open the navigation to all the other menus.\n\n'
        '"All Swatches" is the screen you have currently been on.\n\n'
        '"Saved Looks" has all the looks that you\'ve saved from "Today\'s Look. Tap or double tap on the looks to open them. That screen will have more directions if you press the help icon in the top left corner."\n\n'
        '"Color Wheel" allows you to find the nearest swatch to the color you choose on a color wheel. This is helpful if you may be copying a face chart or have a specific color in mind. The screen will have more directions if you press the help icon in the top left corner.',
        style: theme.primaryTextPrimary,
      ),
    );
  }

  Widget getScreen4() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
         '"Palette Scanner" can be used to compare other palettes to your existing collection. For example, when shopping, you can take a picture of a palette and compare it to your collection to see if you want to buy it. Or when recreating a look, you can find a picture of the original palettes and compare dupes in your collection. The screen will have more directions if you press the help icon in the top left corner.\n\n'
        '"Settings" has all the settings for the app. You can also find this tutorial again if you press the help button there. If you wish to report any bugs or request a feature, you can do so there.',
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
