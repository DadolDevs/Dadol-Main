import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/main.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'invite_page_event.dart';

part 'invite_page_state.dart';

class InvitePageBloc extends Bloc<InvitePageEvent, InvitePageState> {
  InvitePageBloc() : super(InitialInvitePageState());

  @override
  Stream<InvitePageState> mapEventToState(InvitePageEvent event) async* {
    if (event is CreateCode) {
      yield (CreatingCodeInvitePageState());
      try {
        QuerySnapshot snapshot;
        String tmpCode;
        int tentativi = 0;
        bool isNew = false;
        while (!isNew&&tentativi<10) {
          tentativi++;
          tmpCode = getRandomString(6);
          snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('promoCode', isEqualTo: tmpCode)
              .limit(1)
              .get();
          isNew = snapshot.size == 0;
        }

        if (tentativi == 10) {
          yield (ErrorInvitePageState("Unable to fetch code, retry", Colors.orangeAccent));
        } else{
          //got a new code, update user
          await currentUser.updatePromoCode(tmpCode);
          yield (CreatedCodeInvitePageState());
        }

      } catch (exception) {
        yield (ErrorInvitePageState(exception.toString(), Colors.redAccent));
      }
    }
  }

  static const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
