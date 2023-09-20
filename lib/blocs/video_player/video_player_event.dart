part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerEvent {}

class LoadVideo extends VideoPlayerEvent {
  final String mediaUrl;
  final String thumbnailUrl;
  final bool readFromFile;
  final bool isAutoPlaying;
  final bool isLooping;
  LoadVideo(this.mediaUrl, this.thumbnailUrl, this.readFromFile,
      this.isAutoPlaying, this.isLooping)
      : super();

  @override
  List<Object> get props => [];
}

class Ended extends VideoPlayerEvent {
  Ended() : super();

  @override
  List<Object> get props => [];
}

class RaiseVideoPlayerError extends VideoPlayerEvent {
  final String errorMsg;
  RaiseVideoPlayerError(this.errorMsg) : super();

  @override
  List<Object> get props => [];
}
