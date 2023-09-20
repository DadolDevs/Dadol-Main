import 'package:cloud_functions/cloud_functions.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../../../main.dart';

class UserDeleteAccount extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;

  UserDeleteAccount({Key key, this.onSubmittedCallback, this.hasErrors: false})
      : super(key: key);
  @override
  _UserDeleteAccount createState() => _UserDeleteAccount();
}

class _UserDeleteAccount extends State<UserDeleteAccount>
    with SingleTickerProviderStateMixin {
  final TextEditingController _reasonController = TextEditingController();

  String checkedReason = "None";

  @override
  Widget build(BuildContext context) {
    //shadows: Style().textOutlineWithShadows);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(DadolIcons.x_back_arrow, color: Style().dadolGrey),
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          centerTitle: true,
          title: Text(
            AppLocalization.of(context).suspendAccount,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                  top: 10,
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1),
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  topText(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  reasonSelector(),
                  otherInputBox(),
                  Spacer(),
                  deleteAccount(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1)
                ],
              )),
        ));
  }

  Widget topText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppLocalization.of(context).deleteAccountContent,
          style: TextStyle(
            fontSize: 21,
            color: Style().dadolGrey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          AppLocalization.of(context).explainWhy,
          style: TextStyle(fontSize: 18, color: Style().dadolGrey),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget reasonSelector() {
    List<String> reasons = [
      AppLocalization.of(context).deleteReason1,
      AppLocalization.of(context).deleteReason2,
      AppLocalization.of(context).deleteReason3,
      AppLocalization.of(context).deleteReason4,
      AppLocalization.of(context).deleteReason5,
      AppLocalization.of(context).deleteReason6,
      AppLocalization.of(context).deleteReason7,
    ];
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: reasons.map<Widget>((e) {
          return Row(
            children: [
              Checkbox(
                value: checkedReason == e ? true : false,
                shape: CircleBorder(),
                onChanged: (bool value) {
                  setState(() {
                    if (value)
                      checkedReason = e;
                    else
                      checkedReason = "none";
                  });
                },
              ),
              Flexible(
                  child: Text(e,
                      style:
                          TextStyle(fontSize: 18, color: Style().dadolGrey))),
            ],
          );
        }).toList());
  }

  Widget otherInputBox() {
    return TextField(
      controller: _reasonController,
      style: TextStyle(color: Style().dadolGrey),
      decoration: InputDecoration(
        prefixIcon: Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              AppLocalization.of(context).explainWhy,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Style().dadolGrey),
            )),

        //prefix: Text("Oggetto: ", style: TextStyle(fontWeight: FontWeight.bold),)
      ),
    );
  }

  Widget deleteAccount() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Text(
        AppLocalization.of(context).deleteAccount,
        style: TextStyle(color: Colors.red, fontSize: 24),
      ),
      onPressed: () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalization.of(context).deleteAccountTitle),
                content: Text(AppLocalization.of(context).deleteAccountContent),
                actions: [
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalization.of(context).cancel)),
                  FlatButton(
                      onPressed: () async {
                        final HttpsCallable f = FirebaseFunctions.instanceFor(
                                region: "europe-west1")
                            .httpsCallable("delete_account");

                        await f.call(<String, dynamic>{
                          "motivation":
                              checkedReason + " " + _reasonController.text
                        });
                        FirebaseAnalytics().logEvent(
                            name: 'account_deletion',
                            parameters: {"uid": currentUser.uid});
                        currentUser.forceUserLogout();
                        Phoenix.rebirth(context);
                      },
                      child: Text(AppLocalization.of(context).continue_))
                ],
              );
            });
      },
    );
  }
}
