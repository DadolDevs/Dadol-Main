import 'package:feelingapp/includes/stream_messages.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/views/profile/widgets/tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../../../main.dart';
import '../../../routes.dart';
import 'birth_selector.dart';
import 'gender_preference_selector.dart';
import 'gender_selector.dart';
import 'nickname_selector.dart';

class UserPeronalSettings extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;

  UserPeronalSettings(
      {Key key, this.onSubmittedCallback, this.hasErrors: false})
      : super(key: key);
  @override
  _UserPeronalSettings createState() => _UserPeronalSettings();
}

class _UserPeronalSettings extends State<UserPeronalSettings>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(DadolIcons.x_back_arrow, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          centerTitle: true,
          title: Text(
            AppLocalization.of(context).accountManagement,
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                  top: 10,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05),
              height: MediaQuery.of(context).size.height - 60,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  buildNicknameSelector(),
                  buildBirthSelector(),
                  Spacer(),
                  buildGenderSelector(),
                  buildPartnerPreference(),
                  Spacer(),
                  otherButton(),
                  deleteAccount(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1)
                ],
              )),
        ));
  }

  Widget deleteAccount() {
    return RaisedButton(
      elevation: 5,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Text(
        AppLocalization.of(context).deleteAccount,
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
      onPressed: () {
        Navigator.push(context, Routes().deleteAccountPage(RouteSettings()));
      },
    );
  }

  Widget otherButton() {
    return RaisedButton(
      elevation: 5,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Text(
        AppLocalization.of(context).suspendAccount,
        style: TextStyle(color: Colors.grey, fontSize: 24),
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalization.of(context).suspendAccountTitle),
                content: Text(AppLocalization.of(context).suspendPopup),
                actions: [
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalization.of(context).cancel)),
                  FlatButton(
                      onPressed: () async {
                        await currentUser.changeAccountState("Suspended");
                        currentUser.forceUserLogout();
                        Phoenix.rebirth(context);
                      },
                      child: Text(AppLocalization.of(context).continue_))
                ],
              );
            });
      },
    );
  }

  Widget buildBirthSelector() {
    return BirthSelector(
      hasWhiteBackground: true,
      onSubmittedCallback: (val) {
        streamController.add(StreamMessage.carouselReload);
      },
    );
  }

  Widget buildNicknameSelector() {
    return NicknameSelector(
      hasWhiteBackground: true,
      onSubmittedCallback: () {},
    );
  }

  Widget buildGenderSelector() {
    return GenderSelector(
      hasWhiteBackground: true,
      onSubmittedCallback: () {
        streamController.add(StreamMessage.carouselReload);

        List<Tag> newTags = [];
        List<dynamic> newUserTags = [];
        String tagPrefix = currentUser.gender == 0 ? "m_" : "f_";
        int i = 0;
        for (i = 0; i < currentUser.additionalTags.length; i++) {
          if (currentUser.additionalTags[i]["type"] ==
              TAG_TYPE.ATTRIBUTE.index) {
            if (!currentUser.additionalTags[i]["id"].startsWith(tagPrefix)) {
              currentUser.additionalTags[i]["id"] =
                  tagPrefix + currentUser.additionalTags[i]["id"].split("_")[1];
            }
          }
          newTags.add(Tag(
              id: currentUser.additionalTags[i]["id"],
              name: "",
              type: TAG_TYPE.values[currentUser.additionalTags[i]["type"]]));
        }

        currentUser.additionalTags = newUserTags;

        currentUser.updateUserSecondaryTags(newTags);
      },
    );
  }

  Widget buildPartnerPreference() {
    return GenderPreferenceSelector(
      hasWhiteBackground: true,
      onSubmittedCallback: () {
        streamController.add(StreamMessage.carouselReload);
      },
    );
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
