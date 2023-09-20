import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;
import 'package:feelingapp/main.dart';

class PreviewAvatar extends StatefulWidget {
  final String videoPreviewPath;
  PreviewAvatar({Key key, @required this.videoPreviewPath}) : super(key: key);

  @override
  _PreviewAvatarState createState() => _PreviewAvatarState();
}

class _PreviewAvatarState extends State<PreviewAvatar> {
  Future<void> futureInitVideoFromCache;
  ChewieController chewieController;
  VideoPlayerController videoPlayerController;
  Chewie videoFrame;
  double videoDuration = 0.0;
  double sliderValue = 0.0;

  bool isUploading = false;
  @override
  void initState() {
    futureInitVideoFromCache = initPlatformState();
    super.initState();
  }

  Future<Widget> initPlatformState() async {
    videoPlayerController =
        VideoPlayerController.file(File(widget.videoPreviewPath));
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isInitialized) {
        setState(() {
          videoDuration =
              videoPlayerController.value.duration.inMilliseconds.toDouble();
        });
      }
    });
    debugPrint(videoPlayerController.value.duration.toString());
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      //aspectRatio: 720 / 1280,
      autoPlay: true,
      looping: false,
      showControls: false,
      autoInitialize: true,
    );

    videoFrame = Chewie(controller: chewieController);

    //debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1" + videoDuration.toString());
    return videoFrame;
  }

  uploadUserVideo() {
    setState(() {
      isUploading = true;
    });

    currentUser
        .updateUserVideoFromFile(widget.videoPreviewPath, currentUser.uid)
        .then((value) {
      setState(() {
        isUploading = false;
      });
      Navigator.pop(context);
    });
  }

  Future<bool> _onBackButtonDuringLoading() {
    if (isUploading) return Future.value(false);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var pageContent = Scaffold(
        body: Column(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: SizedBox.expand(
                  child: new FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: SizedBox(
                  width: videoPlayerController.value.size?.width ?? 0,
                  height: videoPlayerController.value.size?.height ?? 0,
                  child: VideoPlayer(videoPlayerController),
                ),
              )),
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 150),
                child: FlatButton(
                  color: Colors.black.withOpacity(0.05),
                  textColor: Colors.black,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back",
                    style: TextStyle(fontSize: 20.0),
                  ),
                )),
            FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  uploadUserVideo();
                },
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 20.0),
                )),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                child: Slider(
                  value: sliderValue,
                  onChanged: (newValue) {
                    setState(() {
                      sliderValue = newValue;
                      videoPlayerController.pause();

                      videoPlayerController
                          .seekTo(Duration(milliseconds: newValue.toInt()));
                    });
                  },
                  min: 0.0,
                  max: videoDuration,
                  divisions: 25,
                )),
          ],
        )
      ],
    ));
    if (isUploading) {
      return WillPopScope(
          child: Stack(children: [
            pageContent,
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.7),
              child: HeartbeatProgressIndicator(
                child: Image.asset("assets/images/logo_main.png"),
                startScale: 0.4,
                endScale: 0.5,
              ),
            )
          ]),
          onWillPop: () => _onBackButtonDuringLoading());
    } else
      return pageContent;
  }

  @override
  void dispose() {
    chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }
}
