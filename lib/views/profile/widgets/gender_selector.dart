import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

class GenderSelector extends StatefulWidget {
  final onSubmittedCallback;
  final bool hasWhiteBackground;
  final bool registration;

  GenderSelector(
      {Key key, this.onSubmittedCallback, this.hasWhiteBackground: false,
      this.registration: false})
      : super(key: key);
  @override
  _GenderSelector createState() => _GenderSelector();
}

class _GenderSelector extends State<GenderSelector>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    Map<int, String> genderTranslation = {
      0: AppLocalization.of(context).man,
      1: AppLocalization.of(context).woman,
    };

    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalization.of(context).genderQuery,
            style: getTextStyle(customFontSize: 22)),
        Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(30),
            child:DropdownButtonFormField(
          icon: Container(
          padding: EdgeInsets.only(right:10),
          child: Icon(DadolIcons.x_arrow, size:8)),
          value: currentUser.gender,
          dropdownColor: Colors.white,
          //isExpanded: true,
          isDense: true,
          items: <int>[0, 1].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(genderTranslation[value]),
            );
          }).toList(),
          onChanged: (int newValue) {
            currentUser.updateUserGender(newValue);
            widget.onSubmittedCallback();
          },
          style: getTextStyle(isWhite: false),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
              enabledBorder: widget.registration ? Style().inputBoxBorderRegistration : Style().inputBoxBorder,
              border: widget.registration ? Style().inputBoxBorderRegistration : Style().inputBoxBorder,
              filled: Style().inputBoxFilled,
              fillColor: widget.registration ?  Style().inputBoxFillColorRegistration : Style().inputBoxFillColor,
            ),
        )
      )]),
    );
  }
}
