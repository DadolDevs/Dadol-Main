import 'dart:io';

import 'package:feelingapp/includes/video_trimmer/thumbnail_viewer.dart';
import 'package:feelingapp/includes/video_trimmer/trim_editor_painter.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TrimEditor extends StatefulWidget {
  /// For defining the total trimmer area width
  final double viewerWidth;

  /// For defining the total trimmer area height
  final double viewerHeight;

  /// For defining the image fit type of each thumbnail image.
  ///
  /// By default it is set to `BoxFit.fitHeight`.
  final BoxFit fit;

  /// For defining the maximum length of the output video.
  final Duration maxVideoLength;

  /// For specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  ///
  /// By default it is set to `5.0`.
  final double circleSize;

  /// For specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`.
  ///
  /// By default it is set to `8.0`.
  final double circleSizeOnDrag;

  /// For specifying a color to the circle.
  ///
  /// By default it is set to `Colors.white`.
  final Color circlePaintColor;

  /// For specifying a color to the border of
  /// the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color borderPaintColor;

  /// For specifying a color to the video
  /// scrubber inside the trim area.
  ///
  /// By default it is set to `Colors.white`.
  final Color scrubberPaintColor;

  /// For specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  final int thumbnailQuality;

  /// For showing the start and the end point of the
  /// video on top of the trimmer area.
  ///
  /// By default it is set to `true`.
  final bool showDuration;

  /// For providing a `TextStyle` to the
  /// duration text.
  ///
  /// By default it is set to `TextStyle(color: Colors.white)`
  final TextStyle durationTextStyle;

  /// Callback to the video start position
  ///
  /// Returns the selected video start position in `milliseconds`.
  final Function(double startValue) onChangeStart;

  /// Callback to the video end position.
  ///
  /// Returns the selected video end position in `milliseconds`.
  final Function(double endValue) onChangeEnd;

  /// Callback to the video playback
  /// state to know whether it is currently playing or paused.
  ///
  /// Returns a `boolean` value. If `true`, video is currently
  /// playing, otherwise paused.
  final Function(bool isPlaying) onChangePlaybackState;

  var videoFile;

  VideoPlayerController videoPlayerController;

  var flipThumbnails;

  /// Widget for displaying the video trimmer.
  ///
  /// This has frame wise preview of the video with a
  /// slider for selecting the part of the video to be
  /// trimmed.
  ///
  /// The required parameters are [viewerWidth] & [viewerHeight]
  ///
  /// * [viewerWidth] to define the total trimmer area width.
  ///
  ///
  /// * [viewerHeight] to define the total trimmer area height.
  ///
  ///
  /// The optional parameters are:
  ///
  /// * [fit] for specifying the image fit type of each thumbnail image.
  /// By default it is set to `BoxFit.fitHeight`.
  ///
  ///
  /// * [maxVideoLength] for specifying the maximum length of the
  /// output video.
  ///
  ///
  /// * [circleSize] for specifying a size to the holder at the
  /// two ends of the video trimmer area, while it is `idle`.
  /// By default it is set to `5.0`.
  ///
  ///
  /// * [circleSizeOnDrag] for specifying a size to the holder at
  /// the two ends of the video trimmer area, while it is being
  /// `dragged`. By default it is set to `8.0`.
  ///
  ///
  /// * [circlePaintColor] for specifying a color to the circle.
  /// By default it is set to `Colors.white`.
  ///
  ///
  /// * [borderPaintColor] for specifying a color to the border of
  /// the trim area. By default it is set to `Colors.white`.
  ///
  ///
  /// * [scrubberPaintColor] for specifying a color to the video
  /// scrubber inside the trim area. By default it is set to
  /// `Colors.white`.
  ///
  ///
  /// * [thumbnailQuality] for specifying the quality of each
  /// generated image thumbnail, to be displayed in the trimmer
  /// area.
  ///
  ///
  /// * [showDuration] for showing the start and the end point of the
  /// video on top of the trimmer area. By default it is set to `true`.
  ///
  ///
  /// * [durationTextStyle] is for providing a `TextStyle` to the
  /// duration text. By default it is set to
  /// `TextStyle(color: Colors.white)`
  ///
  ///
  /// * [onChangeStart] is a callback to the video start position.
  ///
  ///
  /// * [onChangeEnd] is a callback to the video end position.
  ///
  ///
  /// * [onChangePlaybackState] is a callback to the video playback
  /// state to know whether it is currently playing or paused.
  ///
  TrimEditor({
    @required this.viewerWidth,
    @required this.viewerHeight,
    @required this.videoFile,
    @required this.videoPlayerController,
    this.fit = BoxFit.fitHeight,
    this.maxVideoLength = const Duration(milliseconds: 0),
    this.circleSize = 5.0,
    this.flipThumbnails = false,
    this.circleSizeOnDrag = 8.0,
    this.circlePaintColor = Colors.white,
    this.borderPaintColor = Colors.white,
    this.scrubberPaintColor = Colors.white,
    this.thumbnailQuality = 75,
    this.showDuration = true,
    this.durationTextStyle = const TextStyle(
      color: Colors.white,
    ),
    this.onChangeStart,
    this.onChangeEnd,
    this.onChangePlaybackState,
  })  : assert(viewerWidth != null),
        assert(viewerHeight != null),
        assert(fit != null),
        assert(maxVideoLength != null),
        assert(circleSize != null),
        assert(circleSizeOnDrag != null),
        assert(circlePaintColor != null),
        assert(borderPaintColor != null),
        assert(scrubberPaintColor != null),
        assert(thumbnailQuality != null),
        assert(showDuration != null),
        assert(durationTextStyle != null);

  @override
  _TrimEditorState createState() => _TrimEditorState();
}

class _TrimEditorState extends State<TrimEditor> with TickerProviderStateMixin {
  File _videoFile;

  double _videoStartPos = 0.0;
  double _videoEndPos = 0.0;

  bool _canUpdateStart = true;
  bool _isLeftDrag = true;

  Offset _startPos = Offset(0, 0);
  Offset _endPos = Offset(0, 0);

  double _startFraction = 0.0;
  double _endFraction = 1.0;

  int _videoDuration = 0;
  int _currentPosition = 0;

  double _thumbnailViewerW = 0.0;
  double _thumbnailViewerH = 0.0;

  int _numberOfThumbnails = 0;

  double _circleSize;

  double fraction;
  double maxLengthPixels;

  ThumbnailViewer thumbnailWidget;

  Animation<double> _scrubberAnimation;
  AnimationController _animationController;
  Tween<double> _linearTween;

  bool videoSemaphore = false;
  bool shouldStartVideo = false;

  Future<void> _initializeVideoController() async {
    if (_videoFile != null) {
      widget.videoPlayerController.addListener(() {
        final bool isPlaying = widget.videoPlayerController.value.isPlaying;

        if (isPlaying) {
          widget.onChangePlaybackState(true);
          setState(() {
            _currentPosition =
                widget.videoPlayerController.value.position.inMilliseconds;

            if (_currentPosition > _videoEndPos.toInt()) {
              widget.onChangePlaybackState(false);
              widget.videoPlayerController.pause();
              _animationController.stop();
            } else {
              if (!_animationController.isAnimating) {
                widget.onChangePlaybackState(true);
                _animationController.forward();
              }
            }
          });
        } else {
          if (widget.videoPlayerController.value.isInitialized) {
            if (_animationController != null) {
              if ((_scrubberAnimation.value).toInt() == (_endPos.dx).toInt()) {
                _animationController.reset();
              }
              _animationController.stop();
              widget.onChangePlaybackState(false);
            }
          }
        }
      });

      widget.videoPlayerController.setVolume(1.0);
      _videoDuration =
          widget.videoPlayerController.value.duration.inMilliseconds;
      print(_videoFile.path);

      _videoEndPos = fraction != null
          ? _videoDuration.toDouble() * fraction
          : _videoDuration.toDouble();

      widget.onChangeEnd(_videoEndPos);

      final ThumbnailViewer _thumbnailWidget = ThumbnailViewer(
        videoFile: _videoFile,
        videoDuration: _videoDuration,
        fit: widget.fit,
        thumbnailHeight: _thumbnailViewerH,
        numberOfThumbnails: _numberOfThumbnails,
        quality: widget.thumbnailQuality,
      );
      thumbnailWidget = _thumbnailWidget;
    }
  }

  void _startVideoFromTap(TapDownDetails details) async {
    double startFrom = 0;
    if (details.localPosition.dx > _startPos.dx &&
        details.localPosition.dx < _thumbnailViewerW &&
        details.localPosition.dx < _endPos.dx) {
      startFrom =
          (details.localPosition.dx / _thumbnailViewerW) * _startFraction;
      await widget.videoPlayerController.pause();
      await widget.videoPlayerController
          .seekTo(Duration(milliseconds: startFrom.toInt()));
      _linearTween.begin = details.localPosition.dx;
      _animationController.duration =
          Duration(milliseconds: (_videoEndPos - startFrom).toInt());
      _animationController.reset();
      widget.videoPlayerController.play();
    }
  }

  void _setVideoStartPosition(DragUpdateDetails details) async {
    if (!(_startPos.dx + details.delta.dx < 0) &&
        !(_startPos.dx + details.delta.dx > _thumbnailViewerW) &&
        !(_startPos.dx + details.delta.dx > _endPos.dx)) {
      if (maxLengthPixels != null) {
        if (!(_endPos.dx - _startPos.dx - details.delta.dx > maxLengthPixels)) {
          setState(() {
            if (!(_startPos.dx + details.delta.dx < 0))
              _startPos += details.delta;

            _startFraction = (_startPos.dx / _thumbnailViewerW);

            _videoStartPos = _videoDuration * _startFraction;
            widget.onChangeStart(_videoStartPos);
          });
          videoSemaphore = true;
          await widget.videoPlayerController.pause();
          await widget.videoPlayerController
              .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
          _linearTween.begin = _startPos.dx;
          _animationController.duration =
              Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
          _animationController.reset();
          videoSemaphore = false;
          if (shouldStartVideo == true) {
            startVideo();
          }
        }
      } else {
        setState(() {
          if (!(_startPos.dx + details.delta.dx < 0))
            _startPos += details.delta;

          _startFraction = (_startPos.dx / _thumbnailViewerW);

          _videoStartPos = _videoDuration * _startFraction;
          widget.onChangeStart(_videoStartPos);
        });
        videoSemaphore = true;
        await widget.videoPlayerController.pause();
        await widget.videoPlayerController
            .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
        _linearTween.begin = _startPos.dx;
        _animationController.duration =
            Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
        _animationController.reset();
        videoSemaphore = false;
        if (shouldStartVideo == true) {
          startVideo();
        }
      }
    }
  }

  void _setVideoEndPosition(DragUpdateDetails details) async {
    if (!(_endPos.dx + details.delta.dx > _thumbnailViewerW) &&
        !(_endPos.dx + details.delta.dx < 0) &&
        !(_endPos.dx + details.delta.dx < _startPos.dx)) {
      if (maxLengthPixels != null) {
        if (!(_endPos.dx - _startPos.dx + details.delta.dx > maxLengthPixels)) {
          setState(() {
            _endPos += details.delta;
            _endFraction = _endPos.dx / _thumbnailViewerW;

            _videoEndPos = _videoDuration * _endFraction;
            widget.onChangeEnd(_videoEndPos);
          });
          videoSemaphore = true;
          await widget.videoPlayerController.pause();
          await widget.videoPlayerController
              .seekTo(Duration(milliseconds: _videoEndPos.toInt()));
          _linearTween.end = _endPos.dx;
          _animationController.duration =
              Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
          _animationController.reset();
          videoSemaphore = false;

          startVideo();
        }
      } else {
        setState(() {
          _endPos += details.delta;
          _endFraction = _endPos.dx / _thumbnailViewerW;

          _videoEndPos = _videoDuration * _endFraction;
          widget.onChangeEnd(_videoEndPos);
        });
        videoSemaphore = true;
        await widget.videoPlayerController.pause();
        await widget.videoPlayerController
            .seekTo(Duration(milliseconds: _videoEndPos.toInt()));
        //await widget.videoPlayerController.seekTo(Duration(milliseconds: _videoStartPos.toInt()));
        _linearTween.end = _endPos.dx;
        _animationController.duration =
            Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt());
        _animationController.reset();
        videoSemaphore = false;
        //if (shouldStartVideo == true) {
        startVideo();
        //}
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _circleSize = widget.circleSize;

    _videoFile = widget.videoFile;
    _thumbnailViewerH = widget.viewerHeight;

    _numberOfThumbnails = widget.viewerWidth ~/ _thumbnailViewerH;

    _thumbnailViewerW = _numberOfThumbnails * _thumbnailViewerH;

    Duration totalDuration = widget.videoPlayerController.value.duration;

    if (widget.maxVideoLength > Duration(milliseconds: 0) &&
        widget.maxVideoLength < totalDuration) {
      if (widget.maxVideoLength < totalDuration) {
        fraction =
            widget.maxVideoLength.inMilliseconds / totalDuration.inMilliseconds;

        maxLengthPixels = _thumbnailViewerW * fraction;
      }
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_videoEndPos - _videoStartPos).toInt()),
    );

    _initializeVideoController();
    _endPos = Offset(
      maxLengthPixels != null ? maxLengthPixels : _thumbnailViewerW,
      _thumbnailViewerH,
    );

    // Defining the tween points
    _linearTween = Tween(begin: _startPos.dx, end: _endPos.dx);

    _scrubberAnimation = _linearTween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.stop();
        }
      });
  }

  @override
  void dispose() {
    widget.videoPlayerController.pause();
    widget.onChangePlaybackState(false);
    if (_videoFile != null) {
      widget.videoPlayerController.setVolume(0.0);
      widget.videoPlayerController.pause();
      widget.videoPlayerController.dispose();
      widget.onChangePlaybackState(false);
    }
    super.dispose();
  }

  void startVideo() async {
    shouldStartVideo = false;
    if (videoSemaphore == true) {
      shouldStartVideo = true;
      debugPrint(
          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    } else {
      await widget.videoPlayerController
          .seekTo(Duration(milliseconds: _videoStartPos.toInt()));
      widget.videoPlayerController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        print("Tapped down");
        print(details.localPosition);
        print((_startPos.dx - details.localPosition.dx).abs());
        print((_endPos.dx - details.localPosition.dx).abs());
        //_startVideoFromTap(details);
      },
      onHorizontalDragStart: (DragStartDetails details) {
        print("START");
        print(details.localPosition);
        print((_startPos.dx - details.localPosition.dx).abs());
        print((_endPos.dx - details.localPosition.dx).abs());

        if (_endPos.dx >= _startPos.dx) {
          if ((_startPos.dx - details.localPosition.dx).abs() >
              (_endPos.dx - details.localPosition.dx).abs()) {
            setState(() {
              _canUpdateStart = false;
            });
          } else {
            setState(() {
              _canUpdateStart = true;
            });
          }
        } else {
          if (_startPos.dx > details.localPosition.dx) {
            _isLeftDrag = true;
          } else {
            _isLeftDrag = false;
          }
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        startVideo();
        setState(() {
          _circleSize = widget.circleSize;
        });
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _circleSize = widget.circleSizeOnDrag;

        if (_endPos.dx >= _startPos.dx) {
          _isLeftDrag = false;
          if (_canUpdateStart && _startPos.dx + details.delta.dx > 0) {
            _isLeftDrag = false; // To prevent from scrolling over
            _setVideoStartPosition(details);
          } else if (!_canUpdateStart &&
              _endPos.dx + details.delta.dx < _thumbnailViewerW) {
            _isLeftDrag = true; // To prevent from scrolling over
            _setVideoEndPosition(details);
          }
        } else {
          if (_isLeftDrag && _startPos.dx + details.delta.dx > 0) {
            _setVideoStartPosition(details);
          } else if (!_isLeftDrag &&
              _endPos.dx + details.delta.dx < _thumbnailViewerW) {
            _setVideoEndPosition(details);
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        child:Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.showDuration
              ? Container(
                  width: _thumbnailViewerW,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          Duration(milliseconds: _videoStartPos.toInt())
                              .toString()
                              .split('.')[0],
                          style: widget.durationTextStyle,
                        ),
                        Text(
                          Duration(milliseconds: _videoEndPos.toInt())
                              .toString()
                              .split('.')[0],
                          style: widget.durationTextStyle,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          Container(
            child: CustomPaint(
              foregroundPainter: TrimEditorPainter(
                startPos: _startPos,
                endPos: _endPos,
                scrubberAnimationDx: _scrubberAnimation.value,
                circleSize: _circleSize,
                circlePaintColor: widget.circlePaintColor,
                borderPaintColor: widget.borderPaintColor,
                scrubberPaintColor: widget.scrubberPaintColor,
              ),
              child: Container(
                color: Colors.grey[900],
                height: _thumbnailViewerH,
                width: _thumbnailViewerW,
                child: thumbnailWidget == null ? Column() : thumbnailWidget,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
