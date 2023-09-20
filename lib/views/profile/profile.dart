import 'dart:async';
import 'dart:ui';
import 'package:feelingapp/blocs/home_page/home_page_bloc.dart';
import 'package:feelingapp/blocs/playback/playback_bloc.dart';
import 'package:feelingapp/includes/camera.dart';
import 'package:feelingapp/includes/preview_video.dart';
import 'package:feelingapp/includes/user.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/profile/widgets/gender_preference_selector.dart';
import 'package:feelingapp/views/profile/widgets/gender_selector.dart';
import 'package:feelingapp/views/profile/widgets/nickname_selector.dart';
import 'package:feelingapp/views/profile/widgets/tag_selection_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/includes/stream_messages.dart';
import 'package:feelingapp/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import '../../includes/video_player.dart';
import '../../routes.dart';
import 'dart:math' as math;

class ProfilePage extends StatefulWidget {
  //final Stream<StreamMessage> parentEvents;
  final bool isEditable;
  final bool autoPlaying;
  final bool showPause;
  final bool showPlay;
  final bool
      userDetailsPermitted; // allows clicking on the user name and navigate to its page

  ProfilePage(
      {Key key,
      this.isEditable = false,
      this.autoPlaying = true,
      this.showPause = false,
      this.showPlay = false,
      this.userDetailsPermitted = false})
      : super(key: key);
  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  var showVideoPreview = false;
  bool isHashTagsSelectionVisibile = false;

  @override
  bool get wantKeepAlive => true;

  StreamController<StreamMessage> videoControls =
      StreamController<StreamMessage>.broadcast();

  var overlayInformation = currentUser.toMap();
  AnimationController _videoEditAnimationController;
  AnimationController _hashButtonAnimationController;

  GlobalKey _fabKey = GlobalObjectKey("recordButton");
  bool showRecordTurorial = true;

  @override
  void initState() {
    super.initState();
    _videoEditAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _hashButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    streamController.stream.asBroadcastStream().listen((event) {
      if (event == StreamMessage.profile) {
        if (widget.autoPlaying) {
          startVideo();
        }
        if ((currentUser.mediaUrl == null) && showRecordTurorial) {
          Future.delayed(
              const Duration(milliseconds: 300), () => showCoachMarkFAB());
          showRecordTurorial = false;
        }
      } else {
        stopVideo();
        if (!_videoEditAnimationController.isDismissed) {
          _videoEditAnimationController.reverse();
          setState(() {
            showVideoPreview = !showVideoPreview;
          });
        }
      }
    });
  }

  void startVideo() {
    videoControls.add(StreamMessage.startVideo);
    debugPrint("Starting video from profile");
  }

  void stopVideo() {
    videoControls.add(StreamMessage.stopVideo);
    debugPrint("Stopping video from profile");
  }

  void reloadVideo() {
    setState(() {
      overlayInformation = currentUser.toMap();
    });
    videoControls.add(StreamMessage.reloadNetworkVideoSource);
  }

  Widget buildProfilePage(var isPlaying) {
    return Container(
        child: Stack(children: [
      currentUser.mediaUrl != null
          ? Container(
              child: ClipRRect(
                  //borderRadius: BorderRadius.circular(8.0),
                  child: BlocProvider(
              create: (BuildContext context) => PlaybackBloc(),
              child: UserVideoPlayer(
                isEditable: false,
                autoPlaying: isPlaying,
                parentEvents: videoControls.stream,
                showReplay: true,
                userDetailsPermitted: widget.userDetailsPermitted,
                overLayInformation: currentUser.toMap(),
                isLooping: false,
              ),
            )))
          : Container(
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
              ),
            ),
    ]));
  }

  Widget buildHashSelectionpage() {
    Widget content;
    if (!isHashTagsSelectionVisibile)
      content = SizedBox();
    else
      content = SafeArea(
          child: Column(
        children: [
          SizedBox(
              height: 15 +
                  MediaQuery.of(context).size.height * 0.05 +
                  MediaQuery.of(context).size.height * 0.005 +
                  10),
          Spacer(),
          UserTagSelectorWidget(),
          Spacer()
        ],
      ));
    return AnimatedSwitcher(
        switchOutCurve: Curves.easeOutExpo,
        switchInCurve: Curves.easeInExpo,
        duration: Duration(milliseconds: 250),
        child: content);
  }

  Widget buildSideButtons() {
    return Container(
      //color: Colors.transparent,
      child: Row(children: [
        Spacer(),
        SafeArea(
            child: Column(
          children: [
            SizedBox(height: 15),
            tagButton(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            videoEditButton(
                visible: !_hashButtonAnimationController.isAnimating &&
                    !isHashTagsSelectionVisibile,
                enabled: !isVideoUploadRunning),
            Spacer(),
            shareButton(
                visible: !_hashButtonAnimationController.isAnimating &&
                    !showVideoPreview &&
                    !isHashTagsSelectionVisibile),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            settingsButton(
                visible: !_hashButtonAnimationController.isAnimating &&
                    !showVideoPreview &&
                    !isHashTagsSelectionVisibile),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ],
        )),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.04,
        )
      ]),
    );
  }
  Widget videoBadge({visible: true}) {
    return Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child:  Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 2, color: Colors.white)),
            child: SizedBox(
              child: Container(
                  decoration: BoxDecoration(
                      color: buildBadgeColor(currentUser),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(buildBadgeText(currentUser), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  )
              ),
            )));
  }

  MaterialColor buildBadgeColor(AppUser user) {
    switch (user.accountState) {
      case "ActiveWithVideo":
        return Colors.green;
        break;
      case "Pending":
        return Colors.orange;
        break;
    }
    return Colors.red;
  }

  String buildBadgeText(AppUser user) {
    switch (user.accountState) {
      case "ActiveWithVideo":
        return AppLocalization.of(context).badgeVideoOK;
        break;
      case "ActiveRefusedVideo":
        return AppLocalization.of(context).badgeVideoRefused;
        break;
      case "VideoError":
        return AppLocalization.of(context).badgeVideoError;
        break;
      case "Active":
        return AppLocalization.of(context).badgeVideoMissing;
        break;
      case "Pending":
        return AppLocalization.of(context).badgeVideoPending;
        break;
    }
    return "MMM";
  }
  
  Widget settingsButton({visible: true}) {
    return Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 2, color: Colors.white)),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.height * 0.05,
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    Navigator.push(context,
                        Routes().additionalSettingsRoute(RouteSettings()));
                  },
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * 0.04,
                  ),
                ),
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            AppLocalization.of(context).settings,
            style: TextStyle(color: Colors.white),
          ),
        ]));
  }

  Widget shareButton({visible: true}) {
    return Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 2, color: Colors.white)),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.height * 0.05,
                child: FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    Share.share(
                        serverSettings.shareMessage[
                                AppLocalization.of(context).locale.toString()]
                            .replaceAll("\\n", "\n"),
                        subject: serverSettings.shareTitle);
                  },
                  child: Icon(
                    DadolIcons.x_share,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * 0.035,
                  ),
                ),
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            AppLocalization.of(context).share,
            style: TextStyle(color: Colors.white),
          ),
        ]));
  }

  Color getIconColor() {
    if (currentUser.mediaUrl == null) {
      return Colors.white;
    } else {
      return Style().dazzlePrimaryColor;
    }
  }

  Widget tagButton({visible: true}) {
    return BlocListener(
      bloc: BlocProvider.of<HomePageBloc>(context),
      listenWhen: (previous, current) =>
          current is CompleteProfileHomePageState,
      listener: (BuildContext context, HomePageState state) {
        setState(() {
          isHashTagsSelectionVisibile = false;
        });
      },
      child: Column(children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    width: 2,
                    color: isHashTagsSelectionVisibile
                        ? getIconColor()
                        : Colors.white)),
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.height * 0.05,
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  heroTag: null,
                  child: AnimatedBuilder(
                    animation: _hashButtonAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return Transform(
                        transform: Matrix4.rotationZ(
                            _hashButtonAnimationController.value *
                                0.5 *
                                math.pi),
                        alignment: FractionalOffset.center,
                        child: Icon(
                          _hashButtonAnimationController.isDismissed
                              ? Icons.tag
                              : DadolIcons.x_cross,
                          color: _hashButtonAnimationController.isDismissed
                              ? Colors.white
                              : getIconColor(),
                          size: _hashButtonAnimationController.isDismissed
                              ? MediaQuery.of(context).size.height * 0.04
                              : MediaQuery.of(context).size.height * 0.03,
                        ),
                      );
                    },
                  ),
                  onPressed: () {

                    if (_hashButtonAnimationController.isDismissed) {
                      blurFilterVisible = true;
                      _hashButtonAnimationController
                          .forward()
                          .then((value) => setState(() {}));
                    } else {
                      blurFilterVisible = false;
                      _hashButtonAnimationController
                          .reverse()
                          .then((value) => setState(() {}));
                    }
                    setState(() {
                      isHashTagsSelectionVisibile =
                          !isHashTagsSelectionVisibile;
                      _videoEditAnimationController.reverse();
                      videoControls.add(StreamMessage.stopVideo);
                      showVideoPreview = false;

                      if (!isVideoUploadRunning)
                        BlocProvider.of<HomePageBloc>(context)
                            .add(EditProfileTags());
                    });
                  },
                ))),
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        Text(
          "Tag",
          style: TextStyle(color: Colors.white),
        ),
      ]),
    );
  }

  Widget videoEditButton({visible: true, enabled: true}) {
    const List<IconData> icons = const [
      DadolIcons.x_record_video,
      DadolIcons.x_upload
    ];
    const List<String> iconsSubtitles = const ["Record", "Upload"];
    List<Widget> buttons = [
      Column(children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    width: 2,
                    color: showVideoPreview ? getIconColor() : Colors.white)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.height * 0.05,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                heroTag: null,
                child: AnimatedBuilder(
                  animation: _videoEditAnimationController,
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      transform: Matrix4.rotationZ(
                          _videoEditAnimationController.value * 0.5 * math.pi),
                      alignment: FractionalOffset.center,
                      child: Icon(
                        _videoEditAnimationController.isDismissed
                            ? Icons.edit
                            : DadolIcons.x_cross,
                        color: _videoEditAnimationController.isDismissed
                            ? Colors.white
                            : getIconColor(),
                        size: _videoEditAnimationController.isDismissed
                            ? MediaQuery.of(context).size.height * 0.04
                            : MediaQuery.of(context).size.height * 0.03,
                      ),
                    );
                  },
                ),
                onPressed: () {
                  setState(() {
                    showVideoPreview = !showVideoPreview;
                  });
                  if (_videoEditAnimationController.isDismissed) {
                    blurFilterVisible = true;
                    videoControls.add(StreamMessage.startVideo);
                    _videoEditAnimationController
                        .forward()
                        .then((value) => setState(() {}));
                  } else {
                    blurFilterVisible = false;
                    _videoEditAnimationController
                        .reverse()
                        .then((value) => setState(() {}));
                    videoControls.add(StreamMessage.stopVideo);
                  }
                },
              ),
            )),
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        Text(AppLocalization.of(context).edit,
            style: TextStyle(color: Colors.white)),
      ])
    ];
    buttons.addAll(List.generate(icons.length, (int index) {
      Widget child = Container(
        height: 70.0,
        width: 56.0,
        alignment: FractionalOffset.topCenter,
        child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _videoEditAnimationController,
              curve: Interval(0.0, 1.0 - index / icons.length / 2.0,
                  curve: Curves.easeOut),
            ),
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  mini: true,
                  child: IconShadowWidget(
                    Icon(icons[index],
                        color: enabled ? getIconColor() : Colors.grey),
                    shadowColor: Colors.black,
                    showShadow: false,
                  ),
                  onPressed: () {
                    if (!enabled) return;
                    stopVideo();
                    if (index == 0) {
                      openCamera();
                    }
                    if (index == 1) {
                      uploadFile();
                    }
                  },
                ),
                Text(iconsSubtitles[index],
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ],
            )),
      );
      return child;
    }));
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Container(
          key: _fabKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: buttons)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMainProfilePage();
  }

  bool blurFilterVisible = false;
  Widget buildMainProfilePage() {
    Widget overlay = Positioned.fill(
      child: Visibility(
        visible: blurFilterVisible,
        child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(color: Colors.black.withOpacity(0.2))),
      ),
    );
    return Stack(children: [
      buildProfilePage(false),
      Positioned(
        left: 10,
        top: 10,
        child: videoBadge(),),
      SizedBox(),
      overlay,
      buildSideButtons(),
      buildHashSelectionpage(),
    ]);
  }

  Widget buildUploadVideoHint() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: MediaQuery.of(context).size.width * 0.25,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Container(
          child: Text(
            AppLocalization.of(context).recordRegisterHint,
            style: TextStyle(color: Colors.white, fontSize: 28),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildNicknameSelector() {
    var onSubmitted = (data) {
      setState(() {
        overlayInformation = currentUser.toMap();
      });
    };
    return NicknameSelector(
      onSubmittedCallback: onSubmitted,
    );
  }

  Widget buildGenderSelector() {
    return GenderSelector(
      onSubmittedCallback: () {
        setState(() {
          overlayInformation = currentUser.toMap();
        });
        streamController.add(StreamMessage.carouselReload);
      },
    );
  }

  Widget buildPartnerPreference() {
    return GenderPreferenceSelector(
      onSubmittedCallback: () {
        setState(() {
          overlayInformation = currentUser.toMap();
        });
        streamController.add(StreamMessage.carouselReload);
      },
    );
  }

  void openCamera() async {
    //await Navigator.push(context, Routes().cameraRoute(RouteSettings()));
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraCapture(onDoneCallback: (isFirstUpload) {
            pushNotificationService.videoUploadCallback(false);
            reloadVideo();
            currentUser.changeAccountState("Pending");
            streamController.add(StreamMessage.carouselReload);
          }),
        ));
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
              isFromFile: true,
              onDoneCallback: (isFirstUpload) async {
                pushNotificationService.videoUploadCallback(false);
                reloadVideo();
                currentUser.changeAccountState("Pending");
                streamController.add(StreamMessage.carouselReload);
              }),
        ));
  }

  void showCoachMarkFAB() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _fabKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    _videoEditAnimationController.forward();
    setState(() {
      showVideoPreview = !showVideoPreview;
    });

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
            child: Text(AppLocalization.of(context).recordRegisterHint,
                style: const TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                )),
          ))
        ],
        duration: null,
        onClose: () {
          _videoEditAnimationController.reverse();
          setState(() {
            showVideoPreview = !showVideoPreview;
          });
        });
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;

    var path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.39);
    path.lineTo(size.width * 0.5,
        size.height * (0.02 + 0.02 + 0.005) + 56 + 2 + 14 + 56 / 2);
    path.lineTo(size.width - (size.width * 0.3),
        size.height * (0.02 + 0.02 + 0.005) + 56 + 2 + 14 + 56 / 2);
    path.moveTo(size.width - (size.width * 0.35),
        size.height * (0.02 + 0.02 + 0.005) + 56 + 2 + 14 + 56 / 3);
    path.lineTo(size.width - (size.width * 0.3),
        size.height * (0.02 + 0.02 + 0.005) + 56 + 2 + 14 + 56 / 2);
    path.lineTo(size.width - (size.width * 0.35),
        size.height * (0.02 + 0.02 + 0.005) + 56 + 2 + 14 + 56 / 1.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
