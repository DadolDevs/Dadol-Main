part of 'invite_page_bloc.dart';

@immutable
abstract class InvitePageState {}

class InitialInvitePageState extends InvitePageState {}

class MissingCodeInvitePageState extends InvitePageState {}
class CreatingCodeInvitePageState extends InvitePageState {}
class CreatedCodeInvitePageState extends InvitePageState {}

///
/// ERROR
///

class ErrorInvitePageState extends InvitePageState {
  final String msg;
  final Color color;
  ErrorInvitePageState(this.msg, this.color) : super();
  @override
  String toString() => 'Error { error: $msg }';

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}