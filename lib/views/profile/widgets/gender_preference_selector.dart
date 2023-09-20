import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

class GenderPreferenceSelector extends StatefulWidget {
  final onSubmittedCallback;
  final bool hasWhiteBackground;
  final bool registration;

  GenderPreferenceSelector({Key key, this.onSubmittedCallback, this.hasWhiteBackground:false,
      this.registration: false})
      : super(key: key);
  @override
  _GenderPreferenceSelector createState() => _GenderPreferenceSelector();
}

class _GenderPreferenceSelector extends State<GenderPreferenceSelector>
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
    Map<int, String> genderPreferenceTranslation = {
    0: AppLocalization.of(context).men,
    1: AppLocalization.of(context).women,
    2: AppLocalization.of(context).both,
  };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        AppLocalization.of(context).genderPreferenceQuery,
        style: getTextStyle(customFontSize: 22),
        textAlign: TextAlign.left,
      ),
      Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(30),
            child:DropdownButtonFormField(
        icon: Container(
          padding: EdgeInsets.only(right:10),
          child: Icon(DadolIcons.x_arrow, size:8)),
          value: currentUser.genderPreference,
          dropdownColor: Colors.white,
          //isExpanded: true,
          isDense: true,
          items: <int>[0, 1, 2].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(genderPreferenceTranslation[value]),
            );
          }).toList(),
          onChanged: (int newValue) {
            currentUser.updateUsergenderPreferences(newValue);
            widget.onSubmittedCallback();
          },
          style: getTextStyle(isWhite: false),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
              enabledBorder: widget.registration ? Style().inputBoxBorderRegistration : Style().inputBoxBorder,
              border: widget.registration ? Style().inputBoxBorderRegistration : Style().inputBoxBorder,
              filled: Style().inputBoxFilled,
              fillColor: widget.registration ?  Style().inputBoxFillColorRegistration : Style().inputBoxFillColor,
            ),)
    )]);
  }
}
