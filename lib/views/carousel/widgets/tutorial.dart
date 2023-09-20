import 'dart:ui';
import 'package:feelingapp/main.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';

class TutorialWidget extends StatelessWidget {
  final onTapCallback;
  final type;
  TutorialWidget({this.type, @required this.onTapCallback});

  Widget buildOneRow(text, icon, context) {
    return Row(children: [
      Icon(
        icon,
        size: 90,
        color: Colors.white,
      ),
      SizedBox(width: 20),
      Flexible(
          child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 24),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (type == "tutorial")
      return tutorialWindow(context);
    else if (type == "returning") return returningWindow(context);
    else if (type == "searchbar") return searchbarTutorial(context);
    else if (type == "final") return finalRemarkTutorial(context);
    
    else if (type == "tag_list_button") return tagListButtonTutorial(context);

    else if (type == "tag_full_list") return tagListTutorial(context);
    else return SizedBox();
  }

     Widget tagListTutorial(BuildContext context) {
     return GestureDetector(
        onTap: () {
          onTapCallback();
        },
        child: Stack(children: [
          Container(
            child: Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                        child: Container(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                          Spacer(),
                          buildOneRow(AppLocalization.of(context).tagListTutorial,
                              Icons.list, context),
                          SizedBox(height: MediaQuery.of(context).size.height*0.2,)
                        ]))))),
          ),
        ]));
   }

   Widget tagListButtonTutorial(BuildContext context) {
     return GestureDetector(
        onTap: () {
          onTapCallback();
        },
        child: Stack(children: [
          Container(
            child: Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                        child: Container(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                          Spacer(),
                          buildOneRow(AppLocalization.of(context).tagListButtonTutorial,
                              Icons.list, context),
                          Spacer(),
                        ]))))),
          ),
        ]));
   }


  Widget returningWindow(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTapCallback();
        },
        child: Stack(children: [
          Container(
            child: Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                        color: Colors.black.withOpacity(0.2),
                        child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Spacer(),
                                  Flexible(
                                      child: Text(
                                          AppLocalization.of(context)
                                                  .wellcomeBack +
                                              " " +
                                              currentUser.userName +
                                              ",",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              shadows: Style()
                                                  .textOutlineWithShadows))),
                                  Flexible(
                                      child: Text(
                                          AppLocalization.of(context)
                                                  .missedyou +
                                              " ❤️",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              shadows: Style()
                                                  .textOutlineWithShadows))),
                                  Spacer(),
                                ]))))),
          ),
        ]));
  }

  Widget searchbarTutorial(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTapCallback();
        },
        child: Stack(children: [
          Container(
            child: Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                        child: Container(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                          Spacer(),
                          buildOneRow(AppLocalization.of(context).searchByTag,
                              DadolIcons.x_search, context),
                          Spacer(),
                        ]))))),
          ),
        ]));
  }

    Widget finalRemarkTutorial(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTapCallback();
        },
        child: Stack(children: [
          Container(
            child: Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                        child: Container(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                          Spacer(),
                          buildOneRow(AppLocalization.of(context).tutorialFinalRemark2,
                              DadolIcons.x_birth, context),
                          Spacer(),
                        ]))))),
          ),
        ]));
  }

  Widget tutorialWindow(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTapCallback();
        },
        child: Stack(children: [
          Container(
            child: Positioned.fill(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                        child: Container(
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                          Text(AppLocalization.of(context).tutorialTitle, textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 28)),
                          buildOneRow(
                              AppLocalization.of(context).tutorialScroll,
                              DadolIcons.x_scroll,
                              context),
                          buildOneRow(
                              AppLocalization.of(context).tutorialSingleTap,
                              DadolIcons.x_1x_tap,
                              context),
                          buildOneRow(
                              AppLocalization.of(context).tutorialDoubleTap,
                              DadolIcons.x_2x_tap,
                              context),
                        ]))))),
          ),
        ]));
  }
}
