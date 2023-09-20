import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SMSCodeSelector extends StatefulWidget {
  final onSubmittedCallback;
  final onChangedCallback;
  final hasErrors;

  SMSCodeSelector(
      {Key key,
      this.onSubmittedCallback,
      this.onChangedCallback,
      this.hasErrors: false})
      : super(key: key);
  @override
  _SMSCodeSelector createState() => _SMSCodeSelector();
}

class _SMSCodeSelector extends State<SMSCodeSelector>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();

  bool hasErrors = false;
  String error;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        child: Container(
          padding: EdgeInsets.only(bottom: 15),
          child:
              Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _controller,
                    obscureText: false,
                    onChanged: (text) {
                      widget.onChangedCallback(text);
                    },
                    onSubmitted: (text) {
                      if (hasErrors == false)
                        widget.onSubmittedCallback(_controller.text.trim());
                    },
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                    decoration: InputDecoration(
                      enabledBorder: Style().inputBoxBorderRegistration,
                      border: Style().inputBoxBorderRegistration,
                      errorBorder: Style().inputBoxErrorBorder,
                      filled: true,
                      fillColor: Colors.green.withOpacity(0.5),
                      //errorText: hasErrors ? error : null,
                    ),
                  )),
        ),
        onFocusChange: (focused) {
          if (focused == true) return;
          if (hasErrors == false)
            widget.onSubmittedCallback(_controller.text.trim());
        });
  }
}
