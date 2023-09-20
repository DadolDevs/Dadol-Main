import 'package:email_validator/email_validator.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmailSelector extends StatefulWidget {
  final onSubmittedCallback;
  final onChangedCallback;
  final hasErrors;

  EmailSelector(
      {Key key,
      this.onSubmittedCallback,
      this.onChangedCallback,
      this.hasErrors: false})
      : super(key: key);
  @override
  _EmailSelector createState() => _EmailSelector();
}

class _EmailSelector extends State<EmailSelector>
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
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Email",
              style: TextStyle(color: Colors.white, fontSize: 22),
              textAlign: TextAlign.left,
            ),
            Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  controller: _controller,
                  onChanged: (text) {
                    if (widget.onChangedCallback != null)
                      widget.onChangedCallback(text);
                  },
                  onSubmitted: (text) {
                    setState(() {
                      hasErrors = validateEmail(_controller.text);
                    });
                    if (hasErrors == false)
                      widget.onSubmittedCallback(
                          {"email": _controller.text.trim()});
                  },
                  style: TextStyle(color: Style().dadolGrey),
                  decoration: InputDecoration(
                    enabledBorder: Style().inputBoxBorderRegistration,
                    border: Style().inputBoxBorderRegistration,
                    errorBorder: Style().inputBoxErrorBorder,
                    filled: true,
                    fillColor: Colors.white,
                    //errorText: hasErrors ? error : null,
                  ),
                )),
            Container(
              padding: EdgeInsets.only(left:10),
                child: Text(
              !hasErrors  ? "" : error,
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.left,
            )),
          ]),
        ),
        onFocusChange: (focused) {
          if (focused == true) return;
          setState(() {
            hasErrors = validateEmail(_controller.text);
          });
          if (hasErrors == false)
            widget.onSubmittedCallback({"email": _controller.text.trim()});
        });
  }

  bool validateEmail(String email) {
    debugPrint("Validating");
    if (email.isEmpty) {
      error = "Please specify your email";
      return true;
    }
    if (EmailValidator.validate(email) == false) {
      error = "Please enter a valid email";
      return true;
    }
    return false;
  }
}
