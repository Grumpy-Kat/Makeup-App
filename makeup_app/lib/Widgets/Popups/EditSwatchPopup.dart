import 'package:flutter/material.dart' hide HSVColor, FlatButton;
import '../../IO/localizationIO.dart';
import '../../theme.dart' as theme;
import '../../globals.dart' as globals;
import '../../types.dart';
import '../DoubleField.dart';
import '../DateField.dart';
import '../TagsField.dart';
import '../StringField.dart';
import '../StarField.dart';
import '../FlatButton.dart';

class EditSwatchPopup extends StatefulWidget {
  final void Function(String?, String?, double?, double?, DateTime?, DateTime?, int?, List<String>?)? onSave;

  EditSwatchPopup({ this.onSave });

  @override
  EditSwatchPopupState createState() => EditSwatchPopupState();
}

class EditSwatchPopupState extends State<EditSwatchPopup> {
  String? _brand = '';
  String? _palette = '';
  double? _weight;
  double? _price;
  DateTime? _openDate;
  DateTime? _expirationDate;
  int? _rating;
  List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    //divider to mark new section
    Widget divider = Divider(
      color: theme.primaryColorDark,
      height: 17,
      thickness: 1,
      indent: 7,
      endIndent: 7,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
      children: <Widget>[
        // Clear Button
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: <Widget>[
              Text(getString('editSwatchPopup_instructions'), style: theme.primaryTextPrimary),
              TextButton(
                onPressed: () {
                  reset();
                  setState(() { });
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getString('editSwatchPopup_clear'),
                    style: TextStyle(color: theme.secondaryTextColor, fontSize: theme.secondaryTextSize, decoration: TextDecoration.underline, fontFamily: theme.fontFamily),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Brand name
        getTextField(
          '${getString('swatch_brand')}',
          _brand,
          (String value) {
            _brand = value;
          },
        ),
        // Palette name
        getTextField(
          '${getString('swatch_palette')}',
          _palette,
          (String value) {
            _palette = value;
          },
        ),
        // Weight
        getNumField(
          '${getString('swatch_weight')}',
          _weight,
          (double value) {
            _weight = value;
          },
        ),
        // Price
        getNumField(
          '${getString('swatch_price')}',
          _price,
          (double value) {
            _price = value;
          },
        ),
        divider,
        const SizedBox(
          height: 10,
        ),

        // Open date
        getDateField(
          '${getString('swatch_openDate')}',
          _openDate,
          null,
          (DateTime value) {
            setState(() {
              _openDate = value;
            });
          },
        ),
        // Expiration date
        getDateField(
          '${getString('swatch_expirationDate')}',
          _expirationDate,
          _openDate,
          (DateTime value) {
            setState(() {
              _expirationDate = value;
            });
          },
        ),
        divider,

        // Rating
        getStarField(
          '${getString('swatch_rating')}',
          _rating,
          (int value) {
            _rating = value;
          },
        ),
        divider,

        // Tags
        getTagsField(),
        divider,

        // Save button
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
          child: FlatButton(
            bgColor: theme.accentColor,
            onPressed: () {
              if(widget.onSave != null) {
                widget.onSave!(_brand, _palette, _weight, _price, _openDate, _expirationDate, _rating, _tags);
              }
            },
            child: Text(
              getString('save'),
              style: theme.accentTextBold,
            ),
          ),
        ),
      ],
    );
  }

  // Text field, ex for brand or palette name
  Widget getTextField(String label, String? value, OnStringAction onChange) {
    return StringField(
      label: label,
      value: value,
      onChange: onChange,
    );
  }

  // Double field, ex for weight or price numbers
  Widget getNumField(String label, double? value, OnDoubleAction onChange) {
    return DoubleField(
      label: label,
      value: value,
      onChange: onChange,
    );
  }

  // Date field that opens popup to calendar
  Widget getDateField(String label, DateTime? date, DateTime? relativeDate, OnDateAction onChange) {
    return DateField(
      label: label,
      date: date,
      relativeDate: relativeDate,
      onChange: onChange,
      padding: EdgeInsets.zero,
      showInputBorder: false,
    );
  }

  // Tags field for swatch tags
  Widget getTagsField() {
    return TagsField(
      label: '${getString('swatch_tags')}',
      options: globals.tags,
      values: _tags,
      onAddOption: (String value) {
        List<String> tags = globals.tags;
        tags.add(value);
        globals.tags = tags;
      },
      onChange: (List<String> value) {
        _tags = value;
        setState(() { });
      },
      labelPadding: const EdgeInsets.symmetric(vertical: 15),
      chipFieldPadding: const EdgeInsets.only(bottom: 20),
    );
  }

  // Star rating field
  Widget getStarField(String label, int? value, OnIntAction onChange) {
    return StarField(
      label: label,
      value: value,
      onChange: onChange,
      labelPadding: const EdgeInsets.symmetric(vertical: 15),
      starFieldPadding: const EdgeInsets.only(bottom: 20),
    );
  }

  void reset() {
    _brand = '';
    _palette = '';
    _weight = null;
    _price = null;
    _openDate = null;
    _expirationDate = null;
    _rating = null;
    _tags = [];
  }
}
