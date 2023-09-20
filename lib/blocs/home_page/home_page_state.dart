part of 'home_page_bloc.dart';

@immutable
abstract class HomePageState {}

class InitialHomePageState extends HomePageState {}
class CompleteProfileHomePageState extends HomePageState {}
class VideoAcceptedHomePageState extends HomePageState {}
class VideoRefusedHomePageState extends HomePageState {}

///
/// ERROR
///

class ErrorHomePageState extends HomePageState {
  final String msg;
  final Color color;
  ErrorHomePageState(this.msg, this.color) : super();
  @override
  String toString() => 'Error { error: $msg }';

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}