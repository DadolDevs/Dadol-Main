import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../main.dart';

class NicknameSelector extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;
  final bool hasWhiteBackground;
  final bool registration;

  NicknameSelector(
      {Key key,
      this.onSubmittedCallback,
      this.hasErrors: false,
      this.hasWhiteBackground: false,
      this.registration: false})
      : super(key: key);
  @override
  _NicknameSelector createState() => _NicknameSelector();
}

class _NicknameSelector extends State<NicknameSelector>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController(text: currentUser.userName);

  bool hasErrors = false;

  void initState() {
    super.initState();

    _controller.addListener(() {
      debugPrint(_controller.text);
      if (_controller.text.length >= 3) {
        setState(() {
          hasErrors = false;
        });
      } else
        setState(() {
          hasErrors = true;
        });
    });
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
    final _initialTextValue = currentUser.userName;

    return Focus(
      child: Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            AppLocalization.of(context).nameQuery,
            style: getTextStyle(customFontSize: 22, isWhite: true),
            textAlign: TextAlign.left,
          ),
          Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                controller: _controller,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp("[A-Za-zÀ-ÖØ-öø-ÿ]")),
                ],
                onSubmitted: (text) {
                  if (!hasErrors)
                    currentUser.updateUserNickname(_controller.text);
                  else
                    _controller.text = _initialTextValue;
                  widget.onSubmittedCallback({"nickname": _controller.text});
                },
                onChanged: (text) {
                  int truncation = 15;
                  if (_controller.text.length > truncation)
                    _controller.text =
                        _controller.text.substring(0, truncation);
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                },
                style: getTextStyle(isWhite: false),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
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
              ))
        ]),
      ),
      onFocusChange: (focused) {
        if (!focused && !hasErrors)
          currentUser.updateUserNickname(_controller.text);
        else
          _controller.text = _initialTextValue;
        widget.onSubmittedCallback({"nickname": _controller.text});
      },
    );
  }
}
