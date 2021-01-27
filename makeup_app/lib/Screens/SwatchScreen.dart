import 'package:flutter/material.dart' hide HSVColor;
import 'package:flutter/services.dart';
import '../Widgets/Swatch.dart';
import '../Widgets/StarRating.dart';
import '../Widgets/ColorPicker.dart';
import '../ColorMath/ColorProcessing.dart';
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../allSwatchesIO.dart' as IO;
import '../types.dart';
import '../localizationIO.dart';
import 'Screen.dart';

class SwatchScreen extends StatefulWidget {
  final int swatch;

  SwatchScreen({ this.swatch });

  @override
  SwatchScreenState createState() => SwatchScreenState();
}

class SwatchScreenState extends State<SwatchScreen> with ScreenState {
  static Swatch _swatch;

  bool _isEditing = false;
  bool _hasChanged = false;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    //get swatch from id
    if(widget.swatch != null) {
      _swatch = IO.get(widget.swatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    //divider to mark new section
    Widget divider = Divider(
      color: theme.primaryColorDark,
      height: 17,
      thickness: 1,
      indent: 37,
      endIndent: 37,
    );
    //all swatch data
    SwatchIcon swatchIcon = SwatchIcon.swatch(_swatch, showInfoBox: false, overrideOnDoubleTap: true, onDoubleTap: (int id) {});
    RGBColor color = _swatch.color;
    String finish = _swatch.finish;
    String brand = globalWidgets.toTitleCase(_swatch.brand).trimRight();
    String palette = globalWidgets.toTitleCase(_swatch.palette).trimRight();
    String shade = globalWidgets.toTitleCase(_swatch.shade).trimRight();
    double weight = _swatch.weight;
    double price = _swatch.price;
    //various options
    List<String> finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
    List<String> tags = globals.tags;
    return buildComplete(
      context,
      getString('screen_swatch'),
      20,
      //back button
      leftBar: globalWidgets.getBackButton (() => exit()),
      //edit button
      rightBar: [
        IconButton(
          constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
          icon: Icon(
            Icons.library_add,
            size: theme.primaryIconSize,
            color: theme.iconTextColor,
          ),
          onPressed: () {
            if(!globals.currSwatches.currSwatches.contains(this)) {
              globals.currSwatches.add(_swatch.id);
            }
          },
        ),
        IconButton(
          constraints: BoxConstraints.tight(Size.fromWidth(theme.primaryIconSize + 15)),
          icon: Icon(
            (_isEditing ? Icons.done : Icons.mode_edit),
            size: theme.primaryIconSize,
            color: theme.iconTextColor,
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
      ],
      body: Column(
        children: <Widget>[
          //swatch preview
          Container(
            height: 150,
            margin: EdgeInsets.only(top: 20, bottom: 50),
            child: swatchIcon,
          ),
          //all fields
          Expanded(
            child: ListView(
              children: <Widget>[
                //color
                getColorField('${getString('swatch_color')}', color, (RGBColor value) { _swatch.color = value; onChange(true); }),
                //finish
                getDropdownField('${getString('swatch_finish')}', finishes, finish, (String value) { _swatch.finish = value; onChange(true); }),
                //brand name
                getTextField('${getString('swatch_brand')}', brand, (String value) { _swatch.brand = value; onChange(false); }),
                //palette name
                getTextField('${getString('swatch_palette')}', palette, (String value) { _swatch.palette = value; onChange(false); }),
                //shade name
                getTextField('${getString('swatch_shade')}', shade, (String value) { _swatch.shade = value; onChange(false); }),
                //weight
                getNumField('${getString('swatch_weight')}', weight, (double value) { _swatch.weight = value; onChange(false); }),
                //price
                getNumField('${getString('swatch_price')}', price, (double value) { _swatch.price = value; onChange(false); }),
                divider,
                //rating
                getStarField('${getString('swatch_rating')}', _swatch.rating, (int value) { _swatch.rating = value; onChange(false); }),
                divider,
                //tags
                getChipField('${getString('swatch_tags')}', tags, _swatch.tags, (String value) { tags.add(value); globals.tags = tags; }, (List<String> value) { _swatch.tags = value; onChange(true); }),
                divider,
                //delete button
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: OutlineButton(
                    color: theme.bgColor,
                    borderSide: BorderSide(
                      color: theme.primaryColorDark,
                    ),
                    onPressed: () async {
                      await globalWidgets.openTwoButtonDialog(
                        context,
                        getString('swatch_deleteWarning'),
                        () async {
                          //action determined by screen that uses it
                          await IO.removeId(_swatch.id);
                          _hasSaved = true;
                          _hasChanged = true;
                          exit();
                        },
                        () { },
                      );
                    },
                    child: Text(
                      '${getString('swatch_delete')}',
                      style: theme.errorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //generic field with just a label and input on opposite horizontal sides
  //utilized by other varieties of fields
  //everything displays as plain text when not editing, but is more unique during editing
  Widget getField(double height, String label, Widget child) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
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

  //text field, ex for brand or palette name
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
          fillColor: _isEditing ? theme.primaryColorLight : theme.bgColor,
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

  //double field, ex for weight or price numbers
  Widget getNumField(String label, double value, OnDoubleAction onChange) {
    return getField(
      55,
      label,
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = value.toString(),
        textAlign: TextAlign.left,
        onChanged: (String val) { onChange(double.parse(val)); },
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
        ],
        enabled: _isEditing,
        decoration: InputDecoration(
          fillColor: _isEditing ? theme.primaryColorLight : theme.bgColor,
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

  //color field that displays color name and opens popup to color picker
  Widget getColorField(String label, RGBColor color, OnRGBColorAction onChange) {
    String colorName = globalWidgets.toTitleCase(getString(getColorName(_swatch.color)));
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
                  //need custom dialog due to size constraints to work with positioning of color picker cursor
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
                                btnText: '${getString('save')}',
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
          color: _isEditing ? theme.primaryColorLight : theme.bgColor,
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

  //dropdown field, ex for finish
  Widget getDropdownField(String label, List<String> options, String value, OnStringAction onChange) {
    String valueText = value;
    if(valueText.contains('_')) {
      valueText = getString(valueText);
    }
    return getField(
      55,
      label,
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isEditing ? theme.primaryColorLight : theme.bgColor,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: _isEditing ? theme.primaryColorDark : theme.bgColor,
              width: 1.0,
            ),
          ),
        ),
        child: DropdownButton<String>(
          disabledHint: Text('$valueText', style: theme.primaryTextPrimary),
          isDense: true,
          isExpanded: true,
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
              String text = val;
              if(text.contains('_')) {
                  text = getString(text);
              }
              return DropdownMenuItem(
                value: val,
                child: Text('$text', style: theme.primaryTextPrimary),
              );
            }
          ).toList(),
        ),
      ),
    );
  }

  //star rating field
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

  //many choice selection field with ability to add more choices
  Widget getChipField(String label, List<String> options, List<String> values, OnStringAction onAddOption, OnStringListAction onChange) {
    List<Widget> widgets = [];
    for(int i = 0; i < options.length; i++) {
      if(options[i] == '') {
        continue;
      }
      if(!_isEditing && !values.contains(options[i])) {
        continue;
      }
      String text = options[i];
      if(text.contains('_')) {
        text = getString(text);
      }
      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text(text, style: theme.primaryTextSecondary),
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
                getString('swatch_popupInstructions'),
                getString('swatch_popupError'),
                getString('swatch_popupBtn'),
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
          label: Text('${getString('swatch_none')}', style: theme.primaryTextSecondary),
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
    //update screen and swatch icon if needed, such as with finish or color changes
    //only needed if swatch icon requires visual changes, so is false for something like brand or rating
    if(shouldSetState) {
      setState(() {});
    }
  }

  void exit() async {
    //save data
    await onExit();
    //actually return to previous screen and reload if any changes were made
    navigation.pop(context, _hasChanged);
  }

  @override
  void onExit() async {
    super.onExit();
    //save changes to swatch
    if(_hasChanged && !_hasSaved) {
      await IO.editId(_swatch.id, _swatch);
    }
  }
}