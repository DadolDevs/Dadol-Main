part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerState {}

class InitialVideoPlayerState extends VideoPlayerState {}
class LoadingVideoPlayerState extends VideoPlayerState {}
class LoadedVideoPlayerState extends VideoPlayerState {
  final Chewie videoFrame;
  LoadedVideoPlayerState(this.videoFrame) : super();
  @override
  String toString() => 'VideoFrame';

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class ErrorVideoPlayerState extends VideoPlayerState {
  final String msg;
  ErrorVideoPlayerState(this.msg) : super();
  @override
  String toString() => 'Error { error: $msg }';

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}