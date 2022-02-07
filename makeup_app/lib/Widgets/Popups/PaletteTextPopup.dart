import 'package:flutter/material.dart' hide FlatButton;
import '../../IO/localizationIO.dart';
import '../../theme.dart' as theme;
import '../../types.dart';
import '../../globalWidgets.dart' as globalWidgets;
import '../../Data/SwatchImage.dart';
import '../StringFormField.dart';
import '../DoubleFormField.dart';
import '../DateField.dart';
import '../FlatButton.dart';
import 'SwatchImageMultiplePopup.dart';

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
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget> [
                      // Brand
                      if(showRequired) StringFormField(
                        label: getString('addPalette_brand'),
                        value: brand,
                        error: getString('addPalette_brandError'),
                        showErrorText: showErrorTexts[0],
                        onChanged: (String val) {
                          brand = val;
                          if(showErrorTexts[0] && val != '') {
                            setState(() { showErrorTexts[0] = false; });
                          }
                        },
                        onSubmitted: (String val) {
                          brand = val;
                          if(brand != '') {
                            setState(() { showErrorTexts[0] = false; });
                          }
                          if(brand == '') {
                            setState(() { showErrorTexts[0] = true; });
                          }
                        },
                      ),
                      if(showRequired) const SizedBox(
                        height: 20,
                      ),

                      // Palette
                      if(showRequired) StringFormField(
                        label: getString('addPalette_palette'),
                        value: palette,
                        error: getString('addPalette_paletteError'),
                        showErrorText: showErrorTexts[1],
                        onChanged: (String val) {
                          palette = val;
                          if(showErrorTexts[1] && val != '') {
                            setState(() { showErrorTexts[1] = false; });
                          }
                        },
                        onSubmitted: (String val) {
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

                      // Weight
                      if(showNums) DoubleFormField(
                        label: getString('addPalette_weight'),
                        value: weight,
                        onChanged: (double val) {
                          weight = double.parse(val.toStringAsFixed(4));
                        },
                        onSubmitted: (double val) {
                          setState(() {
                            weight = double.parse(val.toStringAsFixed(4));
                          });
                        },
                      ),
                      if(showNums) const SizedBox(
                        height: 20,
                      ),

                      // Price
                      if(showNums) DoubleFormField(
                        label: getString('addPalette_price'),
                        value: price,
                        onChanged: (double val) {
                          price = double.parse(val.toStringAsFixed(2));
                        },
                        onSubmitted: (double val) {
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
                        getString('addPalette_openDate'),
                        openDate,
                        null,
                        (DateTime value) {
                          setState(() {
                            openDate = value;
                          });
                        },
                      ),

                      //expiration date
                      if(showDates) getDateField(
                        getString('addPalette_expirationDate'),
                        expirationDate,
                        openDate,
                        (DateTime value) {
                          setState(() {
                            expirationDate = value;
                          });
                        },
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

  static Widget getDateField(String label, DateTime? date, DateTime? relativeDate, OnDateAction onChange) {
    return DateField(
      label: label,
      date: date,
      relativeDate: relativeDate,
      onChange: onChange,
      padding: EdgeInsets.zero,
      outerPadding: const EdgeInsets.only(bottom: 20),
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