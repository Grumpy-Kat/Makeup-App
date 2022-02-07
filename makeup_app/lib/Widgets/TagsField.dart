import 'package:flutter/material.dart';
import '../../IO/localizationIO.dart';
import '../types.dart';
import '../theme.dart' as theme;
import '../globalWidgets.dart' as globalWidgets;

class TagsField extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> values;

  final OnStringAction? onAddOption;
  final OnStringListAction? onChange;
  final OnStringAction? onSelect;
  final OnStringAction? onDeselect;

  final bool showAddChip;

  // Option to turn of interactivity
  final bool isEditing;

  final EdgeInsets? labelPadding;
  final EdgeInsets? chipFieldPadding;

  TagsField({ required this.label, required this.options, required this.values, this.onAddOption, this.onChange, this.onSelect, this.onDeselect, this.showAddChip = true, this.isEditing = true, this.labelPadding, this.chipFieldPadding });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    // Get chips of all options
    for(int i = 0; i < options.length; i++) {
      if(options[i] == '') {
        continue;
      }

      if(!isEditing && !values.contains(options[i])) {
        continue;
      }

      String text = options[i];
      if(text.contains('_')) {
        text = getString(text, defaultValue: text);
      }

      widgets.add(
        FilterChip(
          checkmarkColor: theme.accentColor,
          label: Text(text, style: theme.primaryTextSecondary),
          selected: values.contains(options[i]),
          onSelected: (bool selected) {
            if(isEditing) {
              if(selected) {
                values.add(options[i]);

                if(onSelect != null) {
                  onSelect!(options[i]);
                }
              } else {
                values.remove(options[i]);

                if(onDeselect != null) {
                  onDeselect!(options[i]);
                }
              }

              if(onChange != null) {
                onChange!(values);
              }
            }
          },
        ),
      );

      widgets.add(
        const SizedBox(
          width: 10,
        ),
      );
    }

    // Plus chip to add new chips
    if(isEditing) {
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
                if(onAddOption != null) {
                  onAddOption!(value);
                }

                values.add(value);

                if(onChange != null) {
                  onChange!(values);
                }
              },
            );
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
          padding: labelPadding ?? const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            '$label: ',
            style: theme.primaryTextPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: chipFieldPadding ?? const EdgeInsets.only(bottom: 20),
          child: Wrap(
            children: widgets,
          ),
        ),
      ],
    );
  }
}
