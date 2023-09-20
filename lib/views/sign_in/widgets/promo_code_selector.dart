import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PromoCodeSelector extends StatefulWidget {
  final onSubmittedCallback;
  final onChangedCallback;
  final hasErrors;

  PromoCodeSelector(
      {Key key,
      this.onSubmittedCallback,
      this.onChangedCallback,
      this.hasErrors: false})
      : super(key: key);
  @override
  _PromoCodeSelector createState() => _PromoCodeSelector();
}

class _PromoCodeSelector extends State<PromoCodeSelector>
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
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  AppLocalization.of(context).promoCode,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
                    setState(() {
                      hasErrors = validatePassword(_controller.text);
                    });
                    if (hasErrors == false)
                      widget.onSubmittedCallback(
                          {"invitationCode": _controller.text.trim()});
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
            Container(
                padding: EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  !hasErrors ? "" : error,
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
            widget.onSubmittedCallback(
                {"invitationCode": _controller.text.trim()});
        });
  }

  bool validatePassword(String promo) {
    debugPrint("Promo: $promo");
    if (promo.length != 6 && promo.length != 0) {
      error = "Promo code must be 6 characters long";
      return true;
    }

    return false;
  }
}
