import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:feelingapp/includes/user.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/views/new_user/new_user.dart';
import 'package:feelingapp/views/sign_in/landing.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/main.dart';
import 'package:feelingapp/views/home_screen.dart';
import 'package:feelingapp/includes/auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location_service;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  AppLifecycleState lifecycleState;
  bool _userModelLoaded = false;
  bool _settingsLoaded = false;
  bool _waitingTimerComplete = false;
  Timer _waitingTimer;
  bool _connectedToInternet = true;
  bool _versionChecked = false;

  @override
  void initState() {
    // Check if the user il logged in
    WidgetsBinding.instance.addObserver(this);
    // Load settings
    serverSettings.initialize().then((finished) {
      setState(() {
        _settingsLoaded = true;
      });

      // Perform authentication
      auth.startUp().then((finished) {
        setState(() {
          authStatus = auth.getAuthStatus();
        });
        var uid = auth.getUserId();
        // Create user model
        createUserModel(uid);
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    precacheImages();
    super.didChangeDependencies();
  }

  Widget buildWaitingScreen() {
    _waitingTimerComplete = false;
    if (_waitingTimer != null) _waitingTimer.cancel();

    _waitingTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _waitingTimerComplete = true;
      });
    });

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Container(
            margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.25,
                right: MediaQuery.of(context).size.width * 0.25),
            child: Image.asset("assets/images/logo_main.png")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIOverlays([]);

    if (_connectedToInternet == false) {}

    if (_settingsLoaded == false ||
        _userModelLoaded == false ||
        _waitingTimerComplete == false) {
      return buildWaitingScreen();
    }

    if (authStatus == AuthStatus.NOT_LOGGED_IN) {
      return LandingPage(auth: auth);
    } else if (authStatus == AuthStatus.LOGGED_IN) {
      if (currentUser.registrationStage ==
          RegistrationStage.REGISTERED_BUT_MISSING_DATA.index)
        return NewUserScreen();
      else
        return HomeScreen();
    }
    return HomeScreen();
  }

  Future<void> precacheImages() async {
    await precacheImage(AssetImage("assets/images/intro_image.jpg"), context);
    await precacheImage(AssetImage("assets/images/logo_main.png"), context);
    await precacheImage(
        AssetImage("assets/images/launcher_logo_dadol.png"), context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("Change occured");
    if (state == AppLifecycleState.paused) {
      stopPeriodicTimers();
    }
    if (state == AppLifecycleState.resumed) {
      if (currentUser.uid != null) {
        currentUser.keepUserAliveOnServer();
        stopPeriodicTimers();
        startPeriodicTimers();
      } else {
        Navigator.pushNamed(context, '/root');
      }
    }
  }

  /// Creates the current user model and store it in a global variable
  void createUserModel(uid) async {
    // Check internet connection
    /*_connectedToInternet = await checkInternetConnectivity();
    if (_connectedToInternet == false) {
      await buildErroDialog(AppLocalization.of(context).noInternetTitle,
          AppLocalization.of(context).noInternetBody, [
        AppLocalization.of(context).continue_
      ], [
        () {
          //exit(0);
        }
      ]);
    }*/
    checkInternetConnectivity().then((value) async {
      if (value == false) {
        await buildErroDialog(AppLocalization.of(context).noInternetTitle,
            AppLocalization.of(context).noInternetBody, [
          AppLocalization.of(context).continue_
        ], [
          () {
            exit(0);
          }
        ]);
      }
    });

    // Load current user data from the DB and create the user model
    var userSnapshot;
    try {
      userSnapshot = await dbManager.getCurrentUserDocument(uid);
      // Account has been deleted or something
      if (userSnapshot == null) {
        auth.logoutCallback();
        Phoenix.rebirth(context);
      }
    } catch (e) {
      // User not logged in
      if (authStatus == AuthStatus.LOGGED_IN)
        authStatus = AuthStatus.NOT_LOGGED_IN;
      setState(() {
        _userModelLoaded = true;
      });
      return;
    }

    currentUser = AppUser.map(userSnapshot);

    // Note those functions must remain combined. updateSocialLogin must be called after loadUserSettings
    var userSettingsFuture = currentUser
        .loadUserSettings(Localizations.localeOf(context).languageCode)
        .then((value) {
      currentUser.updateLoginType(auth.user.providerData[0].providerId);
      AppLocalization.of(context).locale =
          Locale(currentUser.userSettings['preferredLocale'], "");
      // Load tags
      currentUser.getTagList(currentUser.userSettings["preferredLocale"]);
    });

    var userMediaUrlsFuture = currentUser.loadMediaUrls();

    // Update FCM token
    pushNotificationService.recordFCMToken();
    pushNotificationService.setLogoutCallback(() async {
      await currentUser.forceUserLogout();
      Phoenix.rebirth(context);
    });

    // Enable position and store new user position
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await buildErroDialog(AppLocalization.of(context).geolocationEnableTitle,
          AppLocalization.of(context).geolocationDeniedForeverBody, [
        AppLocalization.of(context).continue_
      ], [
        () {
            exit(0);
        }
      ]);
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        await buildErroDialog(
            AppLocalization.of(context).geolocationEnableTitle,
            AppLocalization.of(context).geolocationDeniedForeverBody, [
          AppLocalization.of(context).continue_
        ], [
          () {
              exit(0);
          }
        ]);
      }
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await location_service.Location().requestService();
    }

    if (sharedPrefs.getDouble("position.latitude") == null &&
        sharedPrefs.getDouble("position.longitude") == null)
      await userPositionUpdate();
    else
      userPositionUpdate();

    currentUser.updateLastLogin(Timestamp.now());
    startPeriodicTimers();

    await userSettingsFuture;
    await userMediaUrlsFuture;
    await checkAppVersion().then((value) {
          _versionChecked = true;
        });

    setState(() {
      _userModelLoaded = true;
    });

    // Returning user
    if (currentUser.accountState == "Suspended") {
      if ( currentUser.mediaUrl != "")
        currentUser.changeAccountState("Active");
    }

    // Debug
    debugPrint("User loaded:");
    debugPrint(userSnapshot.toString());
  }

  Future<void> buildErroDialog(String title, String body,
      List<String> actionsText, List<dynamic> actionActions) async {
    List<Widget> actions = [];
    assert(actionsText.length == actionActions.length);
    assert(actionsText.length > 0);
    for (int i = 0; i < actionsText.length; i++) {
      actions.add(
          FlatButton(onPressed: actionActions[i], child: Text(actionsText[i])));
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: actions,
          );
        });
  }

  Future<void> userPositionUpdate() async {
    try {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10));

      currentUser.updateGeolocation(Geoflutterfire()
          .point(latitude: position.latitude, longitude: position.longitude));
      sharedPrefs.setDouble("position.latitude", position.latitude);
      sharedPrefs.setDouble("position.longitude", position.longitude);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void startPeriodicTimers() {
    if (userPeriodicTimers.length == 0) {
      userPeriodicTimers.add(Timer.periodic(
          Duration(seconds: serverSettings.keepAliveInterval),
          (Timer t) => currentUser.keepUserAliveOnServer()));
      userPeriodicTimers.add(Timer.periodic(
          Duration(seconds: 10), (Timer t) => userPositionUpdate()));
    } else {
      userPeriodicTimers[0] = Timer.periodic(
          Duration(seconds: serverSettings.keepAliveInterval),
          (Timer t) => currentUser.keepUserAliveOnServer());
      userPeriodicTimers[1] = Timer.periodic(
          Duration(seconds: 10), (Timer t) => userPositionUpdate());
    }
  }

  void stopPeriodicTimers() {
    for (int i = 0; i < userPeriodicTimers.length; i++)
      userPeriodicTimers[i].cancel();
  }

  Future<void> checkAppVersion() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) async {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      var currentVersion = version.split(".");
      var minVersion = serverSettings.minAppVersionThreshold.split(".");
      bool needUpdate = false;

      if (int.parse(currentVersion[0]) < int.parse(minVersion[0])) {
        needUpdate = true;
      } else if (int.parse(currentVersion[0]) == int.parse(minVersion[0]) &&
          int.parse(currentVersion[1]) < int.parse(minVersion[1])) {
        needUpdate = true;
      } else if (int.parse(currentVersion[0]) == int.parse(minVersion[0]) &&
          int.parse(currentVersion[1]) == int.parse(minVersion[1]) &&
          int.parse(currentVersion[2]) < int.parse(minVersion[2])) {
        needUpdate = true;
      }

      if (needUpdate)
        await buildErroDialog(AppLocalization.of(context).newVersionTitle,
            AppLocalization.of(context).newVersionBody, [
          AppLocalization.of(context).continue_
        ], [
          () {
            if (Platform.isIOS)
              launch(serverSettings.iosStoreLink);
            else
              launch(serverSettings.googleStoreLink);
            exit(0);
          }
        ]);
    });
  }

  Future<bool> checkInternetConnectivity() async {
    var connResult = await (Connectivity().checkConnectivity());
    if (connResult == ConnectivityResult.mobile) {
      return true;
    } else if (connResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
