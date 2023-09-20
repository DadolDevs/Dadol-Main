import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:feelingapp/includes/facebook_webview.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
import '../../../routes.dart';

class AdditionalSettings extends StatefulWidget {
  final onSubmittedCallback;
  final hasErrors;

  AdditionalSettings({Key key, this.onSubmittedCallback, this.hasErrors: false})
      : super(key: key);
  @override
  _AdditionalSettings createState() => _AdditionalSettings();
}

class _AdditionalSettings extends State<AdditionalSettings>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(DadolIcons.x_back_arrow, color: Style().dadolGrey),
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          centerTitle: true,
          title: Text(
            AppLocalization.of(context).privacyAndSettings,
            style: TextStyle(color: Style().dadolGrey),
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(AppLocalization.of(context).general.toUpperCase(),
                  style: TextStyle(color: Colors.grey, fontSize: 21)),
              myExpansionTile(Icons.notifications,
                  AppLocalization.of(context).pushNotifications, [
                ListTile(
                  title: Text(AppLocalization.of(context).pushMatch),
                  trailing: Switch(
                    value: currentUser.userSettings['matchPushNotifications'],
                    onChanged: (state) {
                      setState(() {
                        currentUser.updateUserSettings(
                            "matchPushNotifications", state);
                      });
                    },
                    activeColor: Style().dazzlePrimaryColor,
                  ),
                ),
                ListTile(
                  title: Text(AppLocalization.of(context).pushMessage),
                  trailing: Switch(
                    value: currentUser.userSettings['messagePushNotifications'],
                    onChanged: (state) {
                      setState(() {
                        currentUser.updateUserSettings(
                            "messagePushNotifications", state);
                      });
                    },
                    activeColor: Style().dazzlePrimaryColor,
                  ),
                ),
                ListTile(
                  title: Text(AppLocalization.of(context).pushOther),
                  trailing: Switch(
                    value: currentUser.userSettings['otherPushNotifications'],
                    onChanged: (state) {
                      setState(() {
                        currentUser.updateUserSettings(
                            "otherPushNotifications", state);
                      });
                    },
                    activeColor: Style().dazzlePrimaryColor,
                  ),
                ),
              ]),
              myExpansionTile(
                  Icons.language, AppLocalization.of(context).language, [
                ListTile(
                  title: Text("Italiano"),
                  trailing: Switch(
                    value: currentUser.userSettings['preferredLocale'] == "it"
                        ? true
                        : false,
                    onChanged: (state) {
                      if (state == true) {
                        setState(() {
                          currentUser.updateUserSettings(
                              "preferredLocale", "it");
                          currentUser.getTagList("it");
                        });
                        AppLocalization.of(context).locale = Locale("it", "");
                      }
                    },
                    activeColor: Style().dazzlePrimaryColor,
                  ),
                ),
                ListTile(
                  title: Text("English"),
                  trailing: Switch(
                    value: currentUser.userSettings['preferredLocale'] == "en"
                        ? true
                        : false,
                    onChanged: (state) {
                      if (state == true) {
                        setState(() {
                          currentUser.updateUserSettings(
                              "preferredLocale", "en");
                          currentUser.getTagList("en");
                        });
                        AppLocalization.of(context).locale = Locale("en", "");
                      }
                    },
                    activeColor: Style().dazzlePrimaryColor,
                  ),
                ),
              ]),
              Divider(),
              Text(AppLocalization.of(context).assistance.toUpperCase(),
                  style: TextStyle(color: Colors.grey, fontSize: 21)),
              customButton(DadolIcons.x_report_problem,
                  AppLocalization.of(context).reportIssue, () {
                Navigator.push(
                    context, Routes().reportIssueRoute(RouteSettings()));
              }),
              Divider(),
              Text(AppLocalization.of(context).information.toUpperCase(),
                  style: TextStyle(color: Colors.grey, fontSize: 21)),
              outLink(Icons.book, 
                  AppLocalization.of(context).termsOfService,
                  serverSettings.termsLink),
              outLink(
                  Icons.people,
                  AppLocalization.of(context).communityManifest,
                  serverSettings.communityManifestLink),
              outLink(
                  Icons.library_books,
                  AppLocalization.of(context).privacyInfo,
                  serverSettings.privacyDocumentLink),
              outLink(DadolIcons.x_faq, "FAQ", serverSettings.faqLink),
              Divider(),
              Text(AppLocalization.of(context).account.toUpperCase(),
                  style: TextStyle(color: Colors.grey, fontSize: 21)),
              myExpansionTile(
                  Icons.person_add, AppLocalization.of(context).addSocial, [
                ListTile(
                  title: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        DadolIcons.x_facebook_logo,
                        color: Color.fromRGBO(66, 103, 178, 1),
                      ),
                      SizedBox(width: 5),
                      Text(AppLocalization.of(context).connectFacebook)
                    ],
                  ),
                  trailing: Switch(
                    value: currentUser.userSettings['socialAuth']['facebook'],
                    onChanged: (state) async {
                      if (currentUser.userSettings['loginType'] !=
                          "facebook.com") {
                        final bool fbResult = await connectFacebook(
                            currentUser.userSettings['socialAuth']['facebook']);
                        setState(() {
                          currentUser.userSettings['socialAuth']['facebook'] =
                              fbResult;
                        });
                      }
                    },
                    activeColor:
                        currentUser.userSettings['loginType'] == "facebook.com"
                            ? Colors.grey
                            : Style().dazzlePrimaryColor,
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        DadolIcons.x_google_logo,
                        color: Color.fromRGBO(219, 68, 55, 1),
                      ),
                      SizedBox(width: 5),
                      Text(AppLocalization.of(context).connectGoogle)
                    ],
                  ),
                  trailing: Switch(
                    value: currentUser.userSettings['socialAuth']['google'],
                    onChanged: (state) async {
                      if (currentUser.userSettings['loginType'] !=
                          "google.com") {
                        await connectGoogle(
                            currentUser.userSettings['socialAuth']['google']);
                        setState(() {});
                      }
                    },
                    activeColor:
                        currentUser.userSettings['loginType'] == "google.com"
                            ? Colors.grey
                            : Style().dazzlePrimaryColor,
                  ),
                ),
              ]),
              customButton(Icons.person_outline,
                  AppLocalization.of(context).accountManagement, () {
                Navigator.push(
                    context, Routes().personalSettingsPage(RouteSettings()));
              }),
              customButton(Icons.exit_to_app, AppLocalization.of(context).exit,
                  () async {
                await currentUser.forceUserLogout();
                Phoenix.rebirth(context);
              }),
            ],
          ),
        ));
  }

  Widget customButton(IconData icon, String title, onPressed) {
    return FlatButton(
        padding: EdgeInsets.only(top: 15, bottom: 15),
        onPressed: onPressed,
        child: Row(
          children: [
            SizedBox(width: 20),
            Icon(
              icon,
              color: Color.fromRGBO(96, 96, 96, 1),
            ),
            SizedBox(width: 5),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ));
  }

  Widget outLink(IconData icon, String title, String link) {
    var onPressed = () async {
      if (await canLaunch(link)) {
        await launch(link);
      }
    };
    return customButton(icon, title, onPressed);
  }

  Widget myExpansionTile(IconData icon, String title, List<Widget> children) {
    return ExpansionTileCard(
      title: Row(
        children: [
          Icon(
            icon,
            color: Color.fromRGBO(96, 96, 96, 1),
          ),
          SizedBox(width: 5),
          Text(title, style: TextStyle(color: Colors.grey)),
        ],
      ),
      children: children,
    );
  }

  Future<bool> connectGoogle(bool connected) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
      'email',
      'https://www.googleapis.com/auth/user.birthday.read',
      'https://www.googleapis.com/auth/user.gender.read',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/contacts.readonly'
    ]);

    bool isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) _googleSignIn.disconnect();

    if (connected) {
      await currentUser.updateConnectedSocials({"google": false});
      return false;
    }

    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) return false;
    } catch (Exception) {
      return false;
    }

    await currentUser.updateConnectedSocials({"google": true});
    return true;
  }

  Future<bool> connectFacebook(bool connected) async {
    String fbClientID = "831165837664793";
    String fbRedirectUrl =
        "https://www.facebook.com/connect/login_success.html";

    if (!connected) {
      String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomWebView(
                  selectedUrl:
                      'https://www.facebook.com/dialog/oauth?client_id=$fbClientID&redirect_uri=$fbRedirectUrl&response_type=token&scope=email,public_profile,',
                ),
            maintainState: true),
      );
      if (result != null) {
        await currentUser.updateConnectedSocials({"facebook": true});
        return true;
      } else {
        return false;
      }
    } else {
      await currentUser.updateConnectedSocials({"facebook": false});
      return false;
    }
  }
}
