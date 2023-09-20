part of 'playback_bloc.dart';

@immutable
abstract class PlaybackState {}

class InitialPlaybackState extends PlaybackState {}
class ReadyPlaybackState extends PlaybackState {}
class PlayingPlaybackState extends PlaybackState {}
class PausedPlaybackState extends PlaybackState {}
class StoppedPlaybackState extends PlaybackState {}