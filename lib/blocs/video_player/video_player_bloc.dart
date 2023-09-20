import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

part 'video_player_event.dart';

part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc() : super(InitialVideoPlayerState());

  ChewieController chewieController;
  VideoPlayerController videoPlayerController;

  @override
  Stream<VideoPlayerState> mapEventToState(VideoPlayerEvent event) async* {

    if (event is LoadVideo) {
      try {
        yield LoadingVideoPlayerState();

        if (event.readFromFile)
          videoPlayerController =
              VideoPlayerController.file(File(event.mediaUrl));
        else {
          File f = await _downloadAndCacheVideo(event.mediaUrl);
          if (f == null) {
            return;
          }
          videoPlayerController = VideoPlayerController.file(f);
        }

        debugPrint(videoPlayerController.dataSource);
        await videoPlayerController.initialize();

        debugPrint("video url from video: " + event.mediaUrl);
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: event.isAutoPlaying,
          autoInitialize: true,
          looping: event.isLooping,
          showControls: false,
          allowFullScreen: false,
          allowMuting: false,
        );

        chewieController.addListener(() {
          if (videoPlayerController.value.position ==
              videoPlayerController.value.duration &&
              !videoPlayerController.value.isPlaying) {
            print("finished");
            //add(Pause());
          }
        });
        Chewie videoFrame = Chewie(controller: chewieController);

        yield LoadedVideoPlayerState(videoFrame);
      } catch (e) {
        yield InitialVideoPlayerState();
      }
    }
  }

  Future<File> _downloadAndCacheVideo(String videoUrl) async {
    try {
      final cacheManager = DefaultCacheManager();

      FileInfo fileInfo;

      fileInfo = await cacheManager
          .getFileFromCache(videoUrl); // Get video from cache first

      if (fileInfo?.file == null) {
        fileInfo = await cacheManager
            .downloadFile(videoUrl).onError((error, stackTrace){
              return null;
        }); // Download video if not cached yet
      }

      return fileInfo?.file;
    } catch (e) {
      throw (e);
    }
  }
}
