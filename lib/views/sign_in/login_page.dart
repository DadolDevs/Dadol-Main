import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:feelingapp/includes/auth.dart';
import 'package:feelingapp/includes/reward/reward.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/sign_in/widgets/bottom_forward_backward.dart';
import 'package:feelingapp/views/sign_in/widgets/email_selector.dart';
import 'package:feelingapp/views/sign_in/widgets/password_selector.dart';
import 'package:feelingapp/views/sign_in/widgets/promo_code_selector.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  //final BaseAuth auth;
  //final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginPage> {
  String _email;
  String _password;
  String _passwordConfirmation;
  String _inviteCode;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;

  bool forwardAdvanceEnabled = false;

  bool passwordRecoveryState = false;
  bool passwrordResetSent = false;

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    String userId = "";
    try {
      if (_isLoginForm) {
        userId = await auth.signIn(_email, _password);
        final HttpsCallable logoutFunction =
            FirebaseFunctions.instanceFor(region: "europe-west1")
                .httpsCallable("user_logged_in");

        await logoutFunction.call(
            <String, dynamic>{"fcmToken": pushNotificationService.fcmToken});
        userId = await auth.signIn(_email, _password);

        debugPrint('Signed in: $userId');
        Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
        //Navigator.pushReplacementNamed(context, '/root');
      } else {
        userId = await auth.signUp(_email, _password);

        await _requestPromoCode();
        print(_inviteCode);
        debugPrint('Signed up currentUser: $userId');
        await dbManager.createNewUser(userId,_inviteCode);
        //Navigator.pushReplacementNamed(context, '/root');
        Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (e.code == "network-request-failed") {
        _errorMessage = AppLocalization.of(context).errorBadInternet;
      } else if (e.code == "email-already-in-use") {
        _errorMessage = AppLocalization.of(context).errorMailinUse;
      } else {
        _errorMessage = AppLocalization.of(context).errorWrongCredentials;
      }
      setState(() {
        _isLoading = false;
        //_errorMessage = e.message;
      });
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = false;
    auth = EmailAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget beatingLogo = HeartbeatProgressIndicator(
      child: Image.asset("assets/images/logo_main.png"),
      startScale: 0.4,
      endScale: 0.5,
    );

    return new Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            child: Stack(children: [
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
              SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(height: 30),
                  _logingRegisterButtons(),
                  SizedBox(height: 30),
                  _isLoginForm ? _showSinginForm() : _showSingupForm()
                ]),
              ),
              Positioned(
                child: _advanceLoginRegisterButtons(),
                width: MediaQuery.of(context).size.width,
                bottom: 10,
              ),
              _isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.7),
                      child: beatingLogo,
                    )
                  : Container(),
            ]),
            onWillPop: () => _onBackButtonDuringLoading()));
  }

  Future<bool> _onBackButtonDuringLoading() {
    if (_isLoading) return Future.value(false);
    return Future.value(false);
  }

  Widget _showError() {
    return Text(
      _errorMessage,
      style: TextStyle(color: Colors.red, fontSize: 18),
    );
  }

  Widget _logingRegisterButtons() {
    return Row(children: [
      SizedBox(width: 20),
      FlatButton(
          onPressed: () {
            setState(() {
              _errorMessage = "";
              _isLoginForm = false;
            });
          },
          child: Text(
            AppLocalization.of(context).register,
            style: TextStyle(
              color: Colors.white,
              fontSize: _isLoginForm ? 20 : 34,
            ),
          )),
      Spacer(),
      FlatButton(
          onPressed: () {
            _errorMessage = "";
            setState(() {
              _isLoginForm = true;
            });
          },
          child: Text(
            AppLocalization.of(context).login,
            style: TextStyle(
              color: Colors.white,
              fontSize: _isLoginForm ? 34 : 20,
            ),
          )),
      SizedBox(width: 20),
    ]);
  }

  Widget _advanceLoginRegisterButtons() {
    return AdvanceLoginRegisterBar(
      backEnabled: true,
      forwardEnabled: forwardAdvanceEnabled,
      addShadows : false,
      buttonPressedCallback: (button) {
        if (button == 0)
          Navigator.of(context).pop();
        else
          setState(() {
            _isLoading = true;
            validateAndSubmit();
          });
      },
    );
  }

  Widget _showPasswordRecoveryPage() {
    return Container(
        padding: EdgeInsets.only(top: 30, left: 40, right: 40),
        child: Column(
          children: [
            EmailSelector(
                onSubmittedCallback: selectorsCallback,
                onChangedCallback: emailChangedCallback),
            SizedBox(height: 10),
            resetPasswordButton(),
            SizedBox(height: 10),
            forgotPassowrdButton(),
            SizedBox(height: 100),
          ],
        ));
  }

  void emailChangedCallback(String email) {
    _email = email;
    selectorsCallback({});
  }

  Widget _showSinginForm() {
    return passwordRecoveryState
        ? _showPasswordRecoveryPage()
        : Container(
            padding: EdgeInsets.only(top: 30, left: 40, right: 40),
            child: Column(
              children: [
                EmailSelector(
                  onChangedCallback: emailChangedCallback,
                ),
                PasswordSelector(
                  onChangedCallback: passwordChangedCallback,
                ),
                SizedBox(height: 50, child: _showError()),
                forgotPassowrdButton(),
                SizedBox(height: 100),
              ],
            ));
  }

  Widget resetPasswordButton() {
    return GestureDetector(
        onTap: () {
          auth.sendPasswordReset(_email);
          setState(() {
            passwrordResetSent = true;
          });
        },
        child: Column(
          children: [
            Text(
              AppLocalization.of(context).resetPassowrd,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 15),
            passwrordResetSent
                ? Text(
                    "We have sent you an email with instructions to reset your password",
                    style: TextStyle(
                        color: Colors.white,
                        shadows: Style().textOutlineWithShadows))
                : SizedBox()
          ],
        ));
  }

  Widget forgotPassowrdButton() {
    String buttonText = (passwordRecoveryState
        ? AppLocalization.of(context).backToLogin
        : AppLocalization.of(context).forgotPassowrd);
    return GestureDetector(
        onTap: () {
          setState(() {
            passwordRecoveryState = !passwordRecoveryState;
          });
        },
        child: Text(buttonText,
            style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold)));
  }

  void confirmPasswordChangedCallback(String text) {
    _passwordConfirmation = text;
    selectorsCallback({});
  }

  void confirmPromoCodeChangedCallback(String text) {
    _inviteCode = text;
    selectorsCallback({});
  }

  void passwordChangedCallback(String text) {
    _password = text;
    selectorsCallback({});
  }


  //String inviteCode = "";
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

          String inviteCode = "";
          return StatefulBuilder(builder: (context, setState) {
            void confirmPromoCodeChangedCallback(String text) {
              setState(() {
                inviteCode = text;
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
                          onSubmittedCallback: (text) {

                          },
                        ),
                        FloatingActionButton.extended(
                          backgroundColor: inviteCode.length == 6
                              ? Color.fromRGBO(20, 160, 183, 1)
                              : Colors.redAccent,
                          onPressed: () {
                            _inviteCode = inviteCode;
                            Navigator.pop(context);
                          },
                          icon: inviteCode.length == 6
                              ? Icon(Icons.connect_without_contact)
                              : Icon(Icons.close),
                          label: Text(
                            inviteCode.length == 6
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

  Widget _showSingupForm() {
    return Container(
        padding: EdgeInsets.only(top: 30, left: 40, right: 40),
        child: Column(
          children: [
            SizedBox(height: 20, child: _showError()),
            EmailSelector(
              onChangedCallback: emailChangedCallback,
            ),
            PasswordSelector(
              onChangedCallback: passwordChangedCallback,
            ),
            _isLoginForm
                ? SizedBox()
                : PasswordSelector(
                    onChangedCallback: confirmPasswordChangedCallback,
                    matchAgainst: _password != null ? _password : "",
                  ),
            _isLoginForm ? SizedBox() : SizedBox(height: 10),
            SizedBox(height: 50, child: _showError()),

          ],
        ));
  }

  void selectorsCallback(data) {
    setState(() {
      forwardAdvanceEnabled = false;
    });
    if (EmailValidator.validate(_email) &&
        _password != null &&
        _password.length >= 6) {
      if (_isLoginForm == true) {
        setState(() {
          forwardAdvanceEnabled = true;
        });
      } else {
        if (_password == _passwordConfirmation)
          setState(() {
            forwardAdvanceEnabled = true;
          });
      }
    }
  }

  void confirmPasswordCallback(data) {
    if (data.containsKey("password")) _passwordConfirmation = data["password"];
    selectorsCallback({});
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return SizedBox();
    }
  }
}
