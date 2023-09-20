import 'dart:async';
import 'dart:convert';
import 'package:feelingapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as FbAuth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

abstract class AbstractAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String userId;
  User user;

  Future<String> signIn([String username, String password]);

  Future<String> signUp([String username, String password]);

  Future<void> signOut();

  Future<bool> isEmailVerified();

  void logoutCallback();
}

class BaseAuth extends AbstractAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String userId;
  User user;

  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String> signIn([String email, String password]) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user.uid;
  }

  Future<String> signUp([String email, String password]) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<void> logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = "";
    currentUser = null;
    await _firebaseAuth.signOut();
    debugPrint(_firebaseAuth.currentUser.toString());
  }

  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  void loginCallback() {
    getCurrentUser().then((user) {
      userId = user.uid.toString();
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  Future<bool> startUp() async {
    user = await getCurrentUser();

    if (user != null) {
      userId = user.uid.toString();

      authStatus = AuthStatus.LOGGED_IN;
    } else {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    }
    return true;
  }

  AuthStatus getAuthStatus() {
    return authStatus;
  }

  String getUserId() {
    return userId;
  }

  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser;
    return user;
  }
}

class GoogleAuth extends BaseAuth {
  GoogleAuth() {
    if (userId != null) {
      authStatus = AuthStatus.LOGGED_IN;
    } else {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    }
  }

  Future<String> signIn([String email, String password]) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
      'email',
      //'https://www.googleapis.com/auth/user.birthday.read',
      //'https://www.googleapis.com/auth/user.gender.read',
      //'https://www.googleapis.com/auth/userinfo.profile',
      //'https://www.googleapis.com/auth/contacts.readonly'
    ]);

    bool isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) _googleSignIn.disconnect();

    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _firebaseAuth.signInWithCredential(credential);
    user = authResult.user;
    return user.uid;
  }

  Future<String> signUp([String email, String password]) async {
    return signIn();
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<void> logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = "";
    currentUser = null;
    await _firebaseAuth.signOut();
    debugPrint(_firebaseAuth.currentUser.toString());
  }
}

class FacebookAuthenticator extends BaseAuth {
  FacebookAuthenticator() {
    if (userId != null) {
      authStatus = AuthStatus.LOGGED_IN;
    } else {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    }
  }

  Future<String> signIn([String email, String password]) async {
    /*OAuthCredential credential;
    try {
      credential = FacebookAuthProvider.credential(email);
    } catch (e) {
      debugPrint("Impossible to sign user in using Facebook");
      return null;
    }*/
    final LoginResult result = await FacebookAuth.instance.login();
    if(result.status == LoginStatus.success){
    // Create a credential from the access token
    final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken.token);
    // Once signed in, return the UserCredential
    final UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
    user = authResult.user;
    return user.uid;
  }
  return null;
    
  }

  Future<String> signUp([String email, String password]) async {
    return signIn();
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    return _firebaseAuth.signOut();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<void> logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = "";
    currentUser = null;
    await _firebaseAuth.signOut();
    debugPrint(_firebaseAuth.currentUser.toString());
  }
}

class AppleAuth extends BaseAuth {
  AppleAuth() {
    if (userId != null) {
      authStatus = AuthStatus.LOGGED_IN;
    } else {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    }
  }

  Future<String> signIn([String email, String password]) async {
    var scopes = [Scope.fullName, Scope.email];
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        user = authResult.user;
        return user.uid;

      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  Future<String> signUp([String email, String password]) async {
    return signIn();
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<void> logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = "";
    currentUser = null;
    await _firebaseAuth.signOut();
    debugPrint(_firebaseAuth.currentUser.toString());
  }
}

class EmailAuth extends BaseAuth {
  EmailAuth() {
    if (userId != null) {
      authStatus = AuthStatus.LOGGED_IN;
    } else {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    }
  }

  Future<String> signIn([String email, String password]) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user.uid;
  }

  Future<String> signUp([String email, String password]) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  Future<void> logoutCallback() async {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = "";
    currentUser = null;
    await _firebaseAuth.signOut();
    debugPrint(_firebaseAuth.currentUser.toString());
  }
}

class AppleSignInAvailable {
  AppleSignInAvailable(this.isAvailable);
  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    return AppleSignInAvailable(await AppleSignIn.isAvailable());
  }
}
