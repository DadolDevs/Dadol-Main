part of 'playback_bloc.dart';

@immutable
abstract class PlaybackEvent {}

class Play extends PlaybackEvent {
  Play() : super();

  @override
  List<Object> get props => [];
}

class Pause extends PlaybackEvent {
  Pause() : super();

  @override
  List<Object> get props => [];
}

class Stop extends PlaybackEvent {
  Stop() : super();

  @override
  List<Object> get props => [];
}

class Ready extends PlaybackEvent {
  Ready() : super();

  @override
  List<Object> get props => [];
}

