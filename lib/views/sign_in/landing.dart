import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/includes/auth.dart';
import 'package:feelingapp/includes/reward/reward.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/views/sign_in/widgets/promo_code_selector.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../routes.dart';

class LandingPage extends StatefulWidget {
  final auth;
  LandingPage({@required this.auth});

  @override
  State<StatefulWidget> createState() => new LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(1.0, -1.0),
            end: Alignment(-1.0, 1.0),
            colors: [
              Color.fromRGBO(0, 230, 217, 1),
              Color.fromRGBO(20, 160, 183, 1)
            ],
            //stops: [0.8, 0.96, 0.74, 0.22, 0.85],
          ),
        )),
        Column(
          children: [
            SizedBox(height: 0.25 * MediaQuery.of(context).size.height),
            Container(
                width: MediaQuery.of(context).size.width * 1,
                child: SizedBox()),
            Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                child: Image.asset(
                  "assets/images/launcher_logo_dadol.png",
                  width: MediaQuery.of(context).size.width * 0.4,
                )),
            Spacer(),
          ],
        ),
        Column(
          children: [
            Spacer(),
            Container(
                width: MediaQuery.of(context).size.width * 1,
                child: SizedBox()),
            Container(
                child: Image.asset(
              "assets/images/launcher_writing_dadol.png",
              width: MediaQuery.of(context).size.width * 0.4,
            )),
          ],
        ),
        Column(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 1),
          Spacer(),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: RaisedButton(
                color: Color.fromRGBO(59, 89, 152, 1),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () async {
                  await loginWithFacebook();
                },
                child: Text(AppLocalization.of(context).facebookAccess,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              )),
          SizedBox(
            height: 10,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: RaisedButton(
                color: Colors.redAccent,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () async {
                  await loginWithGoogle();
                },
                child: Text(AppLocalization.of(context).googleAccess,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              )),
          if ((Platform.isIOS && appleSignInAvailable.isAvailable))
            SizedBox(
              height: 10,
            ),
          if ((Platform.isIOS && appleSignInAvailable.isAvailable))
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: RaisedButton(
                  color: Colors.black,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onPressed: () async {
                    await loginWithApple();
                  },
                  child: Text(AppLocalization.of(context).loginWithApple,
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                )),
          SizedBox(
            height: 10,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: RaisedButton(
                color: Colors.white,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () => navigateToEmailLoginPage(),
                child: Text(AppLocalization.of(context).other,
                    style: TextStyle(color: Colors.grey, fontSize: 18)),
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        ])
      ],
    ));
  }

  void navigateToEmailLoginPage() {
    Navigator.push(context, Routes().loginRoute(RouteSettings()));
    return;
  }

  String inviteCode = "";
  Future _requestPromoCode() async {
    final ref = await FirebaseFirestore.instance
        .collection("settings")
        .doc("reward")
        .get();

    Reward tmpReward = Reward.fromMap(ref.data());
    return showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {

          String _inviteCode = "";
          return StatefulBuilder(builder: (context, setState) {
            void confirmPromoCodeChangedCallback(String text) {
              setState(() {
                _inviteCode = text;
              });
            }

            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(00),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.7)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.fromSize(
                          size: Size(
                              0, MediaQuery.of(context).size.height * 0.03),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Text(
                            AppLocalization.of(context).askCodeHeader,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              AppLocalization.of(context)
                                  .askCodeCaption
                                  .replaceFirst("[[subscriptionReward]]", tmpReward.subscriptionReward.toString()),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox.fromSize(
                          size: Size(
                              0, MediaQuery.of(context).size.height * 0.05),
                        ),
                        PromoCodeSelector(
                          onChangedCallback: confirmPromoCodeChangedCallback,
                          onSubmittedCallback: (text) {},
                        ),
                        FloatingActionButton.extended(
                          backgroundColor: _inviteCode.length == 6
                              ? Color.fromRGBO(20, 160, 183, 1)
                              : Colors.redAccent,
                          onPressed: () {
                            inviteCode = _inviteCode;
                            Navigator.pop(context);
                          },
                          icon: _inviteCode.length == 6
                              ? Icon(Icons.connect_without_contact)
                              : Icon(Icons.close),
                          label: Text(
                            _inviteCode.length == 6
                                ? AppLocalization.of(context).continue_
                                : AppLocalization.of(context).noCode,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          });
        });
  }

  Future<void> loginWithGoogle() async {
    try {
      await _requestPromoCode();
      print(inviteCode);

      auth = GoogleAuth();
      var userId = await auth.signIn();
      await dbManager.createNewUser(userId, inviteCode);
      Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
    } catch (e) {
      debugPrint(e);
    }
  }

  Future<void> loginWithFacebook() async {
    try {
      await _requestPromoCode();
      print(inviteCode);

      auth = FacebookAuthenticator();
      var userId = await auth.signUp();
      await dbManager.createNewUser(userId, inviteCode);
      Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
    } catch (e) {
      debugPrint(e);
    }

    /*try {
      auth = FacebookAuthenticator();

      String fbClientID = "831165837664793";
      String fbRedirectUrl =
          "https://www.facebook.com/connect/login_success.html";

      String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomWebView(
                  selectedUrl:
                      'https://www.facebook.com/dialog/oauth?client_id=$fbClientID&redirect_uri=$fbRedirectUrl&response_type=token&scope=email,public_profile,',
                ),
            maintainState: true),
      );
      var userId;
      if (result != null) {
        userId = await auth.signIn(result);
      }
      if (userId == null) {
        return;
      }
      await dbManager.createNewUser(userId);
      Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
    } catch (e) {
      debugPrint(e);
    }*/
  }

  Future<void> loginWithApple() async {
    try {
      await _requestPromoCode();
      print(inviteCode);
      auth = AppleAuth();
      var userId = await auth.signIn();
      await dbManager.createNewUser(userId, inviteCode);
      Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
