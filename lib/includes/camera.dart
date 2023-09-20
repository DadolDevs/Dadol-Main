import 'dart:async';
import 'dart:io';
import 'package:feelingapp/views/sign_in/widgets/bottom_forward_backward.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:feelingapp/includes/preview_video.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class CameraCapture extends StatefulWidget {
  final onDoneCallback;

  CameraCapture({
    Key key,
    this.onDoneCallback,
  }) : super(key: key);
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  CameraController controller;
  bool _isCameraReady = false;
  bool _isRecordingMode = true;
  bool _isRecording = false;

  static const timeoutSeconds = 15000;
  static const timeout = const Duration(milliseconds: timeoutSeconds);
  static const ms = const Duration(milliseconds: 1);
  static const timerSpeed = 100;
  var timerUpdatePeriod =
      Duration(milliseconds: timerSpeed); //timeoutSeconds~/timerSpeed);

  Timer recordingTimer;
  Timer progressTimer;
  int progressrecordingValue = 0;
  String filePath;
  List<CameraDescription> cameras;

  bool isFlipped = false;
  int recordedDuration;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      // initialize cameras.
      cameras = await availableCameras();
      // initialize camera controllers.
      controller = CameraController(cameras[1], ResolutionPreset.veryHigh);

      await controller.initialize();
      if (Platform.isAndroid)
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } on CameraException catch (_) {
      // do something on error.
    }
    if (!mounted) return;
    setState(() {
      _isCameraReady = true;
    });
  }

  Future<void> _onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (controller.description == cameras[0]) ? cameras[1] : cameras[0];

    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.medium);
    
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        //showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<String> startVideoRecording() async {
    String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
    print('startVideoRecording');
    if (!controller.value.isInitialized) {
      return null;
    }
    setState(() {
      _isRecording = true;
    });

    final Directory extDir = await Directory.systemTemp.createTemp();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);

    if (controller.value.isRecordingVideo) return null;

    try {
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return null;
    }
    startTimeout();
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    stopTimer();
    setState(() {
      _isRecording = false;
    });

    try {
      XFile f = await controller.stopVideoRecording();
      filePath = f.path;
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return null;
    }
    if (recordedDuration < 1000) // at least 1 second
      return null;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewVideo(
            videoPreviewPath: filePath,
            isFlipped: (Platform.isAndroid && controller.description == cameras[1])? !isFlipped : isFlipped,
            onDoneCallback: widget.onDoneCallback,
            isFromFile: true,
          ),
        ));
  }

  void stopTimer() {
    if (recordingTimer != null) recordingTimer.cancel();

    if (progressTimer != null) progressTimer.cancel();
    recordedDuration = progressrecordingValue;
    setState(() {
      progressrecordingValue = 0;
    });
  }

  void startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    recordingTimer = Timer(duration, handleTimeoutRecording);
    progressTimer = Timer.periodic(
        timerUpdatePeriod,
        (Timer t) => setState(() {
              progressrecordingValue += timerSpeed;
            }));
  }

  void handleTimeoutRecording() {
    // callback function
    stopVideoRecording();
    debugPrint("Stopped recording!");
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      //color: Colors.black.withOpacity(0.2),
      //height: 100.0,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.7),
            radius: 30.0,
            child: Stack(children: [
              Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                  value: progressrecordingValue.toDouble() / timeoutSeconds,
                ),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    (_isRecordingMode)
                        ? (_isRecording)
                            ? Icons.stop
                            : Icons.videocam
                        : Icons.camera_alt,
                    size: 28.0,
                    color: (_isRecording) ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    if (!_isRecordingMode) {
                    } else {
                      if (_isRecording) {
                        stopVideoRecording();
                      } else {
                        startVideoRecording();
                      }
                    }
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) return Container();
    final size = MediaQuery.of(context).size;
    final deviceRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        extendBody: true,
        //bottomNavigationBar: _buildBottomNavigationBar(),
        body: Stack(children: [
          Transform(
              alignment: Alignment.center,
              transform:
                  isFlipped ? Matrix4.rotationY(math.pi) : Matrix4.rotationY(0),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: isFlipped
                      ? Matrix4.rotationY(2 * math.pi)
                      : Matrix4.rotationY(0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 1,
                    child: SizedBox.expand(
                        child: new FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: CameraPreview(controller),
                      ),
                    )),
                  ),
                ),
              )),
          Positioned(
            top: 60.0,
            left: 10.0,
            child: Container(
                child: RawMaterialButton(
              onPressed: () {
                if (_isRecording == false) _onCameraSwitch();
              },
              elevation: 2.0,
              //fillColor: Colors.white,
              child: Icon(
                Icons.switch_camera,
                size: 40.0,
                color: Colors.white,
              ),
              shape: CircleBorder(),
            )),
          ),
          Positioned(
            top: 130.0,
            left: 10,
            child: Container(
                child: RawMaterialButton(
              onPressed: () {
                if (_isRecording == false)
                  setState(() {
                    isFlipped = !isFlipped;
                  });
              },
              elevation: 2.0,
              //fillColor: Colors.white,
              child: Icon(
                Icons.flip,
                size: 40.0,
                color: Colors.white,
              ),
              shape: CircleBorder(),
            )),
          ),
          Positioned(
              bottom: 10,
              child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  child: AdvanceLoginRegisterBar(
                    forwardEnabled: false,
                    backEnabled: true,
                    buttonPressedCallback: (buttonValue) {
                      Navigator.pop(context);
                    },
                  ))),
                  Positioned(child:_buildBottomNavigationBar(), bottom: 50)
        ]));
  }
}
