import 'package:flutter/material.dart' hide HSVColor, FlatButton;
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../IO/localizationIO.dart';
import '../globalWidgets.dart' as globalWidgets;
import '../theme.dart' as theme;
import '../globals.dart' as globals;
import '../types.dart';
import 'StarRating.dart';
import 'FlatButton.dart';

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
        //brand name
        getTextField('${getString('swatch_brand')}', _brand, (String value) { _brand = value; }),
        //palette name
        getTextField('${getString('swatch_palette')}', _palette, (String value) { _palette = value; }),
        //weight
        getNumField('${getString('swatch_weight')}', _weight, (double value) { _weight = value; }),
        //price
        getNumField('${getString('swatch_price')}', _price, (double value) { _price = value; }),
        divider,
        const SizedBox(
          height: 10,
        ),
        //open date
        getDateField('Open Date', _openDate, null, (DateTime value) { setState(() { _openDate = value; }); }),
        //expiration date
        getDateField('Expiration Date', _expirationDate, _openDate, (DateTime value) { setState(() { _expirationDate = value; }); }),
        divider,
        //rating
        getStarField('${getString('swatch_rating')}', _rating, (int value) { _rating = value; }),
        divider,
        //tags
        getChipField('${getString('swatch_tags')}', globals.tags, _tags, (String value) { List<String> tags = globals.tags; tags.add(value); globals.tags = tags; }, (List<String> value) { _tags = value; setState(() { }); }),
        divider,
        //save button
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

  //generic field with just a label and input on opposite horizontal sides
  //utilized by other varieties of fields
  //everything displays as plain text when not editing, but is more unique during editing
  Widget getField(double height, String label, Widget child) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 10),
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
  Widget getTextField(String label, String? value, OnStringAction onChange) {
    return getField(
      55,
      label,
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = value ?? '',
        textAlign: TextAlign.left,
        textInputAction: TextInputAction.done,
        onChanged: (String val) { onChange(globalWidgets.toTitleCase(val).trim()); },
        decoration: InputDecoration(
          fillColor: theme.primaryColorLight,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
  Widget getNumField(String label, double? value, OnDoubleAction onChange) {
    return getField(
      55,
      label,
      TextField(
        scrollPadding: EdgeInsets.zero,
        style: theme.primaryTextPrimary,
        controller: TextEditingController()..text = (value == null ? '' : value.toString()),
        textAlign: TextAlign.left,
        onChanged: (String val) { onChange((val.trim() == '' ? 0.0 : double.parse(val))); },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
        ],
        decoration: InputDecoration(
          fillColor: theme.primaryColorLight,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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

  //date field that opens popup to calendar
  Widget getDateField(String label, DateTime? date, DateTime? relativeDate, OnDateAction onChange) {
    Widget child = Row(
      children: <Widget>[
        Text(
          date == null ? '' : globalWidgets.displayTimeLong(date),
          style: theme.primaryTextPrimary,
          textAlign: TextAlign.left,
        ),
        IconButton(
          padding: const EdgeInsets.only(left: 12, bottom: 70),
          constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
          alignment: Alignment.topLeft,
          icon: Icon(
            Icons.calendar_today,
            size: theme.secondaryIconSize,
          ),
          onPressed: () {
            globalWidgets.openDialog(
              context,
              (BuildContext context) {
                if(date == null && relativeDate != null) {
                  date = DateTime(relativeDate.year + 1, relativeDate.month, relativeDate.day);
                }
                DateTime focusedDate = date ?? DateTime.now();
                return Padding(
                  padding: EdgeInsets.only(bottom: (MediaQuery.of(context).size.height * 0.5) - 251),
                  child: Dialog(
                    insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          height: 502,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  alignment: Alignment.topLeft,
                                  child: TableCalendar(
                                    firstDay: DateTime.utc(1989, 12, 31),
                                    lastDay: DateTime.utc(2041, 1, 5),
                                    focusedDay: focusedDate,
                                    calendarStyle: CalendarStyle(
                                      defaultTextStyle: theme.primaryTextSecondary,
                                      isTodayHighlighted: false,
                                      disabledDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      todayTextStyle: theme.primaryTextSecondary,
                                      selectedDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.accentColor,
                                      ),
                                      selectedTextStyle: theme.accentTextSecondary,
                                    ),
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleTextStyle: theme.primaryTextBold,
                                    ),
                                    onPageChanged: (DateTime newFocusedDate) {
                                      focusedDate = newFocusedDate;
                                    },
                                    selectedDayPredicate: (DateTime possibleDate) {
                                      return isSameDay(possibleDate, date ?? DateTime.now());
                                    },
                                    onDaySelected: (DateTime selectedDate, DateTime newFocusedDate) {
                                      setState(() {
                                        date = selectedDate;
                                        focusedDate = newFocusedDate;
                                      });
                                      onChange(selectedDate);
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 40,
                                child: FlatButton(
                                  bgColor: theme.accentColor,
                                  onPressed: () {
                                    onChange(date ?? focusedDate);
                                    Navigator.pop(context);
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${getString('save')}',
                                      style: theme.accentTextBold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
    return getField(
      55,
      label,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.primaryColorLight,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  //star rating field
  Widget getStarField(String label, int? value, OnIntAction onChange) {
    return Column(
      children: <Widget> [
        Container(
          height: 55,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            '$label: ${(value == null ? 0 : value)}/10',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.only(bottom: 20),
          child: StarRating(
            starCount: 10,
            starSize: 35,
            rating: (value == null ? 0 : value),
            onChange: (int rating) {
              setState(() { onChange(rating); });
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
            if(selected) {
              values.add(options[i]);
            } else {
              values.remove(options[i]);
            }
            onChange(values);
          },
        ),
      );
      widgets.add(
        const SizedBox(
          width: 10,
        ),
      );
    }
    widgets.add(
      ActionChip(
        label: Icon(
          Icons.add,
          size: 15,
          color: theme.iconTextColor,
        ),
        onPressed: () {
          globalWidgets.openTextDialog(
            context,
            getString('swatch_tags_popupInstructions'),
            getString('swatch_tags_popupError'),
            getString('swatch_tags_popupBtn'),
            (String value) {
              onAddOption(value);
              values.add(value);
              onChange(values);
            },
          );
        },
      ),
    );
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
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 20),
          child: Wrap(
            children: widgets,
          ),
        ),
      ],
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
