import 'dart:async';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:feelingapp/includes/user.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'home_page_event.dart';

part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final AppUser appUser;
  HomePageBloc({@required this.appUser}) : super(InitialHomePageState());

  @override
  Stream<HomePageState> mapEventToState(HomePageEvent event) async* {
    if (event is SendLike ||
        event is FilterWithTags ||
        event is EditProfileTags ||
        event is VideoLimitReached) {
      try {
        if (appUser.accountState != "Pending" && appUser.accountState != "ActiveWithVideo") {
          yield (CompleteProfileHomePageState());
        }
      } catch (exception) {
        yield (ErrorHomePageState(exception, Colors.redAccent));
      } finally {
        yield (InitialHomePageState());
      }
    }
  }
}
