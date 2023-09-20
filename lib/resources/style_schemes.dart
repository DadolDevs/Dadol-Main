import 'package:flutter/material.dart';

class Style {
  /* Profile and input forms stuff */

  /// Primary fill color for input fields
  get textFromFillColor => Color.fromRGBO(0, 230, 217, 0.1);
  /// Primary fill color for tags chips
  get chipFillColor => Color.fromRGBO(20, 160, 183, 1);
  
  get dazzlePrimaryColor => Color.fromRGBO(0, 230, 217, 1);
  get dazzleSecondaryColor => Color.fromRGBO(20, 160, 183, 1);

  get dazzleLightPrimaryColor => Color.fromRGBO(0, 230, 217, 0.3);
  get dazzleLightSecondaryColor => Color.fromRGBO(20, 160, 183, 0.3);
  /* Nav bar stuff */
  /// primary fill and outline colors for selected bottom navigation items
  get bottomNavSelectedFillColor => Colors.blue.withOpacity(1);
  get bottomNavSelectedOutlineColor => Colors.blue.withOpacity(0.3);

get whiteInputBoxBorder => OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(width: 1, color: Colors.white.withOpacity(0.8)));

get inputBoxBorder => OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(width: 1, color: Colors.black.withOpacity(0.1)));

get inputBoxBorderRegistration => OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(width: 1, color: Colors.white));

get inputBoxErrorBorder => OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(width: 1, color: Colors.red));
get inputBoxFilled => true;
get inputBoxFillColor => Colors.white.withOpacity(0.3);

get inputBoxFillColorRegistration => Colors.white;

get dadolGrey => Color.fromRGBO(96, 96, 96, 1);

  get inputBoxStyle => InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white.withOpacity(0.3),
            );


  /* Overlay information for videos */
  /// Outline size
  static final double shadowOffset = 0.5;
  /// Outline color
  static final outlineColor = Colors.black;
  get textOutlineWithShadows => [
    Shadow(
        // bottomLeft
        offset: Offset(-shadowOffset, -shadowOffset),
        color: outlineColor),
    Shadow(
        // bottomRight
        offset: Offset(shadowOffset, -shadowOffset),
        color: outlineColor),
    Shadow(
        // topRight
        offset: Offset(shadowOffset, shadowOffset),
        color: outlineColor),
    Shadow(
        // topLeft
        offset: Offset(-shadowOffset, shadowOffset),
        color: outlineColor),
  ];
  /// Text style of the username
  get textDecorationUsername => TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 26,
      shadows: textOutlineWithShadows);
  /// Text style of the main hashtag
  get textDecorationMainHashtag => TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      shadows: textOutlineWithShadows);
  /// Text style of the secondary hashtags
  get textDecorationSecondaryHashtags => TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      shadows: textOutlineWithShadows);
  

  get loadingTextPlaceholder => Colors.grey;
}