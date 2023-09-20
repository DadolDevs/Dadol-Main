import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:chewie/chewie.dart';
import 'package:feelingapp/blocs/home_page/home_page_bloc.dart';
import 'package:feelingapp/blocs/playback/playback_bloc.dart';
import 'package:feelingapp/blocs/video_player/video_player_bloc.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/includes/stream_messages.dart';
import 'package:feelingapp/main.dart';
import 'package:feelingapp/views/profile/widgets/tags.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

import '../routes.dart';

//'https://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_480_1_5MG.mp4'

class UserVideoPlayer extends StatefulWidget {
  final bool isEditable;
  final bool autoPlaying;
  final Stream<StreamMessage> parentEvents;
  final Stream<int> carouselStreamEvents;
  final bool userDetailsPermitted;
  final Map overLayInformation;
  final bool isLooping;
  final bool showReplay;
  final int index;
  final bool readFromFile;

  UserVideoPlayer({
    Key key,
    this.isEditable = false,
    this.autoPlaying = false,
    this.parentEvents,
    this.userDetailsPermitted = false,
    this.overLayInformation,
    this.isLooping = true,
    this.showReplay = false,
    this.index = 0,
    this.carouselStreamEvents,
    this.readFromFile = false,
  }) : super(key: key);

  @override
  _StateUserVideoPlayer createState() => _StateUserVideoPlayer();
}

class _StateUserVideoPlayer extends State<UserVideoPlayer> {
  Future<void> futureInitUserStats;
  File file;
  bool fetchVideoFromOnline = true;
  StreamSubscription<StreamMessage> streamSubscription;
  String mediaUrl;
  String thumbnailUrl;
  bool videoEnded = false;
  bool isVideoLoading = true;
  bool thumbnailLoaded = false;
  var currentPageViewPage;
  VoidCallback videoEventListener;
  StreamSubscription<int> carouselStream;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    if (widget.carouselStreamEvents != null)
      carouselStream = widget.carouselStreamEvents.listen((pageNumber) {
        debugPrint("current page " + widget.index.toString());
        setState(() {
          pageChangedCallback(pageNumber);
        });
      });
    //futureInitUserStats = initPlatformState(tryCache: false);

    if (widget.parentEvents != null)
      streamSubscription =
          widget.parentEvents.asBroadcastStream().listen((event) {
        if (event == StreamMessage.reloadNetworkVideoSource) {}
        //reloadNetowrkSource();
      });
  }

  @override
  void dispose() {
    debugPrint("Disposing " + widget.index.toString() + " !!!!");
    if (streamSubscription != null) streamSubscription.cancel();

    if (carouselStream != null) carouselStream.cancel();

    if (videoPlayerBloc.videoPlayerController != null) {
      videoPlayerBloc.videoPlayerController.dispose();
    }

    if (videoPlayerBloc.chewieController != null) {
      videoPlayerBloc.chewieController.dispose();
    }

    videoPlayerBloc.close();
    super.dispose();
  }

  VideoPlayerBloc videoPlayerBloc = VideoPlayerBloc();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocConsumer(
          bloc: videoPlayerBloc,
          listenWhen: (previous, current) => current is ErrorVideoPlayerState,
          listener: (BuildContext context, VideoPlayerState state) {
            if (state is ErrorVideoPlayerState) {
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
          buildWhen: (previous, current) => !(current is ErrorVideoPlayerState),
          builder: (BuildContext context, VideoPlayerState state) {
            if (state is InitialVideoPlayerState) {
              var mediaUrl = widget.overLayInformation['mediaUrl'];
              var thumbnailUrl =
                  widget.overLayInformation['user_video_thumbnail'];
              videoPlayerBloc.add(LoadVideo(
                  mediaUrl ?? "",
                  thumbnailUrl ?? "",
                  widget.readFromFile,
                  widget.autoPlaying && viewingCarousel,
                  widget.isLooping));
              return Center(child: buildUserCardPlaceholder());
            }
            if (state is LoadingVideoPlayerState) {
              return Center(child: buildUserCardPlaceholder());
            }
            if (state is LoadedVideoPlayerState) {
              return Center(
                child: buildUserCard(state),
              );
            }
            return Text("");
          }),
    );
  }

  void openCamera() async {
    BlocProvider.of<PlaybackBloc>(context).add(Pause());
    await Navigator.push(context, Routes().cameraRoute(RouteSettings()));
    setState(() {
      mediaUrl = widget.overLayInformation['mediaUrl'];
    });
  }

  void navigateToProfileDetails() async {
    if (!widget.userDetailsPermitted) return;
    BlocProvider.of<PlaybackBloc>(context).add(Pause());
    await Navigator.push(
        context, Routes().detailedProfileRoute(RouteSettings()));
    BlocProvider.of<PlaybackBloc>(context).add(Play());
  }

  Widget buildUserCard(LoadedVideoPlayerState state) {
    Chewie videoFrame = state.videoFrame;
    List<Widget> userOverlay = [
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(left: 20),
                  //child: Row(children: <Widget>[userNameAndPic()]
                  child: Text(widget.overLayInformation['userName'],
                      style: Style().textDecorationUsername),
                ),
                SizedBox(width: 5),
                widget.overLayInformation['verified'] == true
                    ? Icon(
                        Icons.verified,
                        color: Style().dazzlePrimaryColor,
                      )
                    : SizedBox(),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(bottom: 40, left: 20),
              child: additionalTags(),
            ),
          ])
    ];

    if (widget.isEditable) {
      userOverlay.add(
        Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(bottom: 20, right: 0),
            child: RawMaterialButton(
              onPressed: () {
                openCamera();
              },
              elevation: 2.0,
              fillColor: Colors.white,
              child: Icon(
                Icons.edit,
                size: 20.0,
              ),
              shape: CircleBorder(),
            )),
      );
    }
    //debugPrint(widget.showReplay.toString() + " " + videoEnded.toString());

    // play
    userOverlay.add(
      BlocBuilder<PlaybackBloc, PlaybackState>(
        bloc: BlocProvider.of<PlaybackBloc>(
            context), // provide the local bloc instance
        builder: (context, state) {
          return Visibility(
            visible: state is ReadyPlaybackState,
            child: Container(
                alignment: Alignment.center,
                child: RawMaterialButton(
                  onPressed: () {
                    BlocProvider.of<PlaybackBloc>(context).add(Play());
                    debugPrint("started playing");
                  },
                  elevation: 2.0,
                  child: IconShadowWidget(
                    Icon(DadolIcons.x_play,
                        size: 60.0, color: Style().dazzlePrimaryColor),
                    shadowColor: Style().dazzleSecondaryColor,
                  ),
                  shape: CircleBorder(),
                )),
          );
        },
      ),
    );

    //pause
    userOverlay.add(
      BlocBuilder<PlaybackBloc, PlaybackState>(
        bloc: BlocProvider.of<PlaybackBloc>(
            context), // provide the local bloc instance
        builder: (context, state) {
          return Visibility(
            visible:
                state is PlayingPlaybackState || state is InitialPlaybackState,
            child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: RawMaterialButton(
                  onPressed: () {
                    BlocProvider.of<PlaybackBloc>(context).add(Pause());
                    debugPrint("paused");
                  },
                  elevation: 2.0,
                  child: SizedBox.expand(),
                )),
          );
        },
      ),
    );

    state.videoFrame.controller.videoPlayerController.addListener(() {
      if (state.videoFrame.controller.videoPlayerController.value.position ==
              state
                  .videoFrame.controller.videoPlayerController.value.duration &&
          !state.videoFrame.controller.videoPlayerController.value.isPlaying) {
        print("finished");
        state.videoFrame.controller.videoPlayerController
            .seekTo(Duration(seconds: 0));
        BlocProvider.of<PlaybackBloc>(context).add(Ready());
      }
    });

    return Container(
      child: Stack(
        children: [
          SizedBox.expand(
            child: new FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: videoFrame
                        .controller.videoPlayerController.value.size?.width ??
                    0,
                height: videoFrame
                        .controller.videoPlayerController.value.size?.height ??
                    0,
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<HomePageBloc, HomePageState>(
                      bloc: BlocProvider.of<HomePageBloc>(context),
                      listener: (context, hpState) {
                        if (!(hpState is InitialHomePageState)) {
                          BlocProvider.of<PlaybackBloc>(context).add(Stop());
                        }
                      },
                    ),
                    BlocListener<PlaybackBloc, PlaybackState>(
                      bloc: BlocProvider.of<PlaybackBloc>(context),
                      listener: (context, pbState) {
                        if (pbState is PausedPlaybackState) {
                          state.videoFrame.controller.pause();
                        }
                        if (pbState is StoppedPlaybackState) {
                          state.videoFrame.controller.pause();
                          state.videoFrame.controller
                              .seekTo(Duration(seconds: 0));
                        }
                        if (pbState is PlayingPlaybackState) {
                          state.videoFrame.controller.play();
                        }
                      },
                    ),
                  ],
                  child: VideoPlayer(
                      state.videoFrame.controller.videoPlayerController),
                ),
              ),
            ),
          ),
        ]..addAll(userOverlay),
      ),
    );
  }

  Widget userNameAndPic() {
    return Row(
      children: <Widget>[
        Container(
            child: RawMaterialButton(
          onPressed: () {
            navigateToProfileDetails();
          },
          elevation: 2.0,
          child: Text(
            widget.overLayInformation['userName'],
            style: Style().textDecorationUsername,
          ),
          shape: CircleBorder(),
        ))
      ],
    );
  }

  Widget tagsRow(TAG_TYPE type) {
    List<dynamic> filteredTags = widget.overLayInformation['additionalTags']
        .where((element) => element["type"] == type.index)
        .toList();
    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.01,
            left: MediaQuery.of(context).size.width * 0.01),
        child: Tags(
          alignment: WrapAlignment.start,
          itemCount: filteredTags.length,
          runSpacing: 8,
          itemBuilder: (index) {
            final item = filteredTags[index];
            String tagTitle;
            try {
              tagTitle = (type == TAG_TYPE.ATTRIBUTE
                  ? currentUser.tagAttributes[item["id"]]["val"]
                  : currentUser.tagInterests[item["id"]]["val"]);
            } catch (e) {
              tagTitle = "";
            }
            return ItemTags(
              key: Key(index.toString()),
              index: index,
              title: tagTitle,
              textStyle: TextStyle(fontSize: 14),
              pressEnabled: false,
              activeColor: type == TAG_TYPE.ATTRIBUTE
                  ? Style().dazzlePrimaryColor
                  : Style().dazzleSecondaryColor,
            );
          },
        ));
  }

  Widget additionalTags() {
    return
        //height: MediaQuery.of(context).size.height * 0.15,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            tagsRow(TAG_TYPE.ATTRIBUTE),
            SizedBox(height: 8),
            tagsRow(TAG_TYPE.INTEREST)
          ],
        );
  }

  pageChangedCallback(pageNumber) {
    debugPrint("Listened " + pageNumber.toString());
    if (pageNumber == widget.index && viewingCarousel) {
      BlocProvider.of<PlaybackBloc>(context).add(Play());
    } else {
      if (mounted) {
        BlocProvider.of<PlaybackBloc>(context).add(Stop());
      }
    }
  }

  Widget buildUserCardPlaceholder() {
    Widget thumbnail = thumbnailUrl != null
        ? FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: Image.network(thumbnailUrl, loadingBuilder:
                (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
              return Visibility(
                visible: loadingProgress == null,
                child: child,
              );
            }),
          )
        : Container(
            color: Colors.white,
          );
    return Container(
      child: SizedBox.expand(
        child: Stack(
          children: [
            thumbnail,
            Positioned.fill(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  )),
            ),
            Positioned.fill(
              child: HeartbeatProgressIndicator(
                child: Image.asset("assets/images/logo_main.png"),
                startScale: 0.3,
                endScale: 0.4,
                duration: Duration(milliseconds: 500),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      width: 300,
      child: SizedBox.expand(
          child: new FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        child: Stack(children: [
          thumbnailUrl != null
              ? Image.network(
                  thumbnailUrl,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Text("");
                  },
                )
              : Container(
                  color: Colors.white,
                ),
          Positioned.fill(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  ))),
          Positioned.fill(
            //color: Colors.black,
            child: HeartbeatProgressIndicator(
              child: Image.asset("assets/images/logo_main.png"),
              startScale: 0.3,
              endScale: 0.4,
              duration: Duration(milliseconds: 500),
            ),
          )
        ]),
      )),
    );
  }
}
