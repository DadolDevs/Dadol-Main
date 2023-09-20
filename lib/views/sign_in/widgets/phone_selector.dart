import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
class PhoneSelector extends StatefulWidget {
  final onSubmittedCallback;
  final onChangedCallback;
  final hasErrors;

  PhoneSelector(
      {Key key,
      this.onSubmittedCallback,
      this.onChangedCallback,
      this.hasErrors: false})
      : super(key: key);
  @override
  _PhoneSelector createState() => _PhoneSelector();
}

class _PhoneSelector extends State<PhoneSelector>
    with SingleTickerProviderStateMixin {

  bool hasErrors = false;
  String error;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String phoneNumber = "";
    return Focus(
      child: Container(
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(15),
          child: IntlPhoneField(
            autoValidate: false,
            style: TextStyle(fontSize: 30),
            textAlignVertical: TextAlignVertical.bottom,
            searchText: "",
            initialCountryCode: "IT",
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (phone) {
              if (widget.onChangedCallback != null)
                phoneNumber = phone.completeNumber;
                widget.onChangedCallback(phone.completeNumber);
            },
            onSubmitted: (text){
              if (widget.onSubmittedCallback != null)
              widget.onSubmittedCallback(phoneNumber);
            },
          ),
        ),
      ),
    );
  }
}
