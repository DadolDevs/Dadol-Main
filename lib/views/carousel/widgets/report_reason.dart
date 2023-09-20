import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReportReason extends StatefulWidget {
  final onSubmittedCallback;

  ReportReason({Key key, this.onSubmittedCallback}) : super(key: key);
  @override
  _ReportReason createState() => _ReportReason();
}

class _ReportReason extends State<ReportReason>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reportReasons = [
      AppLocalization.of(context).report1,
      AppLocalization.of(context).report2,
      AppLocalization.of(context).report3,
      AppLocalization.of(context).report4,
      AppLocalization.of(context).other,
    ];

    final dropDownIndices =
        Iterable<int>.generate(reportReasons.length).toList();

    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField(
        icon: Container(
          padding: EdgeInsets.only(right:10),
          child: Icon(DadolIcons.x_arrow, size:8, color:Colors.white)),
        isExpanded: true,
        dropdownColor: Colors.white,
        
        isDense: true,
        items: dropDownIndices.map<DropdownMenuItem<int>>((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(reportReasons[value],
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: Style().dadolGrey,
                  
                  fontFamily: "Comfortaa",
                )),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
            return dropDownIndices.map<Widget>((int value) {
              return Text(reportReasons[value],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  shadows: Style().textOutlineWithShadows,
                  fontFamily: "Comfortaa",
                ));
            }).toList();
          },
        onChanged: (int newValue) {
          widget.onSubmittedCallback("reason", reportReasons[newValue]);
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          
        ),
      ),
    );
  }
}
