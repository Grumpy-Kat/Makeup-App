import 'package:flutter/material.dart' hide HSVColor, OutlineButton, BackButton;
import '../Data/Swatch.dart';
import '../Widgets/SwatchImagesDisplay.dart';
import '../Widgets/StarField.dart';
import '../Widgets/StringField.dart';
import '../Widgets/DoubleField.dart';
import '../Widgets/ColorField.dart';
import '../Widgets/TagsField.dart';
import '../Widgets/DateField.dart';
import '../Widgets/DropdownField.dart';
import '../Widgets/OutlineButton.dart';
import '../Widgets/BackButton.dart';
import '../ColorMath/ColorObjects.dart';
import '../IO/allSwatchesIO.dart' as IO;
import '../IO/localizationIO.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../navigation.dart' as navigation;
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../types.dart';
import 'Screen.dart';

class SwatchScreen extends StatefulWidget {
  final int? swatch;

  SwatchScreen({ this.swatch });

  @override
  SwatchScreenState createState() => SwatchScreenState();
}

class SwatchScreenState extends State<SwatchScreen> with ScreenState {
  static late Swatch _swatch;

  bool _isEditing = false;
  bool _hasChanged = false;
  bool _hasSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    //get swatch from id
    if(widget.swatch != null) {
      _swatch = IO.get(widget.swatch!)!;
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
    RGBColor color = _swatch.color;
    String colorName = _swatch.colorName.trim();
    String finish = _swatch.finish;
    String brand = globalWidgets.toTitleCase(_swatch.brand).trimRight();
    String palette = globalWidgets.toTitleCase(_swatch.palette).trimRight();
    String shade = globalWidgets.toTitleCase(_swatch.shade).trimRight();

    double weight = _swatch.weight;
    double price = _swatch.price;

    DateTime? openDate = _swatch.openDate;
    if(openDate != null) {
      openDate = globalWidgets.removeTime(openDate);
    }
    DateTime? expirationDate = _swatch.expirationDate;
    if(expirationDate != null) {
      expirationDate = globalWidgets.removeTime(expirationDate);
    }

    //various options
    List<String> finishes = ['finish_matte', 'finish_satin', 'finish_shimmer', 'finish_metallic', 'finish_glitter'];
    List<String> tags = globals.tags;

    return buildComplete(
      context,
      getString('screen_swatch'),
      20,
      leftBar: BackButton(onPressed: () => exit()),
      rightBar: [
        IconButton(
          constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
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
          constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
          icon: Icon(
            (_isEditing ? Icons.done : Icons.mode_edit),
            size: theme.primaryIconSize,
            color: theme.iconTextColor,
          ),
          onPressed: () {
            setState(
              () {
                _isEditing = !_isEditing;
                if(!_isEditing && !_isSaving) {
                  _isSaving = true;
                  _hasSaved = true;
                  IO.editId(_swatch.id, _swatch).then((value) { _isSaving = false; });
                }
              }
            );
          },
        ),
      ],
      body: Column(
        children: <Widget>[
          // Swatch preview
          SwatchImagesDisplay(
            isEditing: _isEditing,
            swatch: _swatch,
            onChange: (List<String> value) {
              _swatch.imgIds = value;
              onChange(true);
              if(!_isSaving) {
                _isSaving = true;
                _hasSaved = true;
                IO.editId(_swatch.id, _swatch).then((value) { _isSaving = false; });
              }
            },
          ),

          // All fields
          Expanded(
            child: ListView(
              children: <Widget>[
                // Color
                getColorField(
                  '${getString('swatch_color')}',
                  color,
                  colorName,
                  (RGBColor value) {
                    _swatch.color = value;
                    onChange(true);
                  },
                  (String value) {
                    _swatch.colorName = value.trim();
                    onChange(true);
                  },
                ),

                // Finish
                getDropdownField(
                  '${getString('swatch_finish')}',
                  finishes,
                  finish,
                  (String value) {
                    _swatch.finish = value;
                    onChange(true);
                  },
                ),
                // Brand name
                getTextField(
                  '${getString('swatch_brand')}',
                  brand,
                  (String value) {
                    _swatch.brand = value;
                    onChange(false);
                  },
                ),
                // Palette name
                getTextField(
                  '${getString('swatch_palette')}',
                  palette,
                  (String value) {
                    _swatch.palette = value;
                    onChange(false);
                  },
                ),
                // Shade name
                getTextField(
                  '${getString('swatch_shade')}',
                  shade,
                  (String value) {
                    _swatch.shade = value;
                    onChange(false);
                  },
                ),
                // Weight
                getNumField(
                  '${getString('swatch_weight')}',
                  weight,
                  (double value) {
                    _swatch.weight = value;
                    onChange(false);
                  },
                ),
                // Price
                getNumField(
                  '${getString('swatch_price')}',
                  price,
                  (double value) {
                    _swatch.price = value;
                    onChange(false);
                  },
                ),
                divider,

                const SizedBox(
                  height: 10,
                ),

                // Open date
                getDateField(
                  '${getString('swatch_openDate')}',
                  openDate,
                  null,
                  (DateTime value) {
                    _swatch.openDate = value;
                    onChange(true);
                  },
                ),
                // Expiration date
                getDateField(
                  '${getString('swatch_expirationDate')}',
                  expirationDate,
                  openDate,
                  (DateTime value) {
                    _swatch.expirationDate = value;
                    onChange(true);
                  },
                ),
                divider,

                // Rating
                getStarField(
                  '${getString('swatch_rating')}',
                  _swatch.rating,
                  (int value) {
                    _swatch.rating = value;
                    onChange(false);
                  },
                ),
                divider,

                // Tags
                getTagsField(
                  tags
                ),
                divider,

                // Delete button
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: OutlineButton(
                    bgColor: theme.bgColor,
                    outlineColor: theme.primaryColorDark,
                    onPressed: () async {
                      await globalWidgets.openTwoButtonDialog(
                        context,
                        getString('swatch_deleteWarning'),
                        () async {
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

  // Text field, ex for brand or palette name
  Widget getTextField(String label, String? value, OnStringAction onChange) {
    return StringField(
      label: label,
      value: value,
      onChange: onChange,
      outerPadding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      isEditing: _isEditing,
    );
  }

  // Double field, ex for weight or price numbers
  Widget getNumField(String label, double value, OnDoubleAction onChange) {
    return DoubleField(
      label: label,
      value: value,
      onChange: onChange,
      outerPadding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
    );
  }

  // Color field that displays color name and opens popup to color picker
  Widget getColorField(String label, RGBColor color, String colorNameOrg, OnRGBColorAction onChange, OnStringAction onNameChange) {
    return ColorField(
      label: label,
      color: color,
      colorNameOrg: colorNameOrg,
      onChange: onChange,
      onNameChange: onNameChange,
      isEditing: _isEditing,
    );
  }

  // Dropdown field, ex for finish
  Widget getDropdownField(String label, List<String> options, String value, OnStringAction onChange) {
    return DropdownField(
      label: label,
      options: options,
      value: value,
      onChange: onChange,
      isEditing: _isEditing,
    );
  }

  // Date field that opens popup to calendar
  Widget getDateField(String label, DateTime? date, DateTime? relativeDate, OnDateAction onChange) {
    return DateField(
      label: label,
      date: date,
      relativeDate: relativeDate,
      onChange: onChange,
      outerPadding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      isEditing: _isEditing,
    );
  }

  // Tags field for swatch tags
  Widget getTagsField(List<String> tags) {
    return TagsField(
      label: '${getString('swatch_tags')}',
      options: tags,
      values: _swatch.tags!,
      onAddOption: (String value) {
        tags.add(value);
        globals.tags = tags;
      },
      onChange: (List<String> value) {
        _swatch.tags = value;
        onChange(true);
      },
      isEditing: _isEditing,
      labelPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      chipFieldPadding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
    );
  }

  // Star rating field
  Widget getStarField(String label, int value, OnIntAction onChange) {
    return StarField(
      label: label,
      value: value,
      onChange: onChange,
      isEditing: _isEditing,
    );
  }

  void onChange(bool shouldSetState) {
    _hasSaved = false;
    _hasChanged = true;

    // Update screen and swatch icon if needed, such as with finish or color changes
    // Only needed if swatch icon requires visual changes, so is false for something like brand or rating
    if(shouldSetState) {
      setState(() {});
    }
  }

  void exit() async {
    // Save data
    await onExit();

    // Actually return to previous screen and reload if any changes were made
    navigation.pop(context, _hasChanged);
  }

  @override
  Future<void> onExit() async {
    super.onExit();

    // Save changes to swatch
    if(_hasChanged && !_hasSaved) {
      await IO.editId(_swatch.id, _swatch);
    }
  }
}
