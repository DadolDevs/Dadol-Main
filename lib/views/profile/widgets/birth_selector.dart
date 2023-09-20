import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';

class BirthSelector extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;
  final hasWhiteBackground;
  final bool registration;

  BirthSelector(
      {Key key,
      this.onSubmittedCallback,
      this.hasErrors: false,
      this.hasWhiteBackground: false,
      this.registration: false})
      : super(key: key);
  @override
  _BirthSelector createState() => _BirthSelector();
}

class _BirthSelector extends State<BirthSelector>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  var formatter = new DateFormat('yyyy-MM-dd');
  bool dateHasErrors = false;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        _controller.text = formatter.format(picked);
        if (calculateAge(picked) >= 18) {
          dateHasErrors = false;
          currentUser.updateBirthDate(Timestamp.fromDate(picked));
        } else {
          dateHasErrors = true;
        }
      });
    widget.onSubmittedCallback({"birthdate": picked});
  }

  @override
  void initState() {
    if (currentUser.birthDate != Timestamp.fromMillisecondsSinceEpoch(0))
      _controller.text = formatter.format(currentUser.birthDate.toDate());
    super.initState();
  }

  TextStyle getTextStyle({double customFontSize = 16, isWhite: true}) {
    var textStyle = TextStyle(
        color: !isWhite ? Colors.black : Colors.white,
        fontSize: customFontSize,
        shadows: widget.registration ? null : Style().textOutlineWithShadows);
    if (widget.hasWhiteBackground == true) {
      textStyle = TextStyle(color: Colors.black, fontSize: customFontSize);
    }
    return textStyle;
  }

  void _showDatePicker(ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
          height: 157,
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Container(
                height: 100,
                child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                    onDateTimeChanged: (val) {
                      setState(() {
                        _controller.text = formatter.format(val);
                        if (calculateAge(val) >= 18) {
                          dateHasErrors = false;
                          currentUser.updateBirthDate(Timestamp.fromDate(val));
                        } else {
                          dateHasErrors = true;
                        }
                      });

                      widget.onSubmittedCallback({"birthdate": val});
                    }),
              ),

              // Close the modal
              CupertinoButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            AppLocalization.of(context).birthDateQuery,
            style: getTextStyle(customFontSize: 22),
            textAlign: TextAlign.left,
          ),
          Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                readOnly: true,
                showCursor: false,
                controller: _controller,
                onTap: () => _showDatePicker(context),
                style: getTextStyle(isWhite: false),
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  enabledBorder: widget.registration
                      ? Style().inputBoxBorderRegistration
                      : Style().inputBoxBorder,
                  border: widget.registration
                      ? Style().inputBoxBorderRegistration
                      : Style().inputBoxBorder,
                  filled: Style().inputBoxFilled,
                  fillColor: widget.registration
                      ? Style().inputBoxFillColorRegistration
                      : Style().inputBoxFillColor,
                ),
              )),
          dateHasErrors
              ? Text(
                  AppLocalization.of(context).ageNotice,
                  style: TextStyle(color: Colors.red),
                )
              : SizedBox(),
        ]));
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
