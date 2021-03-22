import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/cupertino.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/SwatchList.dart';
import '../Widgets/Look.dart';
import '../ColorMath/ColorLookGeneration.dart';
import '../ColorMath/ColorSorting.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;
import '../allSwatchesIO.dart' as IO;
import '../savedLooksIO.dart' as savedLooksIo;
import '../localizationIO.dart';
import 'Screen.dart';

class RandomizeLookScreen extends StatefulWidget {
  @override
  RandomizeLookScreenState createState() => RandomizeLookScreenState();
}

class RandomizeLookScreenState extends State<RandomizeLookScreen> with ScreenState, SwatchListState {
  List<int> _swatches = [];
  List<SwatchIcon> _swatchIcons = [];
  Future<List<int>> _swatchesFuture;

  SwatchList _swatchList;

  int _numSwatches = 5;
  List<String> _selectedFinishes = [];
  List<String> _selectedColors = [];
  int _type = 0;
  int _subtype = 0;

  List<String> _finishes = [];
  List<String> _colors = [];

  bool hasGeneratedSwatches = false;

  @override
  void initState() {
    super.initState();
    _finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
    _selectedFinishes = _finishes.toList();
    //manually add neutral because internally treated as orange
    _colors = createColorWheel().keys.toList();
    _colors.insert(0, 'neutral');
    _selectedColors = _colors.toList();

    //creates future, mostly to not make something null
    _swatchesFuture = _addSwatches();

    createSwatchList();
  }

  Future<List<int>> _addSwatches() async {
    if(!hasGeneratedSwatches) {
      return [];
    }
    globalWidgets.openLoadingDialog(context);
    //gets all swatches
    List<int> allSwatches = await IO.loadFormatted();
    //converts swatches to ints
    _swatches = IO.findMany(
      //gets the similar swatches
      getRandomLook(
        IO.getMany(allSwatches).toList(), //converts swatch ids to swatches
        _numSwatches,
        _type,
        _subtype,
        _selectedColors.toList(),
        _selectedFinishes.toList(),
      ),
    );
    _swatchIcons.clear();
    for(int i = 0; i < _swatches.length; i++) {
      _swatchIcons.add(SwatchIcon.id(_swatches[i], showInfoBox: true));
    }
    Navigator.pop(context);
    return _swatches;
  }

  @override
  Widget build(BuildContext context) {
    if(hasGeneratedSwatches) {
      init(_swatchList);
      return buildComplete(
        context,
        getString('screen_randomizeLook'),
        5,
        rightBar: [
          //help button
          globalWidgets.getHelpBtn(
            context,
            '${getString('help_randomizeLook_0')}\n\n'
            '${getString('help_randomizeLook_1')}\n\n'
            '${getString('help_randomizeLook_2')}\n\n'
            '${getString('help_randomizeLook_3')}\n\n'
            '${getString('help_randomizeLook_4')}',
          ),
        ],
        body: Column(
          children: <Widget>[
            //return to randomize settings
            FlatButton(
              color: theme.bgColor,
              shape:  Border.all(
                color: theme.primaryColorDark,
                width: 2.0,
              ),
              onPressed: () {
                setState(() {
                  hasGeneratedSwatches = false;
                  createSwatchList();
                });
              },
              child: Text(
                getString('randomizeLook_changeSettings'),
                style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
              ),
            ),
            //generate another look with the same settings
            FlatButton(
              color: theme.bgColor,
              shape:  Border.all(
                color: theme.primaryColorDark,
                width: 2.0,
              ),
              onPressed: () {
                setState(() {
                  _swatchesFuture = _addSwatches();
                });
              },
              child: Text(
                getString('randomizeLook_generateAgain'),
                style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.primaryTextSize, fontFamily: theme.fontFamily),
              ),
            ),
            //save look
            FlatButton(
              color: theme.primaryColorDark,
              onPressed: () {
                globalWidgets.openTextDialog(
                  context,
                  getString('randomizeLook_popupInstructions'),
                  getString('randomizeLook_popupError'),
                  getString('save'),
                  (String value) {
                    globalWidgets.openLoadingDialog(context);
                    Look look = Look(
                      id: '',
                      name: value,
                      swatches: _swatches,
                    );
                    look.name = value;
                    savedLooksIo.save(look).then(
                      (String value) {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              child: Text(
                getString('randomizeLook_save'),
                style: theme.primaryTextPrimary,
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _swatchList.addSwatches,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return buildSwatchList(
                    context,
                    snapshot,
                    _swatchIcons,
                    axis: Axis.vertical,
                    crossAxisCount: 4,
                    padding: 20,
                    spacing: 30,
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return buildComplete(
        context,
        getString('screen_randomizeLook'),
        5,
        rightBar: [
          globalWidgets.getHelpBtn(
            context,
            '${getString('help_randomizeLook_0')}\n\n'
            '${getString('help_randomizeLook_1')}\n\n'
            '${getString('help_randomizeLook_2')}\n\n'
            '${getString('help_randomizeLook_3')}\n\n'
            '${getString('help_randomizeLook_4')}',
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          children: <Widget> [
            getNumSwatchesField(context),
            getFinishField(context),
            getColorField(context),
            getTypeField(context),
            if(_type == 2) getDichromaticSubtypeField(context),
            if(_type == 3) getTrichromaticSubtypeField(context),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 170,
                height: 37,
                child: FlatButton(
                  color: theme.accentColor,
                  onPressed: () {
                    setState(() {
                      //sets future
                      hasGeneratedSwatches = true;
                      createSwatchList();
                      _swatchesFuture = _addSwatches();
                    });
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      getString('randomizeLook_generate'),
                      style: theme.accentTextBold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget getField(String label, Widget child) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 19),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$label: ',
              style: theme.primaryTextSecondary,
              textAlign: TextAlign.left,
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget getNumSwatchesField(BuildContext context) {
    TextStyle unselectedStyle = TextStyle(color: theme.secondaryTextColor, fontSize: 14, fontFamily: theme.fontFamily);
    TextStyle selectedStyle = TextStyle(color: theme.accentTextColor, fontSize: 14, fontFamily: theme.fontFamily);
    return getField(
      '${getString('randomizeLook_swatches')}',
      CupertinoSlidingSegmentedControl<int>(
        groupValue: _numSwatches,
        backgroundColor: theme.primaryColor,
        thumbColor: theme.accentColor,
        onValueChanged: (val) {
          if(val != _numSwatches) {
            setState(() {
              _numSwatches = val;
            });
          }
        },
        children: {
          2: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('2', style: (_numSwatches == 2 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          3: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('3', style: (_numSwatches == 3 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          4: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('4', style: (_numSwatches == 4 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          5: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('5', style: (_numSwatches == 5 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          6: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Text('6', style: (_numSwatches == 6 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          7: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('7', style: (_numSwatches == 7 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          8: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('8', style: (_numSwatches == 8 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
        },
      ),
    );
  }

  Widget getFinishField(BuildContext context) {
    TextStyle style = TextStyle(color: theme.secondaryTextColor, fontSize: 13, fontFamily: theme.fontFamily);
    List<Widget> widgets = [];
    for(int i = 0; i < _finishes.length; i++) {
      if(_finishes[i] == '') {
        continue;
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text('${getString(_finishes[i])}', style: style),
          selected: _selectedFinishes.contains(_finishes[i]),
          onSelected: (bool selected) {
            setState(() {
              if(selected) {
                _selectedFinishes.add(_finishes[i]);
              } else {
                _selectedFinishes.remove(_finishes[i]);
              }
            });
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 5,
        ),
      );
    }
    return getField(
      '${getString('randomizeLook_finishes')}',
      Container(
        alignment: Alignment.center,
        child: Wrap(
          children: widgets,
        ),
      ),
    );
  }

  Widget getColorField(BuildContext context) {
    TextStyle style = TextStyle(color: theme.secondaryTextColor, fontSize: 13, fontFamily: theme.fontFamily);
    List<Widget> widgets = [];
    for(int i = 0; i < _colors.length; i++) {
      if(_colors[i] == '') {
        continue;
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text('${getString('randomizeLook_color_${_colors[i].toLowerCase()}')}', style: style),
          selected: _selectedColors.contains(_colors[i]),
          onSelected: (bool selected) {
            setState(() {
              if(selected) {
                _selectedColors.add(_colors[i]);
              } else {
                _selectedColors.remove(_colors[i]);
              }
            });
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 5,
        ),
      );
    }
    return getField(
      '${getString('randomizeLook_colors')}',
      Container(
        alignment: Alignment.center,
        child: Wrap(
          children: widgets,
        ),
      ),
    );
  }

  Widget getTypeField(BuildContext context) {
    TextStyle unselectedStyle = TextStyle(color: theme.secondaryTextColor, fontSize: 10, fontFamily: theme.fontFamily);
    TextStyle selectedStyle = TextStyle(color: theme.accentTextColor, fontSize: 10, fontFamily: theme.fontFamily);
    return getField(
      '${getString('randomizeLook_type')}',
      CupertinoSlidingSegmentedControl<int>(
        groupValue: _type,
        backgroundColor: theme.primaryColor,
        thumbColor: theme.accentColor,
        onValueChanged: (val) {
          if(val != _type) {
            setState(() {
              _subtype = 0;
              _type = val;
            });
          }
        },
        children: {
          0: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_type_random')}', style: (_type == 0 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          1: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_type_monochromatic')}', style: (_type == 1 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          2: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_type_dichromatic')}', style: (_type == 2 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          3: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_type_trichromatic')}', style: (_type == 3 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
        },
      ),
    );
  }

  Widget getDichromaticSubtypeField(BuildContext context) {
    TextStyle unselectedStyle = TextStyle(color: theme.secondaryTextColor, fontSize: 10, fontFamily: theme.fontFamily);
    TextStyle selectedStyle = TextStyle(color: theme.accentTextColor, fontSize: 10, fontFamily: theme.fontFamily);
    return getField(
      '${getString('randomizeLook_dichromatic')}',
      CupertinoSlidingSegmentedControl<int>(
        groupValue: _subtype,
        backgroundColor: theme.primaryColor,
        thumbColor: theme.accentColor,
        onValueChanged: (val) {
          if(val != _subtype) {
            setState(() {
              _subtype = val;
            });
          }
        },
        children: {
          0: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_dichromatic_random')}', style: (_subtype == 0 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          1: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_dichromatic_analogous')}', style: (_subtype == 1 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          2: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_dichromatic_complementary')}', style: (_subtype == 2 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
        },
      ),
    );
  }

  Widget getTrichromaticSubtypeField(BuildContext context) {
    TextStyle unselectedStyle = TextStyle(color: theme.secondaryTextColor, fontSize: 8, fontFamily: theme.fontFamily);
    TextStyle selectedStyle = TextStyle(color: theme.accentTextColor, fontSize: 8, fontFamily: theme.fontFamily);
    return getField(
      '${getString('randomizeLook_trichromatic')}',
      CupertinoSlidingSegmentedControl<int>(
        groupValue: _subtype,
        backgroundColor: theme.primaryColor,
        thumbColor: theme.accentColor,
        onValueChanged: (val) {
          if(val != _subtype) {
            setState(() {
              _subtype = val;
            });
          }
        },
        children: {
          0: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_trichromatic_random')}', style: (_subtype == 0 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          1: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_trichromatic_analogous')}', style: (_subtype == 1 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          2: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_trichromatic_complementary')}', style: (_subtype == 2 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
          3: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('${getString('randomizeLook_trichromatic_triad')}', style: (_subtype == 3 ? selectedStyle : unselectedStyle), textAlign: TextAlign.center),
          ),
        },
      ),
    );
  }

  void createSwatchList() {
    _swatchList = SwatchList(
      addSwatches: _swatchesFuture,
      orgAddSwatches: _swatchesFuture,
      selectedSwatches: [],
      showInfoBox: true,
      showNoColorsFound: hasGeneratedSwatches,
      showNoFilteredColorsFound: hasGeneratedSwatches,
      showPlus: false,
      showDelete: false,
      showDeleteFiltered: false,
      overrideOnTap: false,
      overrideOnDoubleTap: false,
      showEndDrawer: false,
    );
  }

  @override
  Future<void> editSwatches(String brand, String palette, double weight, double price, int rating, List<String> tags) { return null; }

  @override
  Future<void> deleteSwatches() { return null; }

  @override
  void filterSwatches(filters) { }

  @override
  Future sortAndFilterSwatchesActual() { return null; }

  @override
  Future<List<int>> filterAndSearchSwatchesActual() { return null; }

  @override
  Future<void> searchSwatches(String val) async { }

  @override
  void sortSwatches(val) { }
}
