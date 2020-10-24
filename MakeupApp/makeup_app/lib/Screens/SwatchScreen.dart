import 'package:flutter/material.dart' hide HSVColor;
import '../Widgets/Swatch.dart';
import '../Widgets/StarRating.dart';
import '../Widgets/ColorPicker.dart';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../theme.dart' as theme;
import '../routes.dart' as routes;
import '../globals.dart' as globals;
import '../allSwatchesIO.dart' as IO;
import '../types.dart';
import 'Screen.dart';

class SwatchScreen extends StatefulWidget {
  final int swatch;

  final routes.ScreenRoutes prevScreen;

  SwatchScreen({ this.swatch, this.prevScreen });

  @override
  SwatchScreenState createState() => SwatchScreenState();
}

class SwatchScreenState extends State<SwatchScreen> with ScreenState {
  Swatch _swatch;

  bool _isEditing = false;
  bool _hasChanged = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _swatch = IO.get(widget.swatch);
  }

  @override
  Widget build(BuildContext context) {
    SwatchIcon swatchIcon = SwatchIcon.swatch(_swatch, showInfoBox: false, overrideOnDoubleTap: true, onDoubleTap: (int id) {});
    RGBColor color = _swatch.color;
    String finish = globalWidgets.toTitleCase(_swatch.finish).trimRight();
    String brand = globalWidgets.toTitleCase(_swatch.brand).trimRight();
    String palette = globalWidgets.toTitleCase(_swatch.palette).trimRight();
    String shade = globalWidgets.toTitleCase(_swatch.shade).trimRight();
    Widget divider = Divider(
      color: theme.primaryColorDark,
      height: 17,
      thickness: 1,
      indent: 37,
      endIndent: 37,
    );
    List<String> finishes = ['Matte', 'Satin', 'Shimmer', 'Metallic', 'Glitter'];
    List<String> tags = globals.tags;
    return buildComplete(
      context,
      20,
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  color: theme.iconTextColor,
                  icon: Icon(
                    Icons.arrow_back,
                    size: theme.primaryIconSize,
                  ),
                  onPressed: () {
                    exit();
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  color: theme.iconTextColor,
                  icon: Icon(
                    (_isEditing ? Icons.done : Icons.mode_edit),
                    size: theme.primaryIconSize,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _isEditing = !_isEditing;
                        if(!_isEditing) {
                          IO.editId(_swatch.id, _swatch);
                        }
                      }
                    );
                  },
                ),
              ),
            ],
          ),
          Container(
            height: 150,
            margin: EdgeInsets.only(top: 20, bottom: 50),
            child: swatchIcon,
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                getColorField('Color', color, (RGBColor value) { _swatch.color = value; onChange(true); }),
                getDropdownField('Finish', finishes, finish, (String value) { _swatch.finish = value; onChange(true); }),
                getTextField('Brand', brand, (String value) { _swatch.brand = value; onChange(false); }),
                getTextField('Palette', palette, (String value) { _swatch.palette = value; onChange(false); }),
                getTextField('Shade', shade, (String value) { _swatch.shade = value; onChange(false); }),
                divider,
                getStarField('Rating', _swatch.rating, (int value) { _swatch.rating = value; onChange(false); }),
                divider,
                getChipField('Tags', tags, _swatch.tags, (String value) { tags.add(value); globals.tags = tags; }, (List<String> value) { _swatch.tags = value; onChange(true); }),
                divider,
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: OutlineButton(
                    color: theme.primaryColor,
                    borderSide: BorderSide(
                      color: theme.primaryColorDark,
                    ),
                    onPressed: () async {
                      await IO.removeId(_swatch.id);
                      _hasSaved = true;
                      _hasChanged = true;
                      exit();
                    },
                    child: Text(
                      'Delete Swatch',
                      style: theme.errorText,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getField(double height, String label, Widget child) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 15),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget getTextField(String label, String value, OnStringAction onChange) {
    return getField(
      55,
      label,
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = value,
        textAlign: TextAlign.left,
        onChanged: onChange,
        enabled: _isEditing,
        decoration: InputDecoration(
          fillColor: _isEditing ? theme.primaryColor : theme.bgColor,
          filled: true,
          contentPadding:  EdgeInsets.symmetric(horizontal: 12),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.bgColor,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget getColorField(String label, RGBColor color, OnRGBColorAction onChange) {
    String colorName = globalWidgets.toTitleCase(getColorName(_swatch.color)).trimRight();
    Widget child = Row(
      children: <Widget>[
        Text(
          colorName,
          style: theme.primaryTextPrimary,
          textAlign: TextAlign.left,
        ),
        if(_isEditing) IconButton(
          padding: EdgeInsets.only(left: 12, bottom: 70),
          alignment: Alignment.topLeft,
          icon: Icon(
            Icons.colorize,
            size: theme.secondaryIconSize,
          ),
          onPressed: () {
            globalWidgets.openDialog(
              context,
              (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * 0.4) - 15),
                  child: Dialog(
                    insetPadding: EdgeInsets.symmetric(horizontal: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.height * 0.4) + 30,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(bottom: 30),
                              alignment: Alignment.topLeft,
                              child: ColorPicker(
                                btnText: 'Save',
                                initialColor: RGBtoHSV(_swatch.color),
                                onEnter: (double hue, double saturation, double value) {
                                  onChange(HSVtoRGB(HSVColor(hue, saturation, value)));
                                  //doesn't use navigation because is popping an Dialog
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          },
        ),
      ],
    );
    return getField(
      55,
      label,
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isEditing ? theme.primaryColor : theme.bgColor,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: _isEditing ? theme.primaryColorDark : theme.bgColor,
              width: 1.0,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget getDropdownField(String label, List<String> options, String value, OnStringAction onChange) {
    return getField(
      55,
      label,
      Container(
        padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isEditing ? theme.primaryColor : theme.bgColor,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: _isEditing ? theme.primaryColorDark : theme.bgColor,
              width: 1.0,
            ),
          ),
        ),
        child: DropdownButton<String>(
          disabledHint: Text('$value', style: theme.primaryTextPrimary),
          isDense: true,
          style: theme.primaryTextPrimary,
          value: value,
          onChanged: !_isEditing ? null : (String value) {
            if(_isEditing) {
              onChange(value);
            }
          },
          icon: null,
          iconSize: 0,
          underline: Container(),
          items: options.map(
            (String val) {
              return DropdownMenuItem(
                value: val,
                child: Text('$val', style: theme.primaryTextPrimary),
              );
            }
          ).toList(),
        ),
      ),
    );
  }

  Widget getStarField(String label, int value, OnIntAction onChange) {
    return Column(
      children: <Widget> [
        Container(
          height: 55,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Text(
            '$label: $value/10',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 50,
          padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: StarRating(
            starCount: 10,
            starSize: 35,
            rating: value,
            onChange: (int rating) {
              if(_isEditing) {
                setState(() { onChange(rating); });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget getChipField(String label, List<String> options, List<String> values, OnStringAction onAddOption, OnStringListAction onChange) {
    List<Widget> widgets = [];
    for(int i = 0; i < options.length; i++) {
      if(options[i] == '') {
        continue;
      }
      if(!_isEditing && !values.contains(options[i])) {
        continue;
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text(options[i], style: theme.primaryTextSecondary),
          selected: values.contains(options[i]),
          onSelected: (bool selected) {
            if(_isEditing) {
              if(selected) {
                values.add(options[i]);
              } else {
                values.remove(options[i]);
              }
              onChange(values);
            }
          },
        ),
      );
      widgets.add(
        SizedBox(
          width: 10,
        ),
      );
    }
    if(_isEditing) {
      widgets.add(
        ActionChip(
          label: Icon(
            Icons.add,
            size: 15,
            color: theme.iconTextColor,
          ),
          onPressed: () {
            if(_isEditing) {
              globalWidgets.openTextDialog(
                context,
                'Enter new tag:',
                'You must enter a tag.',
                'Add',
                (String value) {
                  onAddOption(value);
                  values.add(value);
                  onChange(values);
                }
              );
            }
          },
        ),
      );
    }
    if(widgets.length == 0) {
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text('None', style: theme.primaryTextSecondary),
          selected: false,
          onSelected: (bool selected) { },
        ),
      );
    }
    return Column(
      children: <Widget> [
        Container(
          height: 55,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
          child: Wrap(
            children: widgets,
          ),
        ),
      ],
    );
  }

  void onChange(bool shouldSetState) {
    _hasSaved = false;
    _hasChanged = true;
    if(shouldSetState) {
      setState(() {});
    }
  }

  void exit() async {
    await onExit();
    navigation.pop(context, _hasChanged);
  }

  @override
  void onExit() async {
    super.onExit();
    if(_hasChanged && !_hasSaved) {
      await IO.editId(_swatch.id, _swatch);
    }
  }

  @override
  void onHorizontalDragEnd(BuildContext context, DragEndDetails drag) {
    exit();
  }
}
