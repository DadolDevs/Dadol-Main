import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/blocs/invite_page/invite_page_bloc.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/sign_in/widgets/email_selector.dart';
import 'package:feelingapp/views/sign_in/widgets/phone_selector.dart';
import 'package:feelingapp/views/sign_in/widgets/promo_code_selector.dart';
import 'package:feelingapp/views/sign_in/widgets/sms_code_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:share/share.dart';
import '../../main.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({Key key}) : super(key: key);

  @override
  _InvitePageState createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  InvitePageBloc _invitePageBloc;

  @override
  void initState() {
    _invitePageBloc = InvitePageBloc();
    if (currentUser.promoCode.isEmpty) {
      _invitePageBloc.add(CreateCode());
    }
    super.initState();
  }

  @override
  void dispose() {
    _invitePageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.of(context).invite.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      SizedBox.fromSize(
                        size:
                            Size(0, MediaQuery.of(context).size.height * 0.01),
                      ),
                      Text(
                        getTitleInvite(context),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromRGBO(20, 160, 183, 1)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: Size(0, MediaQuery.of(context).size.height * 0.02),
              ),
              getLottie(context),
              SizedBox.fromSize(
                size: Size(0, MediaQuery.of(context).size.height * 0.03),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Text(
                  AppLocalization.of(context)
                      .inviteHeader
                      .replaceFirst("[[inviteReward]]", getInviteReward()),
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromRGBO(96, 96, 96, 1),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox.fromSize(
                size: Size(0, MediaQuery.of(context).size.height * 0.03),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  FloatingActionButton.extended(
                    backgroundColor: Color.fromRGBO(20, 160, 183, 1),
                    onPressed: () {
                      Share.share(
                          AppLocalization.of(context).shareCaption.replaceAll(
                                  "[[subscriptionReward]]",
                                  getSubscriptionReward()) +
                              "\n" +
                              "\n" +
                              "iOS: ${AppLocalization.of(context).shareiOS}" +
                              "\n" +
                              "\n" +
                              "Android: ${AppLocalization.of(context).shareDroid}" +
                              "\n" +
                              "\n" +
                              "${AppLocalization.of(context).promoCode}: ${currentUser.promoCode}",
                          subject: serverSettings.shareTitle);
                    },
                    icon: Icon(Icons.share),
                    label: Text(AppLocalization.of(context).invite),
                  ),
                  /* AbsorbPointer(
                    absorbing: currentUser.couponState == "Pending",
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.green[600],
                      onPressed: () async {
                        if (currentUser.accountState == "ActiveWithVideo") {
                          if (currentUser.reward != null) {
                            if (currentUser.reward.cumulated >= 5) {
                              FirebaseAuth auth = FirebaseAuth.instance;
                              if (auth.currentUser.phoneNumber != null &&
                                  auth.currentUser.phoneNumber != "")
                                await _alreadyGotPhoneCheckout();
                              else
                                await _confirmCheckout();
                            } else {
                              await _notEnoughReward();
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content:
                                Text(AppLocalization.of(context).missingVideo),
                          ));
                        }
                      },
                      icon: currentUser.couponState == "Pending"
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Icon(Icons.redeem),
                      label: currentUser.couponState == "Pending"
                          ? Text(AppLocalization.of(context).processing)
                          : Text(AppLocalization.of(context).checkoutAmz),
                    ),
                  ), */
                ],
              ),
              SizedBox.fromSize(
                size: Size(0, MediaQuery.of(context).size.height * 0.03),
              ),
              BlocBuilder(
                bloc: _invitePageBloc,
                builder: (BuildContext context, InvitePageState state) {
                  return Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${AppLocalization.of(context).promoCode}:",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox.fromSize(
                          size: Size(10, 0),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: currentUser.promoCode.toUpperCase()));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Style().dazzleSecondaryColor,
                              content: Text(AppLocalization.of(context)
                                  .copiedToClipboard),
                            ));
                          },
                          child: Text(
                            currentUser.promoCode.toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                color: Color.fromRGBO(20, 160, 183, 1)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox.fromSize(
                size: Size(0, MediaQuery.of(context).size.height * 0.02),
              ),
              IntrinsicHeight(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  currentUser.reward != null
                                      ? currentUser.reward.subscribed.toString()
                                      : "0",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox.fromSize(
                                  size: Size(
                                      0,
                                      MediaQuery.of(context).size.height *
                                          0.01),
                                ),
                                Text(
                                  AppLocalization.of(context).subscribedFriends,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          )),
                      VerticalDivider(
                        width: 1,
                        thickness: 0.5,
                        indent: 4,
                        endIndent: 4,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  "${currentUser.reward != null ? currentUser.reward.cumulated.toString() : 0.0}€",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color.fromRGBO(20, 160, 183, 1)),
                                ),
                                SizedBox.fromSize(
                                  size: Size(
                                      0,
                                      MediaQuery.of(context).size.height *
                                          0.01),
                                ),
                                Text(
                                  AppLocalization.of(context).amznBonus,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: Size(0, MediaQuery.of(context).size.height * 0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTitleInvite(BuildContext context) {
    if (currentUser.reward != null) {
      if (currentUser.reward.currentSpecial != null) {
        return currentUser.reward.currentSpecial.specialCaptions
            .firstWhere((element) =>
                element.locale ==
                AppLocalization.of(context).locale.languageCode)
            .caption
            .toUpperCase();
      }
    }

    return AppLocalization.of(context).friends.toUpperCase();
  }

  String getSubscriptionReward() {
    if (currentUser.reward != null) {
      if (currentUser.reward.currentSpecial != null) {
        return currentUser.reward.currentSpecial.subscriptionReward.toString();
      } else {
        return currentUser.reward.subscriptionReward.toString();
      }
    } else {
      return "2.0€";
    }
  }

  String getInviteReward() {
    if (currentUser.reward != null) {
      if (currentUser.reward.currentSpecial != null) {
        return currentUser.reward.currentSpecial.inviteReward.toString();
      } else {
        return currentUser.reward.inviteReward.toString();
      }
    } else {
      return "N/A";
    }
  }

  LottieBuilder getLottie(BuildContext context) {
    if (currentUser.reward != null) {
      if (currentUser.reward.currentSpecial != null) {
        return Lottie.network(currentUser.reward.currentSpecial.lottieUrl,
            alignment: Alignment.center,
            animate: true,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width * 0.85);
      } else
        return Lottie.asset('assets/lottie/friends.json',
            alignment: Alignment.center,
            animate: true,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width * 0.95);
    }
  }

  Future _requestSent() {
    return showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(00),
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/fireworks.json',
                          alignment: Alignment.center,
                          animate: true,
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width * 0.55),
                      SizedBox.fromSize(
                        size:
                            Size(0, MediaQuery.of(context).size.height * 0.05),
                      ),
                      Text(
                        AppLocalization.of(context).couponProcessing,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox.fromSize(
                        size:
                            Size(0, MediaQuery.of(context).size.height * 0.05),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "OK",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                    ],
                  ),
                ),
              ));
        });
  }

  Future<void> _notEnoughReward() async {
    return showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(00),
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/share.json',
                          alignment: Alignment.center,
                          animate: true,
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width * 0.35),
                      SizedBox.fromSize(
                        size:
                            Size(0, MediaQuery.of(context).size.height * 0.05),
                      ),
                      Text(
                        AppLocalization.of(context).minGiftRequired.replaceAll(
                            "[[inviteReward]]",
                            currentUser.reward != null
                                ? currentUser.reward.inviteReward.toString()
                                : "0.0"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox.fromSize(
                        size:
                            Size(0, MediaQuery.of(context).size.height * 0.05),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "OK",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                    ],
                  ),
                ),
              ));
        });
  }

  Future _phoneNotValid() {
    return showDialog(
        useSafeArea: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(00),
                child: Container(
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.7)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/sad_smiley.json',
                              alignment: Alignment.center,
                              animate: true,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width * 0.35),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            AppLocalization.of(context).ops,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Style().dazzlePrimaryColor,
                                fontSize: 60),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            AppLocalization.of(context).phoneNotValid,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalization.of(context).okCompleted,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          });
        });
  }

  Future _smsCodeNotValid() {
    return showDialog(
        useSafeArea: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(00),
                child: Container(
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.7)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/sad_smiley.json',
                              alignment: Alignment.center,
                              animate: true,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width * 0.35),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            AppLocalization.of(context).ops,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Style().dazzlePrimaryColor,
                                fontSize: 60),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            AppLocalization.of(context).smsNotValid,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalization.of(context).okCompleted,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          });
        });
  }

  Future _confirmCheckout() {
    String phone = "";
    return showDialog(
        useSafeArea: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          bool codeSent = false;
          String verifyId;
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(00),
                child: Scaffold(
                  body: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration:
                        BoxDecoration(color: Colors.black.withOpacity(0.7)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/lottie/fireworks.json',
                                alignment: Alignment.center,
                                animate: true,
                                fit: BoxFit.fill,
                                width:
                                    MediaQuery.of(context).size.width * 0.65),
                            SizedBox.fromSize(
                              size: Size(
                                  0, MediaQuery.of(context).size.height * 0.03),
                            ),
                            Text(
                              AppLocalization.of(context).youEntitled,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 26),
                            ),
                            SizedBox.fromSize(
                              size: Size(
                                  0, MediaQuery.of(context).size.height * 0.03),
                            ),
                            Text(
                              "${currentUser.reward.cumulated.toString()}€",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Style().dazzlePrimaryColor,
                                  fontSize: 60),
                            ),
                            SizedBox.fromSize(
                              size: Size(
                                  0, MediaQuery.of(context).size.height * 0.03),
                            ),
                            Visibility(
                              visible: codeSent,
                              child: Text(
                                AppLocalization.of(context)
                                    .validationCodeRequired,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                            Visibility(
                              visible: !codeSent,
                              child: Text(
                                AppLocalization.of(context).missingPhone,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                            SizedBox.fromSize(
                              size: Size(
                                  0, MediaQuery.of(context).size.height * 0.05),
                            ),
                            Visibility(
                              visible: codeSent,
                              child: SMSCodeSelector(
                                onSubmittedCallback: (text) async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  String smsCode = text;
                                  try {
                                    var _credential =
                                        PhoneAuthProvider.credential(
                                            verificationId: verifyId,
                                            smsCode: smsCode);

                                    await auth.currentUser
                                        .updatePhoneNumber(_credential);

                                    if (auth
                                        .currentUser.phoneNumber.isNotEmpty) {
                                      Navigator.pop(context);
                                      couponCheckout();
                                    }
                                  } catch (ex) {
                                    if (ex.code ==
                                        "credential-already-in-use") {
                                      Navigator.of(context).pop();
                                      _phoneNotValid();
                                    }
                                    if (ex.code ==
                                        "invalid-verification-code") {
                                      Navigator.of(context).pop();
                                      _smsCodeNotValid();
                                    }
                                    print(ex);
                                  }
                                },
                              ),
                            ),
                            Visibility(
                              visible: !codeSent,
                              child: PhoneSelector(
                                onChangedCallback: (text) {
                                  print(text);
                                  phone = text;
                                },
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        AppLocalization.of(context).cancel,
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      if (phone.isNotEmpty) {
                                        FirebaseAuth _auth =
                                            FirebaseAuth.instance;
                                        _auth.verifyPhoneNumber(
                                            phoneNumber: phone,
                                            timeout: Duration(seconds: 120),
                                            verificationCompleted:
                                                (PhoneAuthCredential
                                                    authCredential) {
                                              print("completed");
                                              Navigator.pop(context);
                                            },
                                            verificationFailed:
                                                (FirebaseAuthException
                                                    authException) {
                                              print(authException.message);
                                              Navigator.pop(context);
                                            },
                                            codeSent: (String verificationId,
                                                [int forceResendingToken]) {
                                              print("codeSent");
                                              setState(() {
                                                verifyId = verificationId;
                                                codeSent = true;
                                              });
                                            },
                                            codeAutoRetrievalTimeout: null);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        AppLocalization.of(context).continue_,
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
          });
        });
  }

  Future _alreadyGotPhoneCheckout() {
    return showDialog(
        useSafeArea: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/fireworks.json',
                              alignment: Alignment.center,
                              animate: true,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width * 0.65),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            AppLocalization.of(context).youEntitled,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            "${currentUser.reward.cumulated.toString()}€",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Style().dazzlePrimaryColor,
                                fontSize: 60),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalization.of(context).cancel,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    couponCheckout();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalization.of(context).continue_,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          });
        });
  }

  Future<void> couponCheckout() async {
    String selectedMail = "";
    await showDialog(
        useSafeArea: false,
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            String tmpMail = "";
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/reward_mail.json',
                              alignment: Alignment.center,
                              animate: true,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width * 0.85),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            AppLocalization.of(context).inputRewardMail,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 26),
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          EmailSelector(
                            onChangedCallback: (text) {
                              tmpMail = text;
                            },
                            onSubmittedCallback: (text) {
                              selectedMail = tmpMail;
                              currentUser.updateRewardMail(tmpMail);
                            },
                          ),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalization.of(context).cancel,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    //qui invio la richiesta
                                    if (RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(selectedMail)) {
                                      currentUser.checkoutCoupon();
                                      Navigator.pop(context);
                                      _requestSent();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalization.of(context).continue_,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          });
        }).then((value) => setState(() {}));
  }
}
