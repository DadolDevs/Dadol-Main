part of 'home_page_bloc.dart';

@immutable
abstract class HomePageEvent {}

class SendLike extends HomePageEvent {
  SendLike() : super();

  @override
  List<Object> get props => [];
}

class FilterWithTags extends HomePageEvent {
  FilterWithTags() : super();

  @override
  List<Object> get props => [];
}

class EditProfileTags extends HomePageEvent {
  EditProfileTags() : super();

  @override
  List<Object> get props => [];
}

class VideoLimitReached extends HomePageEvent {
  VideoLimitReached() : super();

  @override
  List<Object> get props => [];
}