import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../main.dart';


class ReportIssue extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;

  ReportIssue({Key key, this.onSubmittedCallback, this.hasErrors: false})
      : super(key: key);
  @override
  _ReportIssue createState() => _ReportIssue();
}

class _ReportIssue extends State<ReportIssue>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  bool isReportSubmitted = false;
  bool isReportCorrect = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(DadolIcons.x_back_arrow, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          centerTitle: true,
          title: Text(
            AppLocalization.of(context).reportIssue,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height*0.8,
                  padding: EdgeInsets.only(
                      top: 10,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05),
                  child: !isReportSubmitted
                      ? Column(
                          children: [
                            _reportReason(),
                            SizedBox(height: 20),
                            _reportTextBox(),
                            SizedBox(
                              height: 20,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: !isReportCorrect ? Colors.grey : Style().dazzlePrimaryColor),
                                  borderRadius: BorderRadius.circular(15)),
                              color: !isReportCorrect ? Colors.grey : Style().dazzlePrimaryColor,
                              textColor: Colors.white,
                              child: Text(
                                AppLocalization.of(context).sendReport,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                              ),
                              onPressed: () {
                                if (_reasonController.text != "" &&
                                    _detailsController.text != "") {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              AppLocalization.of(context)
                                                  .issueTitleConfirmation),
                                          content: Text(
                                              AppLocalization.of(context)
                                                  .issueBodyConfirmation),
                                          actions: [
                                            FlatButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                    AppLocalization.of(context)
                                                        .cancel)),
                                            FlatButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  currentUser
                                                      .generateReportForOtherUser(
                                                          _reasonController
                                                              .text,
                                                          _detailsController
                                                              .text,
                                                          "self");
                                                  setState(() {
                                                    isReportSubmitted = true;
                                                  });
                                                },
                                                child: Text(
                                                    AppLocalization.of(context)
                                                        .continue_))
                                          ],
                                        );
                                      });
                                }
                              },
                            ),
                          ],
                        )
                      : Column(
                        children: [
                          Spacer(),
                          Text(
                            AppLocalization.of(context).issueReceived,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 10),
                          ClipOval(
                            child: Material(
                              color: Style().dazzlePrimaryColor, // button color
                              child: InkWell(
                                splashColor: Style()
                                    .dazzleSecondaryColor, // inkwell color
                                child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 50,
                                    )),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
 Spacer(),                       
                        ])),
            )));
  }

  Widget _reportTextBox() {
    return Theme(
        data: new ThemeData(
          primaryColor: Color.fromRGBO(178, 178, 178, 1),
          primaryColorDark: Color.fromRGBO(178, 178, 178, 1),
        ),
        child: Focus(
          child: Container(
            padding: EdgeInsets.only(bottom: 15),
            child: TextField(
              controller: _detailsController,
              onChanged: (text) {
                checkFields();
                widget.onSubmittedCallback("text", text);
              },
              maxLines: null,
              maxLength: 1000,
              minLines: 10,
              style: TextStyle(
                  color: Colors.black, decoration: TextDecoration.none),
              decoration: InputDecoration(
                  hintText: AppLocalization.of(context).issueDescription,
                  fillColor: Colors.black.withAlpha(5)),
            ),
          ),
          onFocusChange: (focused) {},
        ));
  }

  Widget _reportReason() {
    return Theme(
        data: new ThemeData(
          primaryColor: Color.fromRGBO(178, 178, 178, 1),
          primaryColorDark: Color.fromRGBO(178, 178, 178, 1),
        ),
        child: TextField(
          controller: _reasonController,
          style: TextStyle(color: Colors.black),
          onChanged: (text) {checkFields();},
          decoration: InputDecoration(
            prefixIcon: Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  AppLocalization.of(context).subject,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),

            //prefix: Text("Oggetto: ", style: TextStyle(fontWeight: FontWeight.bold),)
          ),
        ));
  }

  void checkFields() {
    if(_reasonController.text.length > 0 && _detailsController.text.length > 0){
      setState(() {
        isReportCorrect = true;
      });
    }
    else {
      setState(() {
        isReportCorrect = false;
      });
    }
  }
}
