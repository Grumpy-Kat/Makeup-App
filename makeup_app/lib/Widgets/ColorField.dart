import 'package:flutter/material.dart' hide HSVColor;
import '../ColorMath/ColorObjects.dart';
import '../ColorMath/ColorConversions.dart';
import '../ColorMath/ColorProcessing.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../types.dart';
import '../globalWidgets.dart' as globalWidgets;
import 'ColorPicker.dart';

class ColorField extends StatelessWidget {
  final String label;
  final RGBColor color;
  final String colorNameOrg;

  final OnRGBColorAction onChange;
  final OnStringAction onNameChange;

  final bool isEditing;

  ColorField({ required this.label, required this.color, required this.colorNameOrg, required this.onChange, required this.onNameChange, this.isEditing = true });

  @override
  Widget build(BuildContext context) {
    String localizedColorName = (colorNameOrg.contains('color_') ? getString(colorNameOrg) : globalWidgets.toTitleCase(colorNameOrg));
    String colorName = colorNameOrg == '' ? getString(getColorName(color)) : localizedColorName;

    return Container(
      height: 55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Row(
        children: <Widget>[
          Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isEditing ? theme.primaryColorLight : theme.bgColor,
                borderRadius: BorderRadius.circular(3.0),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: isEditing ? theme.primaryColorDark : theme.bgColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    colorName,
                    style: theme.primaryTextPrimary,
                    textAlign: TextAlign.left,
                  ),

                  if(isEditing) IconButton(
                    padding: const EdgeInsets.only(left: 12, bottom: 70),
                    constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
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
                              insetPadding: const EdgeInsets.symmetric(horizontal: 0),
                              shape: const RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
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
                                        padding: const EdgeInsets.only(bottom: 30),
                                        alignment: Alignment.topLeft,
                                        child: ColorPicker(
                                          btnText: '${getString('save')}',
                                          initialColor: RGBtoHSV(color),
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
                        },
                      );
                    },
                  ),

                  if(isEditing) IconButton(
                    padding: const EdgeInsets.only(bottom: 70),
                    constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
                    alignment: Alignment.topLeft,
                    icon: Icon(
                      Icons.mode_edit,
                      size: theme.secondaryIconSize,
                    ),
                    onPressed: () {
                      globalWidgets.openTextDialog(
                        context,
                        getString('swatch_color_popupInstructions'),
                        '',
                        getString('save'),
                        (String value) {
                          onNameChange(value);
                        },
                        orgValue: localizedColorName,
                        required: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
