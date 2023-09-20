import 'dart:ui';
import 'package:feelingapp/blocs/home_page/home_page_bloc.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/carousel/carousel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/includes/stream_messages.dart';
import 'package:feelingapp/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:lottie/lottie.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bottom_nav.dart';
import 'invite_friends/invite_page.dart';
import 'messages/messages.dart';
import 'profile/profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController bottomNavController;

  GlobalKey _fabKey = GlobalObjectKey("fab");

  var bottomBadge;
  var videoUploadBadge;

  var _carousel;

  HomePageBloc homePageBloc;
  bool carouselReady = true; // TODO: this should be false
  bool displayVideoHint = false;
  bool firstVideo = false;
  PreloadPageController _controller = PreloadPageController(
    initialPage: 1,
  );

  @override
  void initState() {
    super.initState();
    // Test async notification
    /*Future.delayed(Duration(seconds: 5),  () =>
    showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return rewardInfoPopUp();
          },
        )
    );*/

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data['type']);
      if (message.data['type'] == 'video_refused') {
        currentUser.changeAccountState("Active");
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return videoRefusedPopUp();
          },
        );
      }
      if (message.data['type'] == 'video_accepted') {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            currentUser.accountState = "ActiveWithVideo";
            return videoAcceptedPopUp();
          },
        );
      }
      if (message.data['type'] == 'reward_info') {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return rewardInfoPopUp();
          },
        );
      }
      if (message.data['type'] == 'coupon') {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return couponSentPopUp();
          },
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("tapped" + message.data['type']);
      if (message.data['type'] == 'video_refused') {
        currentUser.changeAccountState("Active");
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return videoRefusedPopUp();
          },
        );
      }
      if (message.data['type'] == 'video_accepted') {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            currentUser.accountState = "ActiveWithVideo";
            return videoAcceptedPopUp();
          },
        );
      }
      if (message.data['type'] == 'reward_info') {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return rewardInfoPopUp();
          },
        );
      }
      if (message.data['type'] == 'coupon') {
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return couponSentPopUp();
          },
        );
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        if (message.data['type'] == 'video_refused') {
          currentUser.changeAccountState("Active");
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return videoRefusedPopUp();
            },
          );
        }
        if (message.data['type'] == 'video_accepted') {
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return videoAcceptedPopUp();
            },
          );
        }
        if (message.data['type'] == 'reward_info') {
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return rewardInfoPopUp();
            },
          );
        }
        if (message.data['type'] == 'coupon') {
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return couponSentPopUp();
            },
          );
        }
      }
    });
    bottomNavController =
        TabController(initialIndex: 1, vsync: this, length: 4);
    bottomNavController.addListener(() {
      viewingCarousel = bottomNavController.index == 1;
    });
    pushNotificationService.setNotificationBarCallback(setBottomBadge);
    pushNotificationService.setVideoUploadCallback(setVideoBadge);
    homePageBloc = HomePageBloc(appUser: currentUser);
    _carousel = Carousel(
        pageJumper: mainHomePagePageChanger,
        onFirstVideoLoaded: () {
          setState(() {
            carouselReady = true;
          });
        });
    if (currentUser.mediaUrl == null || currentUser.mediaUrl.isEmpty) {
      firstVideo = true;
    }
  }

  @override
  void dispose() {
    homePageBloc.close();
    super.dispose();
  }

  Widget buildBottomNavBar() {
    return CustomBottomNavigationBar();
  }

  void changeNavBarHighlight(int index) {
    bottomNavController.animateTo(index,
        duration: Duration(milliseconds: 200), curve: Curves.ease);
  }

  void bottomTapped(int index) {
    if (index == 2) {
      setBottomBadge(false);
    }
    _controller.animateToPage(index,
        duration: Duration(milliseconds: 200), curve: Curves.ease);
  }

  void setVideoBadge(enabled) {
    setState(() {
      isVideoUploadRunning = enabled;
    });
    if (enabled) {
      Future.delayed(const Duration(seconds: 4), () => showCoachMarkFAB());
      setState(() {
        videoUploadBadge = Icons.cloud_upload;
      });
    } else {
      if (firstVideo) {
        firstVideo = false;
        Future.delayed(
            const Duration(seconds: 4),
            () => showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return profileCompletedPopUp();
                  },
                ));
      }
      setState(() {
        videoUploadBadge = null;
      });
    }
  }

  Widget profileCompletedPopUp() {
    return Material(
      color: Colors.grey.withOpacity(0.1),
      child: Stack(children: [
        BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: MediaQuery.of(context).size.width,
            )),
        Column(
          children: [
            Spacer(),
            Spacer(),
            Lottie.asset('assets/lottie/smiley.json',
                alignment: Alignment.topLeft,
                animate: true,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.45),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).profileCompleted,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            RaisedButton(
              color: Style().dazzlePrimaryColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).okCompleted,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ]),
    );
  }

  Widget videoRefusedPopUp() {
    return Material(
      color: Colors.grey.withOpacity(0.1),
      child: Stack(children: [
        BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: MediaQuery.of(context).size.width,
            )),
        Column(
          children: [
            Spacer(),
            Spacer(),
            Lottie.asset('assets/lottie/sad_smiley.json',
                alignment: Alignment.topLeft,
                animate: true,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.45),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).videoRefusedTitle,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).videoRefusedBody,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            RaisedButton(
              color: Style().dazzlePrimaryColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () async {
                  _controller.jumpToPage(0);
                  Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).uploadNewVideo,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            RaisedButton(
              color: Style().dazzleSecondaryColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () async {
                await launch(
                    "https://www.dadol.it/requisitidelvideoprofilo");
              },
              child: Text(AppLocalization.of(context).refusedMoreInfo,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ]),
    );
  }

  Widget videoAcceptedPopUp() {
    return Material(
      color: Colors.grey.withOpacity(0.1),
      child: Stack(children: [
        BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: MediaQuery.of(context).size.width,
            )),
        Column(
          children: [
            Spacer(),
            Spacer(),
            Lottie.asset('assets/lottie/smiley.json',
                alignment: Alignment.topLeft,
                animate: true,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.45),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).videoAcceptedTitle,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).videoAcceptedBody,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            RaisedButton(
              color: Style().dazzlePrimaryColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () async {
                Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).okCompleted,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ]),
    );
  }

  Widget rewardInfoPopUp() {
    return Material(
      color: Colors.grey.withOpacity(0.1),
      child: Stack(children: [
        BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: MediaQuery.of(context).size.width,
            )),
        Column(
          children: [
            Spacer(),
            Spacer(),
            Lottie.asset('assets/lottie/share.json',
                alignment: Alignment.topLeft,
                animate: true,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.45),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).rewardInfoTitle,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).rewardInfoBody,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            RaisedButton(
              color: Style().dazzlePrimaryColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () {
                bottomTapped(3);
                Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).okCompleted,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ]),
    );
  }

  Widget couponSentPopUp() {
    return Material(
      color: Colors.grey.withOpacity(0.1),
      child: Stack(children: [
        BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: MediaQuery.of(context).size.width,
            )),
        Column(
          children: [
            Spacer(),
            Spacer(),
            Lottie.asset('assets/lottie/fireworks.json',
                alignment: Alignment.topLeft,
                animate: true,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.45),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).couponSentTitle,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.1),
              child: Text(
                AppLocalization.of(context).couponSentBody,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            RaisedButton(
              color: Style().dazzlePrimaryColor,
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () async {
                setState(() {
                  bottomTapped(1);
                });
                Navigator.pop(context);
              },
              child: Text(AppLocalization.of(context).okCompleted,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ],
        ),
      ]),
    );
  }
  void setBottomBadge(enabled) {
    if (bottomNavController.index == 2) {
      setState(() {
        bottomBadge = null;
      });
      //return;
    }
    setState(() {
      if (enabled) {
        bottomBadge = Colors.redAccent;
      } else {
        bottomBadge = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBody: false,
            bottomNavigationBar: ConvexAppBar.badge(
              {0: videoUploadBadge, 2: bottomBadge},
              badgeMargin: EdgeInsets.fromLTRB(20, 0, 0, 20),
              backgroundColor: Style().dazzlePrimaryColor,
              onTap: (index) {
                bottomTapped(index);
              },
              controller: bottomNavController,
              items: [
                TabItem(
                    icon: Icon(
                      Icons.person,
                      key: _fabKey,
                      color: Colors.white60,
                      size: 25,
                    ),
                    activeIcon: Icon(
                      Icons.person,
                      key: _fabKey,
                      color: Style().dazzlePrimaryColor,
                      size: 40,
                    )),
                TabItem(icon: DadolIcons.x_dadol_logo_toolbar_center),
                TabItem(icon: DadolIcons.x_chat),
                TabItem(icon: DadolIcons.x_invite),
              ],
            ),
            body: BlocProvider(
              create: (BuildContext context) => homePageBloc,
              child: BlocListener(
                bloc: homePageBloc,
                listenWhen: (previous, current) =>
                    current is CompleteProfileHomePageState ||
                    current is ErrorHomePageState,
                listener: (BuildContext context, HomePageState state) {
                  if (state is CompleteProfileHomePageState) {
                    return showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return completeProfilePopUp();
                      },
                    );
                  }
                  if (state is ErrorHomePageState) {
                    return showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Attenzione'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(state.msg),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Chiudi'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Stack(children: [
                  PreloadPageView(
                      controller: _controller,
                      preloadPagesCount: 4,
                      physics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        print("animate to ${index.toString()}");
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        changeNavBarHighlight(index);
                        if (index == 0) {
                          streamController.add(StreamMessage.profile);
                        }
                        if (index == 1) {
                          streamController.add(StreamMessage.carousel);
                        }
                        if (index == 2) {
                          streamController.add(StreamMessage.messages);
                          setBottomBadge(false);
                        }
                        if (index == 3) {
                          streamController.add(StreamMessage.stopCarouselVideo);
                          streamController.add(StreamMessage.stopProfileVideo);
                          //streamController.add(StreamMessage.profile);
                        }
                      },
                      children: [
                        ProfilePage(
                          isEditable: true,
                          autoPlaying: false,
                          showPause: true,
                        ),
                        _carousel,
                        MessagesPage(
                          bottomBadgeSetter: setBottomBadge,
                        ),
                        InvitePage()
                      ]),
                ]),
              ),
            ),
          ),
        ),
        !carouselReady ? buildWaitingScreen() : SizedBox(),
      ],
    );
  }

  void mainHomePagePageChanger(int page) {
    _controller.animateToPage(page,
        duration: Duration(milliseconds: 200), curve: Curves.ease);
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.25,
                right: MediaQuery.of(context).size.width * 0.25),
            child: Image.asset("assets/images/logo_main.png")),
      ),
    );
  }

  void showCoachMarkFAB() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _fabKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
      targetContext: _fabKey.currentContext,
      markRect: markRect,
      children: [
        Center(
            child: Container(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
          ),
          child: Text(AppLocalization.of(context).waitForUpload,
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.white,
              )),
        ))
      ],
      duration: null,
    );
  }

  Widget completeProfilePopUp() {
    return Stack(children: [
      BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            width: MediaQuery.of(context).size.width,
          )),
      Column(
        children: [
          Spacer(),
          Icon(
            DadolIcons.x_exclamation_point,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.3,
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.1,
                left: MediaQuery.of(context).size.width * 0.1),
            child: Text(
              AppLocalization.of(context).uploadVideoToContinueTitle,
              style: TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.1,
                left: MediaQuery.of(context).size.width * 0.1),
            child: Text(
              AppLocalization.of(context).uploadVideoToContinueSubTitle,
              style: TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          RaisedButton(
            color: Colors.grey,
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: () async {
              _controller.jumpToPage(1);
              Navigator.pop(context);
            },
            child: Text(AppLocalization.of(context).backToHome,
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          SizedBox(height: 10),
          RaisedButton(
            color: Style().dazzlePrimaryColor,
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: () async {
              _controller.jumpToPage(0);
              Navigator.pop(context);
            },
            child: Text(AppLocalization.of(context).goToProfile,
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
        ],
      ),
    ]);
  }
}
