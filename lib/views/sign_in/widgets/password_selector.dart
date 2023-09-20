import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PasswordSelector extends StatefulWidget {
  final onSubmittedCallback;
  final onChangedCallback;
  final hasErrors;
  final matchAgainst;

  PasswordSelector(
      {Key key,
      this.onSubmittedCallback,
      this.onChangedCallback,
      this.hasErrors: false,
      this.matchAgainst})
      : super(key: key);
  @override
  _PasswordSelector createState() => _PasswordSelector();
}

class _PasswordSelector extends State<PasswordSelector>
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
            widget.matchAgainst != null
                ? Text(
                    AppLocalization.of(context).confirmPassword,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22),
                    textAlign: TextAlign.left,
                  )
                : Text(
                    "Password",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,),
                    textAlign: TextAlign.left,
                  ),
            Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  controller: _controller,
                  obscureText: true,
                  onChanged: (text) {
                    widget.onChangedCallback(text);
                  },
                  onSubmitted: (text) {
                    setState(() {
                      hasErrors = validatePassword(_controller.text);
                    });
                    if (hasErrors == false)
                      widget.onSubmittedCallback(
                          {"password": _controller.text.trim()});
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
                padding: EdgeInsets.only(left: 10),
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
            hasErrors = validatePassword(_controller.text);
          });
          if (hasErrors == false)
            widget.onSubmittedCallback({"password": _controller.text.trim()});
        });
  }

  bool validatePassword(String password) {
    debugPrint("Password: $password");
    if (password.length < 6) {
      error = "Password must be at least 6 characters long";
      return true;
    }
    if (widget.matchAgainst != null) {
      if (password != widget.matchAgainst) {
        error = "The two passwords must be the same";
        return true;
      }
    }

    return false;
  }
}
