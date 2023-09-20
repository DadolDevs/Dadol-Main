import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/views/messages/chat.dart';
import 'package:feelingapp/views/new_user/new_user.dart';
import 'package:feelingapp/views/profile/widgets/additional_settings.dart';
import 'package:feelingapp/views/profile/widgets/report_an_issue_page.dart';
import 'package:feelingapp/views/profile/widgets/user_delete_account_page.dart';
import 'package:feelingapp/views/profile/widgets/user_personal_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/views/profile/profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'includes/camera.dart';
import 'main.dart';
import 'views/sign_in/login_page.dart';
import 'views/home_screen.dart';
import 'package:feelingapp/views/root/root.dart';

class Routes {
  MyCustomRoute loginRoute(RouteSettings settings) {
    return new MyCustomRoute(
      builder: (_) => new LoginPage(),
      settings: settings,
    );
  }

  MyCustomRoute homeRoute(RouteSettings settings) {
    return new MyCustomRoute(
      builder: (_) => new HomeScreen(),
      settings: settings,
    );
  }

  MyCustomRoute cameraRoute(RouteSettings settings) {
    return new MyCustomRoute(
      builder: (_) => new CameraCapture(),
      settings: settings,
    );
  }

  MyCustomRoute previewVideoRoute(RouteSettings settings) {
    return new MyCustomRoute(
      builder: (_) => new CameraCapture(),
      settings: settings,
    );
  }

  MyCustomRoute rootRoute(RouteSettings settings) {
    return new MyCustomRoute(
      builder: (_) => new RootPage(),
      settings: settings,
    );
  }

  MyCustomRoute chatRoute(RouteSettings settings, otherName, otherPic, chatId) {
    return new ChatRoute(
      builder: (_) => new ChatPage(
          otherName: otherName, otherPic: otherPic, chatId: chatId),
      settings: settings,
    );
  }

  MyCustomRoute personalSettingsPage(RouteSettings settings) {
    return new ChatRoute(
      builder: (_) => new UserPeronalSettings(),
      settings: settings,
    );
  }

    MyCustomRoute deleteAccountPage(RouteSettings settings) {
    return new ChatRoute(
      builder: (_) => new UserDeleteAccount(),
      settings: settings,
    );
  }

  MyCustomRoute reportIssueRoute(RouteSettings settings) {
    return new ChatRoute(
      builder: (_) => new ReportIssue(),
      settings: settings,
    );
  }

  MyCustomRoute newUserRoute(RouteSettings settings) {
    return new ChatRoute(
      builder: (_) => new NewUserScreen(),
      settings: settings,
    );
  }

  MyCustomRoute additionalSettingsRoute(RouteSettings settings) {
    return new ChatRoute(
      builder: (_) => new AdditionalSettings(),
      settings: settings,
    );
  }

  MyCustomRoute detailedProfileRoute(RouteSettings settings) {
    return new MyCustomRoute(
      builder: (_) => new Scaffold(
          body: ProfilePage(
        isEditable: false,
        autoPlaying: false,
        showPause: true,
      )),
      settings: settings,
    );
  }

  Routes() {
    // Prevent orientation change
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Hide status bar
    //SystemChrome.setEnabledSystemUIOverlays([]);
    runApp(Phoenix(
        child: MaterialApp(
      title: "Dadol",
      localizationsDelegates: [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('it', ''),
      ],
      theme: ThemeData(fontFamily: 'Comfortaa'),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoOverscrollBehavior(),
          child: child,
        );
      },
      debugShowCheckedModeBanner: false,
      home: new RootPage(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/login':
            return loginRoute(settings);
          case '/home':
            return homeRoute(settings);
          case '/camera':
            return cameraRoute(settings);
          case '/new_user':
            return newUserRoute(settings);
          case '/preview_video':
            return previewVideoRoute(settings);
          case '/profile':
            return detailedProfileRoute(settings);
          case '/root':
            return rootRoute(settings);
          case '/additional_settings':
            return additionalSettingsRoute(settings);
          default:
            return rootRoute(settings);
        }
      },
    )));
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //if (settings.isInitialRoute) return child;
    return new FadeTransition(opacity: animation, child: child);
  }
}

class ChatRoute<T> extends MyCustomRoute<T> {
  ChatRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //if (settings.isInitialRoute) return child;
    return new SlideTransition(
      child: child,
      position: new Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
    );
  }
}

class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
