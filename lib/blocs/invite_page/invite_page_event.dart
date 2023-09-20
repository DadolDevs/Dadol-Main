part of 'invite_page_bloc.dart';

@immutable
abstract class InvitePageEvent {}
class CreateCode extends InvitePageEvent {
  CreateCode() : super();

  @override
  List<Object> get props => [];
}