import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'playback_event.dart';

part 'playback_state.dart';

class PlaybackBloc extends Bloc<PlaybackEvent, PlaybackState> {
  PlaybackBloc() : super(InitialPlaybackState());


  @override
  Stream<PlaybackState> mapEventToState(PlaybackEvent event) async* {

    if (event is Play) {
      yield PlayingPlaybackState();
    }
    if (event is Pause) {
      yield PausedPlaybackState();
      add(Ready());
    }
    if (event is Stop) {
      yield StoppedPlaybackState();
      add(Ready());
    }
    if (event is Ready) {
      yield ReadyPlaybackState();
    }
  }


}
