import 'dart:async';
import 'dart:ui';
import 'package:feelingapp/blocs/home_page/home_page_bloc.dart';
import 'package:feelingapp/blocs/playback/playback_bloc.dart';
import 'package:feelingapp/includes/user.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/carousel/widgets/report_card.dart';
import 'package:feelingapp/views/carousel/widgets/tutorial.dart';
import 'package:feelingapp/views/carousel/widgets/tag_selector_fancy.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/includes/stream_messages.dart';
import 'package:feelingapp/includes/video_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:like_button/like_button.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../../main.dart';

class Carousel extends StatefulWidget {
  final pageJumper;
  final onFirstVideoLoaded;
  Carousel(
      {Key key, @required this.pageJumper, @required this.onFirstVideoLoaded})
      : super(key: key);
  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  PreloadPageController _controller =
      new PreloadPageController(viewportFraction: 1.01);
  StreamController<int> _carouselStreamController =
      StreamController<int>.broadcast();
  int currentPage = 0;

  AnimationController _likeAnimationController;
  AnimationController _popUpAnimationController;

  Future<dynamic> carouselFutureMemorizer;

  var showReport = false;

  var reportText;
  var reportReason;
  var userOnScreen;

  Map likedUSers = Map();

  bool isSearchBarExpanded = false;
  bool isUIEnabled = true;
  bool isTutorialStarted = false;

  GlobalKey _searchBarKey = GlobalObjectKey("search_bar");
  GlobalKey _videoScreenKey = GlobalObjectKey("video_screen");

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool isKeyboardVisible) {
      if (!isKeyboardVisible) {
        if (isSearchBarExpanded) {
          FocusScope.of(context).unfocus();
        }
      }
    });

    carouselFutureMemorizer = currentUser.getPersonalizedCollection();

    carouselFutureMemorizer.then((value) {
      if (value.length <= 1) widget.onFirstVideoLoaded();
    });

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _popUpAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );

    streamController.stream.asBroadcastStream().listen((event) {
      if (event == StreamMessage.carousel) {
        _carouselStreamController.add(currentPage);
      } else if (event == StreamMessage.carouselReload) {
        currentUser.getPersonalizedCollection().then((value) {
          _controller.jumpToPage(0);
          setState(() {
            carouselFutureMemorizer = Future<List<dynamic>>.value(value);
          });
        });
      } else {
        // videoControls.add(StreamMessage.stopVideo);
        _carouselStreamController.add(-1);
        setState(() {
          showReport = false;
        });
        _popUpAnimationController.reverse().orCancel;
      }
    });
  }

  Widget userCard(userCardInfo, position) {
    var autoPlay = false;

    // Autoplay the first page
    if (position == 0 && currentPage == 0) autoPlay = true;

    // Set current user as seen
    debugPrint("Currentpage " +
        currentPage.toString() +
        " position " +
        position.toString());

    var videoPlayer = ClipRRect(
      child: BlocProvider(
        create: (BuildContext context) => PlaybackBloc(),
        child: UserVideoPlayer(
          autoPlaying: autoPlay,
          userDetailsPermitted: true,
          overLayInformation: userCardInfo,
          isLooping: false,
          showReplay: true,
          index: position,
          carouselStreamEvents: _carouselStreamController.stream,
        ),
      ),
    );

    var likeAnimation = AnimatedBuilder(
        animation: _likeAnimationController,
        builder: (_, child) {
          return FadeTransition(
              opacity: CurvedAnimation(
                  parent: _likeAnimationController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut),
              child: IgnorePointer(
                child: Container(
                  child: Image.asset(
                    "assets/images/logo_main.png",
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  alignment: Alignment.center,
                ),
              ));
        });
    //Image.asset("assets/images/logo_main.png")

    return WillPopScope(
        onWillPop: () {
          // Remove focus from the selection bar. The bar will then close automatically due to the focus listener
          if (isSearchBarExpanded) {
            FocusScope.of(context).unfocus();
          }
          return Future.value(false);
        },
        child: GestureDetector(
            onDoubleTap: () {
              BlocProvider.of<HomePageBloc>(context).add(SendLike());
              if (currentUser.accountState == "Pending" ||
                  currentUser.accountState == "ActiveWithVideo") {
                currentUser.userLiked(userCardInfo['uid']);
                animateLike();
                FirebaseAnalytics().logEvent(name: 'video_like', parameters: {
                  "uid": currentUser.uid,
                  "other_uid": userOnScreen
                });
              }
            },
            onTap: () {
              //videoControls.add(StreamMessage.pauseVideo);
              // Remove focus from the selection bar. The bar will then close automatically due to the focus listener
              if (isSearchBarExpanded) {
                FocusScope.of(context).unfocus();
              }
            },
            child: Stack(children: [
              videoPlayer,
              likeAnimation,
            ])));
  }

  void animatePopUp() async {
    try {
      await _popUpAnimationController.forward().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because it was disposed of
    }
  }

  void animateLike() async {
    try {
      if (!likedUSers.containsKey(userOnScreen)) {
        await _likeAnimationController.forward().orCancel;
        await _likeAnimationController.reverse().orCancel;
      }
      likedUSers[userOnScreen] = true;
      _controller.nextPage(
          duration: Duration(milliseconds: 400), curve: Curves.easeInOutQuint);
    } on TickerCanceled {
      // the animation got canceled, probably because it was disposed of
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget carouselChild;
    final searchBar = Expanded(
      key: _searchBarKey,
      child: BlocListener(
        bloc: BlocProvider.of<HomePageBloc>(context),
        listenWhen: (previous, current) =>
            current is CompleteProfileHomePageState,
        listener: (BuildContext context, HomePageState state) {
          setState(() {
            isSearchBarExpanded = false;
            FocusScope.of(context).unfocus();
          });
        },
        child: UserTagSelectorFancy(
            enabled: isUIEnabled,
            onExpandedCallback: (isFullyOpen, isFullyClosed) {
              setState(() {
                isSearchBarExpanded = isFullyOpen;
              });
            },
            onTappedCallback: (isExpanded) {
              if (isExpanded)
                setState(() {
                  isSearchBarExpanded = isExpanded;
                });

              if (!isVideoUploadRunning)
                BlocProvider.of<HomePageBloc>(context).add(FilterWithTags());
            },
            onFilterChanged: (filterTags) {
              currentUser.updateUserTagSearchFilter(filterTags);
              streamController.add(StreamMessage.carouselReload);
            }),
      ),
    );

    final reportDots = Container(
      child: InkWell(
        onTap: () {
          if (isUIEnabled == false) return;
          setState(() {
            //videoControls.add(StreamMessage.pauseVideo);
            showReport = true;
          });
        },
        child: IconShadowWidget(
          Icon(
            Icons.more_vert,
            size: MediaQuery.of(context).size.height * 0.05,
            color: Colors.white,
          ),
          shadowColor: Colors.black,
        ),
      ),
    );

    Widget topBar = Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            searchBar,
            reportDots,
            SizedBox(width: MediaQuery.of(context).size.width * 0.01)
          ],
        ));

    Widget topBarExpanded = Container(
        width: isSearchBarExpanded
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
            searchBar,
            SizedBox(width: MediaQuery.of(context).size.width * 0.05)
          ],
        ));

    return Stack(key: _videoScreenKey, children: [
      FutureBuilder<dynamic>(
          future: carouselFutureMemorizer,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                carouselChild = Container();
                break;
              default:
                carouselChild = PreloadPageView.builder(
                  // Changes begin here
                  key: new PageStorageKey('feed'),
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  reverse: false,
                  itemCount: snapshot.data.length,
                  preloadPagesCount: 2,
                  onPageChanged: (int position) {
                    if (position != currentPage &&
                        currentUser.numberOfVideosViewedToday >= 30 &&
                        !isVideoUploadRunning &&
                        currentUser.accountState != "ActiveWithVideo" &&
                        currentUser.accountState != "Pending") {
                      BlocProvider.of<HomePageBloc>(context)
                          .add(VideoLimitReached());
                      _controller.jumpToPage(currentPage);
                    } else {
                      _carouselStreamController.add(position);
                      currentPage = position;
                      userOnScreen = snapshot.data[currentPage]['uid'];
                      currentUser.userSeen(snapshot.data[position]['uid']);
                    }
                  },
                  itemBuilder: (context, position) {
                    // Always mark the first video as seen
                    if (position == 0)
                      currentUser.userSeen(snapshot.data[0]['uid']);

                    userOnScreen = snapshot.data[currentPage]['uid'];
                    return FractionallySizedBox(
                        heightFactor: 1,
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom: position == snapshot.data.length - 1
                                  ? 0
                                  : MediaQuery.of(context).size.height *
                                      0.009), // Spacing between different videos on the carousle
                          child: carouselPageContent(
                              snapshot.data[position]['uid'],
                              snapshot.data[position],
                              position),
                        ));
                  },
                );
            }
            return AnimatedSwitcher(
                duration: Duration(milliseconds: 500), child: carouselChild);
          }),
      tutorialOverlay(),
      popUpAnimation(),
      Positioned(
        top: 35,
        child: AnimatedSize(
            vsync: this,
            duration: Duration(milliseconds: 500),
            child: isSearchBarExpanded ? topBarExpanded : topBar),
      ),
      showReport
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 20,
                    sigmaY: 20,
                  ),
                  child: reportCard(),
                ),
              ))
          : Container(),
    ]);
  }

  Widget carouselPageContent(String type, var data, int position) {
    if (type == "no_more_videos") {
      return WillPopScope(
        onWillPop: () {
          // Remove focus from the selection bar. The bar will then close automatically due to the focus listener
          if (isSearchBarExpanded) {
            FocusScope.of(context).unfocus();
          }
          return Future.value(false);
        },
        child: Container(
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalization.of(context).noMoreVids,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ))
            ])),
      );
    } else if (type == "view_limit_reached") {
      return WillPopScope(
        onWillPop: () {
          // Remove focus from the selection bar. The bar will then close automatically due to the focus listener
          if (isSearchBarExpanded) {
            FocusScope.of(context).unfocus();
          }
          return Future.value(false);
        },
        child: Container(
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalization.of(context).viewLimitReached,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ))
            ])),
      );
    } else if (type == "video_upload_required") {
      return WillPopScope(
        onWillPop: () {
          // Remove focus from the selection bar. The bar will then close automatically due to the focus listener
          if (isSearchBarExpanded) {
            FocusScope.of(context).unfocus();
          }
          return Future.value(false);
        },
        child: Container(
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalization.of(context).uploadVideoToContinue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ))
            ])),
      );
    } else if (currentUser.registrationStage !=
            RegistrationStage.COMPLETE.index &&
        isTutorialStarted == false) {
      isTutorialStarted = true;
      Future.delayed(const Duration(milliseconds: 1000), () => startTutorial());
      return Container(
        width: 0,
        height: 0,
      );
    }

    //bool isLikedUser = false;
    return Stack(
      children: [
        userCard(data, position),
        Positioned(
          bottom: MediaQuery.of(context).size.height/2.31,
          right: 20,
          child: Icon(
            Icons.favorite,
            color: Style().dazzleSecondaryColor,
            size: 55,
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height/2.31,
          right: 17,
          child: LikeButton(
            padding:  EdgeInsets.all(20),
            //isLiked: isLikedUser,
            circleColor: CircleColor(
                start: Style().dazzleSecondaryColor,
                end: Style().dazzlePrimaryColor),
            bubblesColor: BubblesColor(
              dotPrimaryColor: Style().dazzlePrimaryColor,
              dotSecondaryColor: Style().dazzleSecondaryColor,
            ),
            likeBuilder: (bool isLiked) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: isLiked ? Style().dazzlePrimaryColor : Colors.white,
                    size: 45,
                  ),

                ],
              );
            },
            onTap: (liked) {
              try{
                BlocProvider.of<HomePageBloc>(context).add(SendLike());
                if (currentUser.accountState == "Pending" ||
                    currentUser.accountState == "ActiveWithVideo") {
                  currentUser.userLiked(data['uid']);

                  FirebaseAnalytics().logEvent(name: 'video_like', parameters: {
                    "uid": currentUser.uid,
                    "other_uid": data['uid']
                  });


                  return Future.value(true);
                }
              }catch(exception){

              }

              return Future.value(false);
            },
          ),
        )
      ],
    );
  }

  Widget tutorialOverlay() {
    var tutorialType;
    /*if (currentUser.registrationStage != RegistrationStage.COMPLETE.index)
      tutorialType = "tutorial";*/

    if (currentUser.accountState == "Suspended") tutorialType = "returning";

    if (tutorialType == null) return SizedBox();

    setState(() {
      isUIEnabled = false;
    });

    return TutorialWidget(
        type: tutorialType,
        onTapCallback: () {
          setState(() {
            isUIEnabled = true;
          });
          if (tutorialType == "tutorial") {
            currentUser
                .updateRegistrationStage(RegistrationStage.COMPLETE.index)
                .then((value) => null);
            setState(() {
              currentUser.registrationStage = RegistrationStage.COMPLETE.index;
            });
          }
          if (tutorialType == "returning") {
            currentUser.changeAccountState("Active");
          }
        });
  }

  void reportCallback(String type, String text) {
    if (type == "reason")
      reportReason = text;
    else
      reportText = text;
  }

  Widget reportCard() {
    return ReportCard(
      enabled: showReport,
      onSubmittedCallback: (submitted) {
        _carouselStreamController.add(currentPage);
        setState(() {
          showReport = false;
        });
        if (submitted == true) {
          _controller.nextPage(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutQuint);
        }
      },
      otherUid: userOnScreen,
    );
  }

  Widget popUpContainer() {
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
              _popUpAnimationController.reverse().orCancel;
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
              await _popUpAnimationController.reverse().orCancel;
              widget.pageJumper(0);
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

  Widget popUpAnimation() {
    return AnimatedBuilder(
        animation: _popUpAnimationController,
        builder: (_, child) {
          return FadeTransition(
              opacity: CurvedAnimation(
                  parent: _popUpAnimationController,
                  curve: Curves.easeIn,
                  reverseCurve: Curves.easeOut),
              child: IgnorePointer(
                ignoring: _popUpAnimationController.isDismissed ? true : false,
                child: Container(
                  child: popUpContainer(),
                  alignment: Alignment.center,
                ),
              ));
        });
  }

  void showFinalTutorial() {
    CoachMark coachMarkFAB = CoachMark(bgColor: Colors.black.withOpacity(0.7));

    Rect markRect = Rect.fromLTWH(0, 0, 0, 0); // Bogus rectangle

    coachMarkFAB.show(
        targetContext: _searchBarKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            child: TutorialWidget(
              type: "final",
              onTapCallback: () {},
            ),
          ))
        ],
        duration: null,
        onClose: () {
          currentUser
              .updateRegistrationStage(RegistrationStage.COMPLETE.index)
              .then((value) => null);
          setState(() {
            currentUser.registrationStage = RegistrationStage.COMPLETE.index;
          });
          _carouselStreamController.add(0);
          //videoControls.add(StreamMessage.startVideo);
        });
  }

  void showSearchBarTutorial() {
    CoachMark coachMarkFAB = CoachMark(bgColor: Colors.black.withOpacity(0.7));
    RenderBox target = _searchBarKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    markRect = markRect.inflate(17.0);

    coachMarkFAB.show(
        targetContext: _searchBarKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            child: TutorialWidget(
              type: "searchbar",
              onTapCallback: () {},
            ),
          ))
        ],
        duration: null,
        onClose: () {
          showFinalTutorial();
        });
  }

  void startTutorial() {
    CoachMark coachMarkFAB = CoachMark(bgColor: Colors.black.withOpacity(0.7));
    RenderBox target = _videoScreenKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0);

    //videoControls.add(StreamMessage.pauseVideo);

    coachMarkFAB.show(
        targetContext: _videoScreenKey.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            child: TutorialWidget(
              type: "tutorial",
              onTapCallback: () {},
            ),
          ))
        ],
        duration: null,
        onClose: () {
          showSearchBarTutorial();
        });
  }
}
