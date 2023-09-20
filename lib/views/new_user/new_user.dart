import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/blocs/playback/playback_bloc.dart';
import 'package:feelingapp/includes/preview_video.dart';
import 'package:feelingapp/includes/stream_messages.dart';
import 'package:feelingapp/includes/user.dart';
import 'package:feelingapp/includes/video_player.dart';
import 'package:feelingapp/main.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/profile/widgets/birth_selector.dart';
import 'package:feelingapp/views/profile/widgets/gender_preference_selector.dart';
import 'package:feelingapp/views/profile/widgets/gender_selector.dart';
import 'package:feelingapp/views/profile/widgets/nickname_selector.dart';
import 'package:feelingapp/views/profile/widgets/tag_selection_page.dart';
import 'package:feelingapp/views/sign_in/widgets/bottom_forward_backward.dart';
import 'package:feelingapp/views/sign_in/widgets/phone_selector.dart';
import 'package:feelingapp/views/sign_in/widgets/sms_code_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';

enum Stages {
  Bio,
  Video,
  PreviewStage,
}

class NewUserScreen extends StatefulWidget {
  @override
  _NewUserScreenState createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  var _pageViewController = PageController();
  int currentPage;

  bool _nicknameHasErrors = false;
  bool _ageHasErrors = false;
  bool _nicknameCompleted = false;
  bool _phoneVerified = false;
  bool _ageCompleted = false;
  bool _conditionsAccepted = false;
  bool _endRegistrationEnabled = false;
  bool isAnyTagSelected = false;
  StreamController<StreamMessage> videoControls;


  @override
  void initState() {
    super.initState();
    currentPage = 0;
    if (currentUser.userName != "") {
      _nicknameCompleted = true;
    }
    if (currentUser.birthDate != Timestamp.fromMillisecondsSinceEpoch(0)) {
      _ageCompleted = true;
    }

    if (currentUser.additionalTags.length > 0) {
      isAnyTagSelected = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: pageViewBuilder()));
  }

  Widget pageViewBuilder() {
    return Stack(
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
        SingleChildScrollView(
            child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height * 1,
              child: PageView(
                controller: _pageViewController,
                physics: new NeverScrollableScrollPhysics(),
                children: <Widget>[
                  buildPhoneValidator(),
                  buildBioSelection(),
                  buildTagSelection(),
                  buildVideoSelection(),
                  buildPreview(),
                ],
              )),
          //buildBottomNavigationBar()
        ])),
        _showNav(),
        _showEndRegsitration(
            enabled: _endRegistrationEnabled && currentPage == 2),
      ],
    );
  }

  Widget _showEndRegsitration({bool enabled = false}) {
    if (enabled == false) {
      return SizedBox();
    }
    return Column(
      children: [
        Spacer(),
        Row(
          children: [
            Spacer(),
            FlatButton(
                onPressed: () {
                  completeRegistration();
                },
                child: Text(
                  !isAnyTagSelected
                      ? AppLocalization.of(context).skip
                      : AppLocalization.of(context).continue_,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                )),
          ],
        ),
        SizedBox(height: 30)
      ],
    );
  }

  Widget buildTagSelection() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.04),
        Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(AppLocalization.of(context).telltags,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center))),
        Spacer(),
        UserTagSelectorWidget(
          registration: false,
          onSubmittedCallback: () {
            setState(() {
              isAnyTagSelected = true;
            });
          },
          withTutorial: true,
        ),
        Spacer(),
        SizedBox(height: 85),
      ],
    ));
  }

  Widget _showNav() {
    return Container(
        padding: EdgeInsets.only(top: 30, left: 10, right: 20),
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              AdvanceLoginRegisterBar(
                backEnabled: currentPage == 0 ? false : true,
                forwardEnabled: forwardButtonEnabled(),
                addShadows: false,
                buttonPressedCallback: (button) {
                  if (button == 0) {
                    // back
                    _pageViewController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                    setState(() {
                      currentPage--;
                    });
                  } else {
                    // forward
                    _pageViewController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                    setState(() {
                      currentPage++;
                    });
                  }
                },
              ),
            ]));
  }

  bool forwardButtonEnabled() {
    debugPrint(_ageCompleted.toString());
    switch (currentPage) {
      case 0: // User data
        {
          if (_phoneVerified) {
            return true;
          }
          break;
        }
      case 1: // User data
        {
          if (_nicknameCompleted && _ageCompleted && _conditionsAccepted) {
            return true;
          }
          break;
        }
      case 2: // Tags
        setState(() {
          _endRegistrationEnabled = true;
        });
        return false;
        break;
      case 3: // Video upload
        setState(() {
          _endRegistrationEnabled = true;
        });
        return false;
        break;
      default:
        {
          return true;
        }
    }
    return false;
  }

  validatorCallback(data) {
    if (data.containsKey("nickname")) {
      if (data['nickname'].length < 3) {
        setState(() {
          _nicknameHasErrors = true;
          _nicknameCompleted = false;
        });
      } else {
        setState(() {
          _nicknameHasErrors = false;
          _nicknameCompleted = true;
        });
      }
    }
    if (data.containsKey("birthdate") && data["birthdate"] != null) {
      if (calculateAge(data["birthdate"]) >= 18) {
        setState(() {
          _ageHasErrors = false;
          _ageCompleted = true;
        });
      } else {
        setState(() {
          _ageHasErrors = true;
          _ageCompleted = false;
        });
      }
    }
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

String phone;
  String verifyId;
  bool codeSent = false;
  Widget buildPhoneValidator() {
    return Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Lottie.asset('assets/lottie/verified.json',
                alignment: Alignment.center,
                animate: true,
                fit: BoxFit.fill,
                width:
                MediaQuery.of(context).size.width * 0.65),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              AppLocalization.of(context).phoneCaptionSub,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            PhoneSelector(
              onChangedCallback: (text) {
                print(text);
                phone = text;
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                            },
                            verificationFailed:
                                (FirebaseAuthException
                            authException) {
                              print(authException.message);
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
                        AppLocalization.of(context).sendCode,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            SMSCodeSelector(
              onSubmittedCallback: (text) async {
                if (validating) {
                  return;
                }
                validating = true;
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
                    if (!_phoneVerified) {
                      _phoneValid();
                    }
                    setState(() {
                      _phoneVerified = true;
                    });
                  }
                } catch (ex) {
                  if (ex.code ==
                      "credential-already-in-use") {
                    _phoneNotValid();
                  }
                  if (ex.code ==
                      "invalid-verification-code") {
                    _smsCodeNotValid();
                  }
                  print(ex);
                }finally{
                  validating = false;
                }
              },
            ),
            Spacer(),
          ],
        ));
  }
bool validating = false;

  Future _phoneValid() {
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
                          Lottie.asset('assets/lottie/smiley.json',
                              alignment: Alignment.center,
                              animate: true,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width * 0.35),
                          SizedBox.fromSize(
                            size: Size(
                                0, MediaQuery.of(context).size.height * 0.03),
                          ),
                          Text(
                            "Ok",
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
                            AppLocalization.of(context).phoneValid,
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

  Widget buildBioSelection() {
    return Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(AppLocalization.of(context).tellusabout,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center))),
            Spacer(),
            NicknameSelector(
              onSubmittedCallback: validatorCallback,
              hasErrors: _nicknameHasErrors,
              registration: true,
            ),
            SizedBox(height: 10),
            GenderSelector(
              onSubmittedCallback: () {},
              registration: true,
            ),
            Spacer(),
            BirthSelector(
                registration: true,
                onSubmittedCallback: validatorCallback,
                hasErrors: _ageHasErrors),
            SizedBox(height: 10),
            GenderPreferenceSelector(
              onSubmittedCallback: () {},
              registration: true,
            ),
            SizedBox(height: 30),
            _privacyBox(),
            SizedBox(height: 85),
            Spacer(),
          ],
        ));
  }

  Widget _privacyBox() {
    TextStyle defaultStyle =
        TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Comfortaa");
    TextStyle linkStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontFamily: "Comfortaa",
      decoration: TextDecoration.underline,
    );
    if (AppLocalization.of(context).locale.languageCode == "it")
      return Row(children: [
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.white),
          child: Checkbox(
            value: _conditionsAccepted,
            onChanged: (value) {
              setState(() {
                _conditionsAccepted = value;
              });
            },
            checkColor: Colors.white,
            activeColor: Style().dazzlePrimaryColor,
          ),
        ),
        Flexible(
            child: RichText(
          text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              TextSpan(text: 'Ho letto e accettato  '),
              TextSpan(
                  text: 'l\'informativa sulla privacy',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch(
                          "https://www.dadol.it//privacy-policy")) {
                        await launch("https://www.dadol.it//privacy-policy");
                      }
                    }),
              TextSpan(text: ' e i '),
              TextSpan(
                  text: 'termini e le condizioni',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch(
                          "https://www.dadol.it//termini-di-servizio")) {
                        await launch(
                            "https://www.dadol.it//termini-di-servizio");
                      }
                    }),
            ],
          ),
        )),
      ]);
    else
      return Row(children: [
        Theme(
          data: ThemeData(unselectedWidgetColor: Colors.white),
          child: Checkbox(
            value: _conditionsAccepted,
            onChanged: (value) {
              setState(() {
                _conditionsAccepted = value;
              });
            },
            checkColor: Colors.white,
            activeColor: Style().dazzlePrimaryColor,
          ),
        ),
        Flexible(
            child: RichText(
          text: TextSpan(
            style: defaultStyle,
            children: <TextSpan>[
              TextSpan(text: 'I have read and accepted the '),
              TextSpan(
                  text: 'privacy notice',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch(
                          "https://www.dadol.it//privacy-policy")) {
                        await launch("https://www.dadol.it//privacy-policy");
                      }
                    }),
              TextSpan(text: ' and agreed to the '),
              TextSpan(
                  text: 'terms of use',
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (await canLaunch(
                          "https://www.dadol.it//termini-di-servizio")) {
                        await launch(
                            "https://www.dadol.it//termini-di-servizio");
                      }
                    }),
            ],
          ),
        )),
      ]);
  }

  Widget buildPreview() {
    videoControls = StreamController<StreamMessage>.broadcast();

    var videoPlayer = Container(
        child: Stack(children: [
      ClipRRect(
          //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          child: BlocProvider(
            create: (BuildContext context) => PlaybackBloc(),
            child: UserVideoPlayer(
        isLooping: false,
        showReplay: true,
        overLayInformation: currentUser.toMap(),
        parentEvents: videoControls.stream,
      ),
          ))
    ]));
    return videoPlayer;
  }

  Widget buildVideoSelection() {
    return Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.15,
          right: MediaQuery.of(context).size.width * 0.15,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text(AppLocalization.of(context).askForVideoPresentation,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        shadows: Style().textOutlineWithShadows),
                    textAlign: TextAlign.center)),
            Spacer(),
            Text(
              AppLocalization.of(context).askForVideoPresentationSubtitle,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  shadows: Style().textOutlineWithShadows),
              textAlign: TextAlign.center,
            ),
            videoSourceSelection(),
            Spacer(),
          ],
        ));
  }

  Widget videoSourceSelection() {
    final cameraIcon = Column(children: [
      IconButton(
          iconSize: 40,
          icon: Icon(Icons.camera, color: Colors.white),
          onPressed: () {
            openCamera();
          }),
      Text(
        AppLocalization.of(context).record,
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            shadows: Style().textOutlineWithShadows),
        textAlign: TextAlign.center,
      ),
    ]);

    final uploadIcon = Column(children: [
      IconButton(
          iconSize: 40,
          icon: Icon(Icons.file_upload, color: Colors.white),
          onPressed: () {
            uploadFile();
          }),
      Text(
        AppLocalization.of(context).upload,
        style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            shadows: Style().textOutlineWithShadows),
        textAlign: TextAlign.center,
      ),
    ]);

    return Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
        child: Row(
          children: <Widget>[cameraIcon, SizedBox(width: 30), uploadIcon],
          mainAxisAlignment: MainAxisAlignment.center,
        ));
  }

  void openCamera() async {
    await Navigator.push(context, Routes().cameraRoute(RouteSettings()));
    // Need to perform check whether the video has been uploaded correctly
    completeRegistration();
  }

  void completeRegistration() async {
    await currentUser.updateRegistrationStage(
        RegistrationStage.REGSITERED_WITHOUT_THE_TUTORIAL.index);
    Navigator.pushNamedAndRemoveUntil(context, '/root', (route) => false);
  }

  void uploadFile() async {
    ImagePicker _picker = ImagePicker();
    PickedFile file = await _picker.getVideo(source: ImageSource.gallery);

    if (file == null) return;

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewVideo(
            videoPreviewPath: file.path,
          ),
        ));

    completeRegistration();
  }



  @override
  void dispose() {
    super.dispose();
    videoControls.close();
  }
}
