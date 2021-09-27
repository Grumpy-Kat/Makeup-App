import 'package:flutter/material.dart' hide FlatButton;
import 'package:table_calendar/table_calendar.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../types.dart';
import '../globalWidgets.dart' as globalWidgets;
import 'SwatchImage.dart';
import 'SwatchImageMultiplePopup.dart';
import 'FlatButton.dart';

class PaletteTextPopup {
  static Future<void> open(BuildContext context, String title, void Function(String, String, double, double, DateTime?, DateTime?, List<SwatchImage>) onPressed, { bool showRequired = true, bool showNums = true, bool showDates = true, bool showImgs = true }) {
    String brand = '';
    String palette = '';
    double weight = 0.0;
    double price = 0.00;
    DateTime? openDate;
    DateTime? expirationDate;
    List<SwatchImage> imgs = [];

    //divider to mark new section
    Widget divider = Divider(
      color: theme.primaryColorDark,
      height: 17,
      thickness: 1,
      indent: 7,
      endIndent: 7,
    );

    List<bool> showErrorTexts = [false, false];
    return globalWidgets.openDialog(
      context,
      (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return globalWidgets.getAlertDialog(
              context,
              title: Text(title, style: theme.primaryTextBold),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget> [
                    //brand
                    if(showRequired) globalWidgets.getTextField(
                      context,
                      getString('addPalette_brand'),
                      brand,
                      getString('addPalette_brandError'),
                      showErrorTexts[0],
                      (String val) {
                        brand = val;
                        if(showErrorTexts[0] && val != '') {
                          setState(() { showErrorTexts[0] = false; });
                        }
                      },
                      (String val) {
                        brand = val;
                        if(brand != '') {
                          setState(() { showErrorTexts[0] = false; });
                        }
                        if(brand == '') {
                          setState(() { showErrorTexts[0] = true; });
                        }
                      }
                    ),
                    if(showRequired) const SizedBox(
                      height: 20,
                    ),

                    //palette
                    if(showRequired) globalWidgets.getTextField(
                      context,
                      getString('addPalette_palette'),
                      palette,
                      getString('addPalette_paletteError'),
                      showErrorTexts[1],
                      (String val) {
                        palette = val;
                        if(showErrorTexts[1] && val != '') {
                          setState(() { showErrorTexts[1] = false; });
                        }
                      },
                      (String val) {
                        palette = val;
                        if(palette != '') {
                          setState(() { showErrorTexts[1] = false; });
                        }
                        if(palette == '') {
                          setState(() { showErrorTexts[1] = true; });
                        }
                      }
                    ),
                    if(showRequired) const SizedBox(
                      height: 20,
                    ),

                    //weight
                    if(showNums) globalWidgets.getNumField(
                      context,
                      getString('addPalette_weight'),
                      weight,
                      '',
                      false,
                      (double val) {
                        weight = double.parse(val.toStringAsFixed(4));
                      },
                      (double val) {
                        setState(() {
                          weight = double.parse(val.toStringAsFixed(4));
                        });
                      },
                    ),
                    if(showNums) const SizedBox(
                      height: 20,
                    ),

                    //price
                    if(showNums) globalWidgets.getNumField(
                      context,
                      getString('addPalette_price'),
                      price,
                      '',
                      false,
                      (double val) {
                        price = double.parse(val.toStringAsFixed(2));
                      },
                      (double val) {
                        setState(() {
                          price = double.parse(val.toStringAsFixed(2));
                        });
                      },
                    ),
                    if(showNums) const SizedBox(
                      height: 20,
                    ),

                    if((showRequired || showNums) && (showDates || showImgs)) divider,
                    if(showDates) const SizedBox(
                      height: 20,
                    ),

                    //open date
                    if(showDates) getDateField(
                      context,
                      getString('addPalette_openDate'),
                      openDate,
                      null,
                      (DateTime value) {
                        setState(() {
                          openDate = value;
                        });
                      },
                    ),
                    if(showDates) const SizedBox(
                      height: 20,
                    ),

                    //expiration date
                    if(showDates) getDateField(
                      context,
                      getString('addPalette_expirationDate'),
                      expirationDate,
                      openDate,
                      (DateTime value) {
                        setState(() {
                          expirationDate = value;
                        });
                      },
                    ),
                    if(showDates) const SizedBox(
                      height: 20,
                    ),

                    if(showDates && showImgs) divider,

                    if(showImgs) getImgsField(
                      context,
                      getString('addPalette_swatchImages'),
                      imgs,
                      (List<SwatchImage> value) {
                        setState(() {
                          imgs = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  bgColor: theme.accentColor,
                  onPressed: () {
                    if(showRequired && (brand == '' || palette == '')) {
                      if(brand == '') {
                        setState(() { showErrorTexts[0] = true; });
                      }
                      if(palette == '') {
                        setState(() { showErrorTexts[1] = true; });
                      }
                    } else {
                      //doesn't use navigation because is popping a Dialog
                      Navigator.pop(context);
                      onPressed(brand, palette, weight, price, openDate, expirationDate, imgs);
                    }
                  },
                  child: Text(
                    getString('save'),
                    style: theme.accentTextBold,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  static Widget getDateField(BuildContext context, String label, DateTime? date, DateTime? relativeDate, OnDateAction onChange) {
    return GestureDetector(

      onTap: () {
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
                          ),
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

      child: TextFormField(
        autofocus: true,
        textAlign: TextAlign.left,
        style: theme.primaryTextSecondary,
        textCapitalization: TextCapitalization.words,
        cursorColor: theme.accentColor,
        textInputAction: TextInputAction.done,
        controller: TextEditingController()..text = (date == null ? '' : globalWidgets.displayTimeLong(date!)),
        readOnly: true,
        decoration: InputDecoration(
          prefix: date == null ? null : Container(
            padding: const EdgeInsets.only(right: 9, top: 5, bottom: 0),
            child: Icon(
              Icons.calendar_today,
              size: theme.secondaryIconSize,
              color: theme.iconTextColor,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon: date != null ? null : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.calendar_today,
              size: theme.secondaryIconSize,
              color: theme.iconTextColor,
            ),
          ),
          fillColor: theme.primaryColor,
          labelText: label,
          labelStyle: theme.primaryTextSecondary,
          enabled: false,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.primaryColorDark,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.accentColor,
              width: 2.5,
            ),
          ),
        ),
      ),

    );
  }

  static Widget getImgsField(BuildContext context, String label, List<SwatchImage>? value, OnSwatchImageListAction onChange) {
    value = value ?? [];

    List<Widget> widgets = [];
    List<String> imgIds = [];
    for(int i = 0; i < value.length; i++) {
      imgIds.add(value[i].id);
      widgets.add(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
          ),
          child: Image.memory(
            value[i].bytes,
            height: 50,
          ),
        ),
      );
    }

    widgets.add(
      SwatchImageMultiplePopup(
        otherImgIds: imgIds,
        onImgsAdded: (List<SwatchImage> newValue) {
          value!.addAll(newValue);
          onChange(value);
        },
      ),
    );

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
          height: 50,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 20),
          child: GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 15,
              crossAxisSpacing: 0,
              crossAxisCount: 1,
            ),
            itemCount: widgets.length,
            itemBuilder: (BuildContext context, int i) {
              return widgets[i];
            },
          ),
        ),
      ],
    );
  }
}