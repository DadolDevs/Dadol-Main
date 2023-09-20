import 'dart:ui';

import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/carousel/widgets/report_detailed_text.dart';
import 'package:feelingapp/views/carousel/widgets/report_reason.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../main.dart';
import '../../../resources/localization.dart';

class ReportCard extends StatefulWidget {
  final onSubmittedCallback;
  final otherUid;
  final enabled;
  final dark;

  ReportCard(
      {Key key,
      this.onSubmittedCallback,
      this.otherUid,
      this.enabled,
      this.dark = false})
      : super(key: key);
  @override
  _ChatReportCard createState() => _ChatReportCard();
}

class _ChatReportCard extends State<ReportCard>
    with SingleTickerProviderStateMixin {
  var reportReason;
  var reportText;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled == false) {
      return SizedBox();
    }
    final reportLabelStyle = TextStyle(
        color: Colors.white,
        fontSize: 24,
        shadows: Style().textOutlineWithShadows);
    final backButton = Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.only(
              top: 35,
              left: MediaQuery.of(context).size.height * 0.01),
          child: RawMaterialButton(
            constraints: BoxConstraints.tight(Size(
                (MediaQuery.of(context).size.height * 0.05),
                MediaQuery.of(context).size.height * 0.05)),
            onPressed: () {
              widget.onSubmittedCallback(false);
            },
            shape: CircleBorder(),
            child: Icon(
              DadolIcons.x_back_arrow,
              color: Colors.white,
              size: MediaQuery.of(context).size.height * 0.05,
            ),
          ),
        ));
    return GestureDetector(
        onHorizontalDragStart: (details) {},
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.3),
            child: ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20,
                      sigmaY: 20,
                    ),
                    child: Stack(children: [
                      SingleChildScrollView(
                          child: Container(
                        color: Colors.black.withOpacity(widget.dark ? 0.5 : 0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.only(top: 100, left: 20, right: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalization.of(context).reportUser,
                                style: reportLabelStyle,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ReportReason(
                                onSubmittedCallback: reportCallback,
                              ),
                              Text(
                                AppLocalization.of(context).reportDetails,
                                style: reportLabelStyle,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ReportText(
                                onSubmittedCallback: reportCallback,
                              ),
                              Row(children: [
                                Spacer(),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  color: Style().dazzlePrimaryColor,
                                  textColor: Colors.white,
                                  child: Text(
                                    AppLocalization.of(context).sendReport,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24),
                                  ),
                                  onPressed: () {
                                    if (reportReason != null) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  AppLocalization.of(context)
                                                      .reportTitle),
                                              content: Text(
                                                  AppLocalization.of(context)
                                                      .reportBody),
                                              actions: [
                                                FlatButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                        AppLocalization.of(
                                                                context)
                                                            .cancel)),
                                                FlatButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      currentUser
                                                          .generateReportForOtherUser(
                                                              reportReason,
                                                              reportText,
                                                              widget.otherUid);
                                                      reportReason = null;
                                                      reportText = null;
                                                      widget
                                                          .onSubmittedCallback(
                                                              true);
                                                    },
                                                    child: Text(
                                                        AppLocalization.of(
                                                                context)
                                                            .continue_))
                                              ],
                                            );
                                          });
                                    }
                                  },
                                ),
                                Spacer(),
                              ]),
                            ]),
                      )),
                      backButton,
                    ])))));
  }

  void reportCallback(String type, String text) {
    if (type == "reason")
      reportReason = text;
    else
      reportText = text;
  }
}
