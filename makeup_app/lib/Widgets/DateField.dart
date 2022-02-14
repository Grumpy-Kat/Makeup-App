import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide FlatButton;
import 'package:table_calendar/table_calendar.dart';
import '../IO/localizationIO.dart';
import '../theme.dart' as theme;
import '../types.dart';
import '../globalWidgets.dart' as globalWidgets;
import 'FlatButton.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime? relativeDate;
  final OnDateAction onChange;

  final EdgeInsets? padding;
  final EdgeInsets? outerPadding;

  final bool isHorizontal;

  final bool isEditing;
  final bool showInputBorder;

  DateField({ required this.label, this.date, this.relativeDate,  required this.onChange, this.padding, this.isHorizontal = true, this.isEditing = true, this.showInputBorder = true, this.outerPadding });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      Text(
        '$label: ',
        style: theme.primaryTextPrimary,
        textAlign: TextAlign.left,
      ),

      Container(
        height: 55,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: (isEditing && showInputBorder) ? theme.primaryColorLight : theme.bgColor,
          borderRadius: BorderRadius.circular(3.0),
          border: Border.fromBorderSide(
            BorderSide(
              color: (isEditing && showInputBorder) ? theme.primaryColorDark : theme.bgColor,
              width: 1.0,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: isHorizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              date == null ? '' : globalWidgets.displayTimeLong(date!),
              style: theme.primaryTextPrimary,
              textAlign: TextAlign.left,
            ),

            if(isEditing) IconButton(
              padding: EdgeInsets.only(left: date == null ? 0 : 12, bottom: 3),
              constraints: BoxConstraints.tight(const Size.fromWidth(theme.primaryIconSize + 15)),
              alignment: Alignment.centerLeft,
              icon: Icon(
                Icons.calendar_today,
                size: theme.secondaryIconSize,
              ),
              onPressed: () {
                globalWidgets.openDialog(
                  context,
                  (BuildContext context) {
                    DateTime? date = this.date;

                    if(date == null && relativeDate != null) {
                      date = DateTime(relativeDate!.year + 1, relativeDate!.month, relativeDate!.day);
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
                                  // TableCalendar
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

                                          // TODO: If breaking due to onChange's setState, make StatefulWidget
                                          onChange(selectedDate);
                                        },
                                      ),
                                    ),
                                  ),

                                  // Enter button
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
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      )
    ];

    if(isHorizontal) {
      return Container(
        height: 55,
        alignment: Alignment.centerLeft,
        padding: outerPadding ?? const EdgeInsets.only(bottom: 10),
        child: Row(
          children: children,
        ),
      );
    }

    return Container(
      height: 100,
      alignment: Alignment.centerLeft,
      padding: outerPadding ?? const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
