import 'dart:async';
import 'dart:io';
import 'package:feelingapp/includes/video_trimmer/trimmer_editor.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/sign_in/widgets/bottom_forward_backward.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:video_player/video_player.dart';
import 'package:feelingapp/main.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class PreviewVideo extends StatefulWidget {
  final String videoPreviewPath;
  final bool isFromFile;
  final bool isFlipped;
  final onDoneCallback;

  PreviewVideo(
      {Key key,
      @required this.videoPreviewPath,
      this.onDoneCallback,
      this.isFromFile: false,
      this.isFlipped: false})
      : super(key: key);

  @override
  _PreviewVideoState createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  VideoPlayerController videoPlayerController;
  bool firstLoaded = true;
  bool isUploading = false;
  Widget trimEditor = Container();
  Widget videoPlayer = Container();

  double videoStart;
  double videoEnd;
  int fileSize = -1;
  double normalizedFileSize = -1;

  @override
  void initState() {
    super.initState();
    loadVideo(videoFile: File(widget.videoPreviewPath));
  }

  Future<void> loadVideo({@required File videoFile}) async {
    if (videoFile != null) {
      fileSize = videoFile.lengthSync(); // bytes

      videoPlayerController = VideoPlayerController.file(videoFile);

      await videoPlayerController.initialize().then((_) {
        normalizedFileSize = fileSize /
            (videoPlayerController.value.duration.inMilliseconds / 1000);
        videoPlayerController.play();
        setState(() {
          trimEditor = TrimEditor(
            videoFile: videoFile,
            flipThumbnails: true,
            fit: BoxFit.fitWidth,
            maxVideoLength: Duration(seconds: 15),
            viewerHeight: 50,
            viewerWidth: MediaQuery.of(context).size.width * 0.95,
            videoPlayerController: videoPlayerController,
            circlePaintColor: Style().dazzlePrimaryColor,
            borderPaintColor: Style().dazzlePrimaryColor,
            scrubberPaintColor: Style().dazzlePrimaryColor,
            onChangeStart: (start) {
              videoStart = start;
            },
            onChangeEnd: (end) => videoEnd = end,
            onChangePlaybackState:
                (play) {}, //=> play ? videoPlayerController.play() : videoPlayerController.pause(),
          );
          videoPlayer = VideoPlayer(videoPlayerController);
        });
      });
    }
  }

  Future<int> doCompressVideo(String inputFilePath, String outputFilePath,
      String videoStart, String videoEnd) async {
    String dir = (await getTemporaryDirectory()).path;
    //File temp = new File('$dir/temp.file');

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    var ffpmpegCommands = [
      "-y",
      "-i",
      inputFilePath,
      "-ss",
      videoStart,
      "-t",
      videoEnd,
      "-c:v",
      "libx264",
      "-preset",
      serverSettings.compressionPreset,
      "-b:v",
      (serverSettings.compressionRate * 1024 * 8).toString(),
      "-filter:v",
      "scale=720:-2",
      "-pass",
      "1",
      "-f",
      "mp4",
      "-passlogfile",
      "$dir",
      "$dir/temp.file"
    ];
    if (widget.isFlipped) ffpmpegCommands.addAll(["-vf", "hflip"]);

    int res = await _flutterFFmpeg.executeWithArguments(ffpmpegCommands);
    if (res != 0) {
      //res = await doCompressVideoPanic(inputFilePath, outputFilePath, videoStart, videoEnd);
      exit(0);
      return res;
    }

    ffpmpegCommands = [
      "-y",
      "-i",
      inputFilePath,
      "-ss",
      videoStart,
      "-t",
      videoEnd,
      "-c:v",
      "libx264",
      "-preset",
      serverSettings.compressionPreset,
      "-b:v",
      (serverSettings.compressionRate * 1024 * 8).toString(),
      "-filter:v",
      "scale=720:-2",
      "-pass",
      "2",
      "-f",
      "mp4",
      "-passlogfile",
      "$dir"
    ];

    if (widget.isFlipped) ffpmpegCommands.addAll(["-vf", "hflip"]);
    ffpmpegCommands.add("$outputFilePath");

    res = await _flutterFFmpeg.executeWithArguments(ffpmpegCommands);
    if (res != 0) {
      //res = await doCompressVideoPanic(inputFilePath, outputFilePath, videoStart, videoEnd);
      return res;
    }
    return res;
  }

  Future<int> doCompressVideoPanic(String inputFilePath, String outputFilePath,
      String videoStart, String videoEnd) async {
    String dir = (await getTemporaryDirectory()).path;

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    // First pass
    var ffpmpegCommands = [
      "-y",
      "-i",
      inputFilePath,
      "-c:v",
      "libx264",
      "-preset",
      serverSettings.compressionPreset,
      "-b:v",
      (serverSettings.compressionRate * 1024 * 8).toString(),
      "-filter:v",
      "scale=720:-1",
      "-pass",
      "1",
      "-f",
      "mp4",
      "-passlogfile",
      "$dir",
      "$dir/temp.file"
    ];
    if (widget.isFlipped) ffpmpegCommands.addAll(["-vf", "hflip"]);

    int res = await _flutterFFmpeg.executeWithArguments(ffpmpegCommands);
    // Second pass
    ffpmpegCommands = [
      "-y",
      "-i",
      inputFilePath,
      "-c:v",
      "libx264",
      "-preset",
      serverSettings.compressionPreset,
      "-b:v",
      (serverSettings.compressionRate * 1024 * 8).toString(),
      "-filter:v",
      "scale=720:-1",
      "-pass",
      "2",
      "-f",
      "mp4",
      "-passlogfile",
      "$dir"
    ];

    if (widget.isFlipped) ffpmpegCommands.addAll(["-vf", "hflip"]);
    ffpmpegCommands.add("$dir/temp_encoded_file");
    res = await _flutterFFmpeg.executeWithArguments(ffpmpegCommands);

    res = await trimOnlyVideo(
        "$dir/temp_encoded_file", outputFilePath, videoStart, videoEnd);
    return res;
  }

  Future<int> trimOnlyVideo(String inputFilePath, String outputFilePath,
      String videoStart, String videoEnd) async {
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    var ffpmpegCommands = [
      "-i",
      inputFilePath,
      "-ss",
      videoStart,
      "-t",
      videoEnd,
      "-vcodec",
      "h264",
    ];
    if (widget.isFlipped) ffpmpegCommands.addAll(["-vf", "hflip"]);

    ffpmpegCommands.add("$outputFilePath");

    int res = await _flutterFFmpeg.executeWithArguments(ffpmpegCommands);
    return res;
  }

  void uploadUserVideo() async {
    setState(() {
      isUploading = true;
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        isUploading = false;
      });
      Navigator.of(context).popUntil((_) => _.isFirst);
    });
    pushNotificationService.videoUploadCallback(true);

    final Directory extDir = await Directory.systemTemp.createTemp();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    var convertedPath =
        '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}_temp.mp4';

    //var videoDuration = math.min(math.max(1, videoPlayerController.value.duration.inSeconds), 15);
    if (videoStart == null) {
      videoStart = 0;
    }
    if (videoEnd == null) {
      videoEnd = math.min(
          videoPlayerController.value.duration.inMilliseconds.toDouble(),
          15000);
    }
    videoEnd = videoEnd - videoStart;

    final sVideoSeconds = videoStart ~/ 1000;
    final sVideoMilliseconds = (videoStart - sVideoSeconds * 1000) ~/ 1;
    final sVideoDuration = sVideoSeconds > 9
        ? "00:00:$sVideoSeconds.$sVideoMilliseconds"
        : "00:00:0$sVideoSeconds.$sVideoMilliseconds";

    final eVideoSeconds = videoEnd ~/ 1000;
    final eVideoMilliseconds = (videoEnd - eVideoSeconds * 1000) ~/ 1;
    final eVideoDuration = eVideoSeconds > 9
        ? "00:00:$eVideoSeconds.$eVideoMilliseconds"
        : "00:00:0$eVideoSeconds.$eVideoMilliseconds";

    bool doCompress = false;
    if (normalizedFileSize > serverSettings.compressionRate * 1024) {
      doCompress = true;
    }
    int res = 0;
    if (doCompress) {
      res = await doCompressVideo(widget.videoPreviewPath, convertedPath,
          sVideoDuration, eVideoDuration);
    } else {
      res = await trimOnlyVideo(widget.videoPreviewPath, convertedPath,
          sVideoDuration, eVideoDuration);
    }
    var isFirstUpload = false;
    if (currentUser.mediaUrl == null) {
      isFirstUpload = true;
      FirebaseAnalytics().logEvent(
          name: 'first_video_upload', parameters: {"uid": currentUser.uid});
    } else {
      FirebaseAnalytics()
          .logEvent(name: 'video_update', parameters: {"uid": currentUser.uid});
    }

    if (res == 0){
      await currentUser.updateUserVideoFromFile(convertedPath, currentUser.uid);}

    widget.onDoneCallback(isFirstUpload);
  }

  Future<bool> _onBackButtonDuringLoading() {
    if (isUploading) return Future.value(false);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent = Container(
        child: Stack(
      children: <Widget>[
        Transform(
          alignment: Alignment.center,
          transform: widget.isFlipped
              ? Matrix4.rotationY(math.pi)
              : Matrix4.rotationY(0),
          child: Container(
            child: SizedBox.expand(
                child: new FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: videoPlayerController.value.size?.width ?? 0,
                height: videoPlayerController.value.size?.height ?? 0,
                child: videoPlayer,
              ),
            )),
          ),
        ),
        Positioned(
            top: 10,
            child: Container(
                width: MediaQuery.of(context).size.width * 1,
                child: trimEditor)),
        Positioned(
            bottom: 10,
            child: Container(
                width: MediaQuery.of(context).size.width * 1,
                child: AdvanceLoginRegisterBar(
                  forwardEnabled: true,
                  backEnabled: true,
                  buttonPressedCallback: (buttonValue) {
                    if (buttonValue == 0)
                      Navigator.pop(context);
                    else {
                      uploadUserVideo();
                    }
                  },
                ))),
      ],
    ));

    Widget beatingLogo = HeartbeatProgressIndicator(
      child: Image.asset("assets/images/logo_main.png"),
      startScale: 0.4,
      endScale: 0.5,
    );

    pageContent = Stack(children: [
      pageContent,
      isUploading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.7),
              child: beatingLogo,
            )
          : Container(),
    ]);

    return WillPopScope(
        onWillPop: () => _onBackButtonDuringLoading(),
        child: Scaffold(body: pageContent));
  }

  @override
  void dispose() {
    super.dispose();
    //videoPlayerController.dispose();
  }
}
