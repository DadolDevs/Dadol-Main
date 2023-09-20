import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReportText extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;

  ReportText({Key key, this.onSubmittedCallback, this.hasErrors: false})
      : super(key: key);
  @override
  _ReportText createState() => _ReportText();
}

class _ReportText extends State<ReportText>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Container(
        padding: EdgeInsets.only(bottom: 15),
        child: TextField(
          controller: _controller,
          onChanged: (text) {
            widget.onSubmittedCallback("text", text);
          },
          maxLines: null,
          maxLength: 1000,
          minLines: 10,
          style: TextStyle(color: Colors.white, shadows: Style().textOutlineWithShadows, decoration: TextDecoration.none),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
            counterStyle: TextStyle(color: Colors.white)
          ),
        ),
      ),
      onFocusChange: (focused) {},
    );
  }
}
