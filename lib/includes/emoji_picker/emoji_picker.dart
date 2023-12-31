library emoji_picker;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../main.dart';
import 'emoji_lists.dart' as emojiList;

import 'package:shared_preferences/shared_preferences.dart';

/// All the possible categories that [Emoji] can be put into
///
/// All [Category] are shown in the keyboard bottombar with the exception of [Category.RECOMMENDED]
/// which only displays when keywords are given
enum Category {
  RECOMMENDED,
  RECENT,
  SMILEYS,
  ANIMALS,
  FOODS,
  TRAVEL,
  ACTIVITIES,
  OBJECTS,
  SYMBOLS,
  FLAGS
}

/// Enum to alter the keyboard button style
enum ButtonMode {
  /// Android button style - gives the button a splash color with ripple effect
  MATERIAL,

  /// iOS button style - gives the button a fade out effect when pressed
  CUPERTINO
}

/// Callback function for when emoji is selected
///
/// The function returns the selected [Emoji] as well as the [Category] from which it originated
typedef void OnEmojiSelected(Emoji emoji, Category category);

/// The Emoji Keyboard widget
///
/// This widget displays a grid of [Emoji] sorted by [Category] which the user can horizontally scroll through.
///
/// There is also a bottombar which displays all the possible [Category] and allow the user to quickly switch to that [Category]
class EmojiPicker extends StatefulWidget {
  @override
  _EmojiPickerState createState() => new _EmojiPickerState();

  /// Number of columns in keyboard grid
  int columns;

  /// Number of rows in keyboard grid
  int rows;

  /// The currently selected [Category]
  ///
  /// This [Category] will have its button in the bottombar darkened
  Category selectedCategory;

  /// The function called when the emoji is selected
  OnEmojiSelected onEmojiSelected;

  /// The background color of the keyboard
  Color bgColor;

  /// The color of the keyboard page indicator
  Color indicatorColor;

  Color progressIndicatorColor;

  Color _defaultBgColor = Color.fromRGBO(242, 242, 242, 1);

  /// A list of keywords that are used to provide the user with recommended emojis in [Category.RECOMMENDED]
  List<String> recommendKeywords;

  /// The maximum number of emojis to be recommended
  int numRecommended;

  /// The string to be displayed if no recommendations found
  String noRecommendationsText;

  /// The text style for the [noRecommendationsText]
  TextStyle noRecommendationsStyle;

  /// The string to be displayed if no recent emojis to display
  String noRecentsText;

  /// The text style for the [noRecentsText]
  TextStyle noRecentsStyle;

  /// Determines the icon to display for each [Category]
  CategoryIcons categoryIcons;

  /// Determines the style given to the keyboard keys
  ButtonMode buttonMode;

  EmojiPicker({
    Key key,
    @required this.onEmojiSelected,
    this.columns = 7,
    this.rows = 3,
    this.selectedCategory,
    this.bgColor,
    this.indicatorColor = Colors.blue,
    this.progressIndicatorColor = Colors.blue,
    this.recommendKeywords,
    this.numRecommended = 10,
    this.noRecommendationsText = "No Recommendations",
    this.noRecommendationsStyle,
    this.noRecentsText = "No Recents",
    this.noRecentsStyle,
    this.categoryIcons,
    this.buttonMode = ButtonMode.MATERIAL,
    //this.unavailableEmojiIcon,
  }) : super(key: key) {
    if (selectedCategory == null) {
      if (recommendKeywords == null) {
        selectedCategory = Category.SMILEYS;
      } else {
        selectedCategory = Category.RECOMMENDED;
      }
    } else if (recommendKeywords == null &&
        selectedCategory == Category.RECOMMENDED) {
      selectedCategory = Category.SMILEYS;
    }

    if (this.noRecommendationsStyle == null) {
      noRecommendationsStyle = TextStyle(fontSize: 20, color: Colors.black26);
    }

    if (this.noRecentsStyle == null) {
      noRecentsStyle = TextStyle(fontSize: 20, color: Colors.black26);
    }

    if (this.bgColor == null) {
      bgColor = _defaultBgColor;
    }

    if (categoryIcons == null) {
      categoryIcons = CategoryIcons();
    }
  }
}

class _Recommended {
  final String name;
  final String emoji;
  final int tier;
  final int numSplitEqualKeyword;
  final int numSplitPartialKeyword;

  _Recommended(
      {this.name,
      this.emoji,
      this.tier,
      this.numSplitEqualKeyword = 0,
      this.numSplitPartialKeyword = 0});
}

/// Class that defines the icon representing a [Category]
class CategoryIcon {
  /// The icon to represent the category
  IconData icon;

  /// The default color of the icon
  Color color;

  /// The color of the icon once the category is selected
  Color selectedColor;

  CategoryIcon({@required this.icon, this.color, this.selectedColor}) {
    if (this.color == null) {
      this.color = Color.fromRGBO(211, 211, 211, 1);
    }
    if (this.selectedColor == null) {
      this.selectedColor = Color.fromRGBO(178, 178, 178, 1);
    }
  }
}

/// Class used to define all the [CategoryIcon] shown for each [Category]
///
/// This allows the keyboard to be personalized by changing icons shown.
/// If a [CategoryIcon] is set as null or not defined during initialization, the default icons will be used instead
class CategoryIcons {
  /// Icon for [Category.RECOMMENDED]
  CategoryIcon recommendationIcon;

  /// Icon for [Category.RECENT]
  CategoryIcon recentIcon;

  /// Icon for [Category.SMILEYS]
  CategoryIcon smileyIcon;

  /// Icon for [Category.ANIMALS]
  CategoryIcon animalIcon;

  /// Icon for [Category.FOODS]
  CategoryIcon foodIcon;

  /// Icon for [Category.TRAVEL]
  CategoryIcon travelIcon;

  /// Icon for [Category.ACTIVITIES]
  CategoryIcon activityIcon;

  /// Icon for [Category.OBJECTS]
  CategoryIcon objectIcon;

  /// Icon for [Category.SYMBOLS]
  CategoryIcon symbolIcon;

  /// Icon for [Category.FLAGS]
  CategoryIcon flagIcon;

  CategoryIcons(
      {this.recommendationIcon,
      this.recentIcon,
      this.smileyIcon,
      this.animalIcon,
      this.foodIcon,
      this.travelIcon,
      this.activityIcon,
      this.objectIcon,
      this.symbolIcon,
      this.flagIcon}) {
    if (recommendationIcon == null) {
      recommendationIcon = CategoryIcon(icon: Icons.search);
    }
    if (recentIcon == null) {
      recentIcon = CategoryIcon(icon: Icons.access_time);
    }
    if (smileyIcon == null) {
      smileyIcon = CategoryIcon(icon: Icons.tag_faces);
    }
    if (animalIcon == null) {
      animalIcon = CategoryIcon(icon: Icons.pets);
    }
    if (foodIcon == null) {
      foodIcon = CategoryIcon(icon: Icons.fastfood);
    }
    if (travelIcon == null) {
      travelIcon = CategoryIcon(icon: Icons.location_city);
    }
    if (activityIcon == null) {
      activityIcon = CategoryIcon(icon: Icons.directions_run);
    }
    if (objectIcon == null) {
      objectIcon = CategoryIcon(icon: Icons.lightbulb_outline);
    }
    if (symbolIcon == null) {
      symbolIcon = CategoryIcon(icon: Icons.euro_symbol);
    }
    if (flagIcon == null) {
      flagIcon = CategoryIcon(icon: Icons.flag);
    }
  }
}

/// A class to store data for each individual emoji
class Emoji {
  /// The name or description for this emoji
  final String name;

  /// The unicode string for this emoji
  ///
  /// This is the string that should be displayed to view the emoji
  final String emoji;

  Emoji({@required this.name, @required this.emoji});

  @override
  String toString() {
    return "Name: " + name + ", Emoji: " + emoji;
  }
}

class _EmojiPickerState extends State<EmojiPicker> {
  static const platform = const MethodChannel("emoji_picker");

  List<Widget> pages = new List();
  int recommendedPagesNum;
  int recentPagesNum;
  int smileyPagesNum;
  int animalPagesNum;
  int foodPagesNum;
  int travelPagesNum;
  int activityPagesNum;
  int objectPagesNum;
  int symbolPagesNum;
  int flagPagesNum;
  List<String> allNames = new List();
  List<String> allEmojis = new List();
  List<String> recentEmojis = new List();

  Map<String, String> smileyMap = new Map();
  Map<String, String> animalMap = new Map();
  Map<String, String> foodMap = new Map();
  Map<String, String> travelMap = new Map();
  Map<String, String> activityMap = new Map();
  Map<String, String> objectMap = new Map();
  Map<String, String> symbolMap = new Map();
  Map<String, String> flagMap = new Map();

  bool loaded = false;

  int currentPage = 0;
  @override
  void initState() {
    super.initState();

    updateEmojis().then((_) {
      loaded = true;
    });
  }

  Future<bool> _isEmojiAvailable(String emoji) async {
    if (Platform.isAndroid) {
      bool isAvailable;
      try {
        isAvailable =
            await platform.invokeMethod("isAvailable", {"emoji": emoji});
      } on PlatformException catch (_) {
        isAvailable = false;
      }
      return isAvailable;
    } else {
      return true;
    }
  }

  Future<Map<String, String>> _getFiltered(Map<String, String> emoji) async {
    return emoji;
  }

  Future<List<String>> getRecentEmojis() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = "recents";
    recentEmojis = prefs.getStringList(key) ?? new List();
    return recentEmojis;
  }

  void addRecentEmoji(Emoji emoji) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "recents";
    getRecentEmojis().then((_) {
      print("adding emoji");
      setState(() {
        recentEmojis.insert(0, emoji.name);
        prefs.setStringList(key, recentEmojis);
      });
    });
  }

  Future<Map<String, String>> getAvailableEmojis(Map<String, String> map,
      {@required String title}) async {
    Map<String, String> newMap;

    newMap = await restoreFilteredEmojis(title);

    if (newMap != null) {
      return newMap;
    }

    newMap = await _getFiltered(map);

    await cacheFilteredEmojis(title, newMap);

    return newMap;
  }

  Future<void> cacheFilteredEmojis(
      String title, Map<String, String> emojis) async {
    final prefs = await SharedPreferences.getInstance();
    String emojiJson = jsonEncode(emojis);
    prefs.setString(title, emojiJson);
    return;
  }

  Future<Map<String, String>> restoreFilteredEmojis(String title) async {
    final prefs = await SharedPreferences.getInstance();
    String emojiJson = prefs.getString(title);
    if (emojiJson == null) {
      return null;
    }
    Map<String, String> emojis =
        Map<String, String>.from(jsonDecode(emojiJson));
    return emojis;
  }

  Future updateEmojis() async {
    smileyMap = await getAvailableEmojis(emojiList.smileys, title: 'smileys');
    animalMap = await getAvailableEmojis(emojiList.animals, title: 'animals');
    foodMap = await getAvailableEmojis(emojiList.foods, title: 'foods');
    travelMap = await getAvailableEmojis(emojiList.travel, title: 'travel');
    activityMap =
        await getAvailableEmojis(emojiList.activities, title: 'activities');
    objectMap = await getAvailableEmojis(emojiList.objects, title: 'objects');
    symbolMap = await getAvailableEmojis(emojiList.symbols, title: 'symbols');
    flagMap = await getAvailableEmojis(emojiList.flags, title: 'flags');

    allNames.addAll(smileyMap.keys);
    allNames.addAll(animalMap.keys);
    allNames.addAll(foodMap.keys);
    allNames.addAll(travelMap.keys);
    allNames.addAll(activityMap.keys);
    allNames.addAll(objectMap.keys);
    allNames.addAll(symbolMap.keys);
    allNames.addAll(flagMap.keys);

    allEmojis.addAll(smileyMap.values);
    allEmojis.addAll(animalMap.values);
    allEmojis.addAll(foodMap.values);
    allEmojis.addAll(travelMap.values);
    allEmojis.addAll(activityMap.values);
    allEmojis.addAll(objectMap.values);
    allEmojis.addAll(symbolMap.values);
    allEmojis.addAll(flagMap.values);

    recommendedPagesNum = 0;
    List<_Recommended> recommendedEmojis = new List();
    List<Widget> recommendedPages = new List();

    if (widget.recommendKeywords != null) {
      allNames.forEach((name) {
        int numSplitEqualKeyword = 0;
        int numSplitPartialKeyword = 0;

        widget.recommendKeywords.forEach((keyword) {
          if (name.toLowerCase() == keyword.toLowerCase()) {
            recommendedEmojis.add(_Recommended(
                name: name, emoji: allEmojis[allNames.indexOf(name)], tier: 1));
          } else {
            List<String> splitName = name.split(" ");

            splitName.forEach((splitName) {
              if (splitName.replaceAll(":", "").toLowerCase() ==
                  keyword.toLowerCase()) {
                numSplitEqualKeyword += 1;
              } else if (splitName
                  .replaceAll(":", "")
                  .toLowerCase()
                  .contains(keyword.toLowerCase())) {
                numSplitPartialKeyword += 1;
              }
            });
          }
        });

        if (numSplitEqualKeyword > 0) {
          if (numSplitEqualKeyword == name.split(" ").length) {
            recommendedEmojis.add(_Recommended(
                name: name, emoji: allEmojis[allNames.indexOf(name)], tier: 1));
          } else {
            recommendedEmojis.add(_Recommended(
                name: name,
                emoji: allEmojis[allNames.indexOf(name)],
                tier: 2,
                numSplitEqualKeyword: numSplitEqualKeyword,
                numSplitPartialKeyword: numSplitPartialKeyword));
          }
        } else if (numSplitPartialKeyword > 0) {
          recommendedEmojis.add(_Recommended(
              name: name,
              emoji: allEmojis[allNames.indexOf(name)],
              tier: 3,
              numSplitPartialKeyword: numSplitPartialKeyword));
        }
      });

      recommendedEmojis.sort((a, b) {
        if (a.tier < b.tier) {
          return -1;
        } else if (a.tier > b.tier) {
          return 1;
        } else {
          if (a.tier == 1) {
            if (a.name.split(" ").length > b.name.split(" ").length) {
              return -1;
            } else if (a.name.split(" ").length < b.name.split(" ").length) {
              return 1;
            } else {
              return 0;
            }
          } else if (a.tier == 2) {
            if (a.numSplitEqualKeyword > b.numSplitEqualKeyword) {
              return -1;
            } else if (a.numSplitEqualKeyword < b.numSplitEqualKeyword) {
              return 1;
            } else {
              if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
                return -1;
              } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
                return 1;
              } else {
                if (a.name.split(" ").length < b.name.split(" ").length) {
                  return -1;
                } else if (a.name.split(" ").length >
                    b.name.split(" ").length) {
                  return 1;
                } else {
                  return 0;
                }
              }
            }
          } else if (a.tier == 3) {
            if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
              return -1;
            } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
              return 1;
            } else {
              return 0;
            }
          }
        }

        return 0;
      });

      if (recommendedEmojis.length > widget.numRecommended) {
        recommendedEmojis =
            recommendedEmojis.getRange(0, widget.numRecommended).toList();
      }

      if (recommendedEmojis.length != 0) {
        recommendedPagesNum =
            (recommendedEmojis.length / (widget.rows * widget.columns)).ceil();

        for (var i = 0; i < recommendedPagesNum; i++) {
          recommendedPages.add(Container(
            color: widget.bgColor,
            child: GridView.count(
              shrinkWrap: true,
              primary: true,
              crossAxisCount: widget.columns,
              children: List.generate(widget.rows * widget.columns, (index) {
                if (index + (widget.columns * widget.rows * i) <
                    recommendedEmojis.length) {
                  switch (widget.buttonMode) {
                    case ButtonMode.MATERIAL:
                      return Center(
                          child: FlatButton(
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            recommendedEmojis[
                                    index + (widget.columns * widget.rows * i)]
                                .emoji,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        onPressed: () {
                          _Recommended recommended = recommendedEmojis[
                              index + (widget.columns * widget.rows * i)];
                          widget.onEmojiSelected(
                              Emoji(
                                  name: recommended.name,
                                  emoji: recommended.emoji),
                              widget.selectedCategory);
                          addRecentEmoji(Emoji(
                              name: recommended.name,
                              emoji: recommended.emoji));
                        },
                      ));
                      break;
                    case ButtonMode.CUPERTINO:
                      return Center(
                          child: CupertinoButton(
                        pressedOpacity: 0.4,
                        padding: EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            recommendedEmojis[
                                    index + (widget.columns * widget.rows * i)]
                                .emoji,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        onPressed: () {
                          _Recommended recommended = recommendedEmojis[
                              index + (widget.columns * widget.rows * i)];
                          widget.onEmojiSelected(
                              Emoji(
                                  name: recommended.name,
                                  emoji: recommended.emoji),
                              widget.selectedCategory);
                          addRecentEmoji(Emoji(
                              name: recommended.name,
                              emoji: recommended.emoji));
                        },
                      ));

                      break;
                    default:
                      return Container();
                      break;
                  }
                } else {
                  return Container();
                }
              }),
            ),
          ));
        }
      } else {
        recommendedPagesNum = 1;

        recommendedPages.add(Container(
            color: widget.bgColor,
            child: Center(
                child: Text(
              widget.noRecommendationsText,
              style: widget.noRecommendationsStyle,
            ))));
      }
    }

    List<Widget> recentPages = new List();
    recentPagesNum = 0;
    recentPages.add(recentPage());

    smileyPagesNum = 1;/*
        (smileyMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> smileyPages = new List();

    for (var i = 0; i < smileyPagesNum; i++) {
      smileyPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(smileyMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                smileyMap.values.toList().length) {
              String emojiTxt = smileyMap.values
                  .toList()[index + (widget.columns * widget.rows * i)];

              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        emojiTxt,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: smileyMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: smileyMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        emojiTxt,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: smileyMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: smileyMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    animalPagesNum = 1; /*
        (animalMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> animalPages = new List();

    for (var i = 0; i < animalPagesNum; i++) {
      animalPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(animalMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                animalMap.values.toList().length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        animalMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: animalMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: animalMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        animalMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: animalMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: animalMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    foodPagesNum = 1; /*
        (foodMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> foodPages = new List();

    for (var i = 0; i < foodPagesNum; i++) {
      foodPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(foodMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                foodMap.values.toList().length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        foodMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: foodMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: foodMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        foodMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: foodMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: foodMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    travelPagesNum = 1; /*
        (travelMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> travelPages = new List();

    for (var i = 0; i < travelPagesNum; i++) {
      travelPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(travelMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                travelMap.values.toList().length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        travelMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: travelMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: travelMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        travelMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: travelMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: travelMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    activityPagesNum = 1; /*
        (activityMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> activityPages = new List();

    for (var i = 0; i < activityPagesNum; i++) {
      activityPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(activityMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                activityMap.values.toList().length) {
              String emojiTxt = activityMap.values
                  .toList()[index + (widget.columns * widget.rows * i)];

              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        activityMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: activityMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: activityMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        emojiTxt,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: activityMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: activityMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    objectPagesNum = 1; /*
        (objectMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> objectPages = new List();

    for (var i = 0; i < objectPagesNum; i++) {
      objectPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(objectMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                objectMap.values.toList().length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        objectMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: objectMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: objectMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        objectMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: objectMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: objectMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    symbolPagesNum = 1; /*
        (symbolMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> symbolPages = new List();

    for (var i = 0; i < symbolPagesNum; i++) {
      symbolPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(symbolMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                symbolMap.values.toList().length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        symbolMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: symbolMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: symbolMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        symbolMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: symbolMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: symbolMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }

    flagPagesNum = 1;/*
        (flagMap.values.toList().length / (widget.rows * widget.columns))
            .ceil();*/

    List<Widget> flagPages = new List();

    for (var i = 0; i < flagPagesNum; i++) {
      flagPages.add(Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns,
          children: List.generate(flagMap.values.toList().length, (index) {
            if (index + (widget.columns * widget.rows * i) <
                flagMap.values.toList().length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        flagMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: flagMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: flagMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        flagMap.values.toList()[
                            index + (widget.columns * widget.rows * i)],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      widget.onEmojiSelected(
                          Emoji(
                              name: flagMap.keys.toList()[
                                  index + (widget.columns * widget.rows * i)],
                              emoji: flagMap.values.toList()[
                                  index + (widget.columns * widget.rows * i)]),
                          widget.selectedCategory);
                    },
                  ));
                  break;
                default:
                  return Container();
                  break;
              }
            } else {
              return Container();
            }
          }),
        ),
      ));
    }


    pages.addAll(smileyPages);
    pages.addAll(animalPages);
    pages.addAll(foodPages);
    pages.addAll(travelPages);
    pages.addAll(activityPages);
    pages.addAll(objectPages);
    pages.addAll(symbolPages);
    pages.addAll(flagPages);


  }

  Widget recentPage() {
    if (recentEmojis.length != 0) {
      return Container(
          color: widget.bgColor,
          child: GridView.count(
            shrinkWrap: true,
            primary: true,
            crossAxisCount: widget.columns,
            children: List.generate(widget.rows * widget.columns, (index) {
              if (index < recentEmojis.length) {
                switch (widget.buttonMode) {
                  case ButtonMode.MATERIAL:
                    return Center(
                        child: FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          allEmojis[allNames.indexOf(recentEmojis[index])],
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        String emojiName = recentEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: emojiName,
                                emoji: allEmojis[allNames.indexOf(emojiName)]),
                            widget.selectedCategory);
                      },
                    ));
                    break;
                  case ButtonMode.CUPERTINO:
                    return Center(
                        child: CupertinoButton(
                      pressedOpacity: 0.4,
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          allEmojis[allNames.indexOf(recentEmojis[index])],
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        String emojiName = recentEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: emojiName,
                                emoji: allEmojis[allNames.indexOf(emojiName)]),
                            widget.selectedCategory);
                      },
                    ));

                    break;
                  default:
                    return Container();
                    break;
                }
              } else {
                return Container();
              }
            }),
          ));
    } else {
      return Container(
          color: widget.bgColor,
          child: Center(
              child: Text(
            widget.noRecentsText,
            style: widget.noRecentsStyle,
          )));
    }
  }

  Widget defaultButton(CategoryIcon categoryIcon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width /
          (widget.recommendKeywords == null ? 8 : 9),
      height: MediaQuery.of(context).size.width /
          (widget.recommendKeywords == null ? 8 : 9),
      child: Container(
        color: widget.bgColor,
        child: Center(
          child: Icon(
            categoryIcon.icon,
            size: 22,
            color: categoryIcon.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {

      PageController pageController;
      if (currentPage == 0) {
        pageController =
            PageController(initialPage: recentPagesNum + recommendedPagesNum);
      } else if (currentPage == 1) {
        pageController = PageController(
            initialPage: smileyPagesNum + recentPagesNum + recommendedPagesNum);
      } else if (currentPage == 2) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (currentPage == 3) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (currentPage == 4) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (currentPage == 5) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                activityPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (currentPage == 6) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                activityPagesNum +
                objectPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      } else if (currentPage == 7) {
        pageController = PageController(
            initialPage: smileyPagesNum +
                animalPagesNum +
                foodPagesNum +
                travelPagesNum +
                activityPagesNum +
                objectPagesNum +
                symbolPagesNum +
                recentPagesNum +
                recommendedPagesNum);
      }

      pageController.addListener(() {
        setState(() {currentPage = pageController.page.toInt();});
      });

      double emojiWindowHeight = sharedPrefs.get("keyboardHeight");

      if (emojiWindowHeight != null) {
        emojiWindowHeight = emojiWindowHeight - 56;
      }
      else {
        emojiWindowHeight = (MediaQuery.of(context).size.width / widget.columns) *
                widget.rows;
      }
      return Column(
        children: <Widget>[
          SizedBox(
            height: emojiWindowHeight,
            width: MediaQuery.of(context).size.width,
            child: PageView(
                //scrollDirection: Axis.vertical,
                children: pages,
                controller: pageController,
                onPageChanged: (index) {
                  if (widget.recommendKeywords != null &&
                      index < recommendedPagesNum) {
                    widget.selectedCategory = Category.RECOMMENDED;
                  } else if (index < recentPagesNum + recommendedPagesNum) {
                    widget.selectedCategory = Category.RECENT;
                  } else if (index <
                      recentPagesNum + smileyPagesNum + recommendedPagesNum) {
                    widget.selectedCategory = Category.SMILEYS;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.ANIMALS;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.FOODS;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.TRAVEL;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          activityPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.ACTIVITIES;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          activityPagesNum +
                          objectPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.OBJECTS;
                  } else if (index <
                      recentPagesNum +
                          smileyPagesNum +
                          animalPagesNum +
                          foodPagesNum +
                          travelPagesNum +
                          activityPagesNum +
                          objectPagesNum +
                          symbolPagesNum +
                          recommendedPagesNum) {
                    widget.selectedCategory = Category.SYMBOLS;
                  } else {
                    widget.selectedCategory = Category.FLAGS;
                  }
                }),
          ),
          Container(
              color: widget.bgColor,
              height: 6,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 4, bottom: 0, right: 2, left: 2),
              child: CustomPaint(
                painter: _ProgressPainter(
                    context,
                    pageController,
                    new Map.fromIterables([
                      Category.RECOMMENDED,
                      Category.RECENT,
                      Category.SMILEYS,
                      Category.ANIMALS,
                      Category.FOODS,
                      Category.TRAVEL,
                      Category.ACTIVITIES,
                      Category.OBJECTS,
                      Category.SYMBOLS,
                      Category.FLAGS
                    ], [
                      1,
                      1,
                      1,
                      1,
                      1,
                      1,
                      1,
                      1,
                      1,
                      1
                    ]),
                    widget.selectedCategory,
                    widget.indicatorColor),
              )),
          Container(
              height: 50,
              color: widget.bgColor,
              child: Row(
                children: <Widget>[
                  widget.recommendKeywords != null
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width / 10,
                          height: MediaQuery.of(context).size.width / 10,
                          child: widget.buttonMode == ButtonMode.MATERIAL
                              ? FlatButton(
                                  padding: EdgeInsets.all(0),
                                  color: widget.selectedCategory ==
                                          Category.RECOMMENDED
                                      ? Colors.black12
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0))),
                                  child: Center(
                                    child: Icon(
                                      widget.categoryIcons.recommendationIcon
                                          .icon,
                                      size: 22,
                                      color: widget.selectedCategory ==
                                              Category.RECOMMENDED
                                          ? widget.categoryIcons
                                              .recommendationIcon.selectedColor
                                          : widget.categoryIcons
                                              .recommendationIcon.color,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (widget.selectedCategory ==
                                        Category.RECOMMENDED) {
                                      return;
                                    }

                                    pageController.jumpToPage(0);
                                  },
                                )
                              : CupertinoButton(
                                  pressedOpacity: 0.4,
                                  padding: EdgeInsets.all(0),
                                  color: widget.selectedCategory ==
                                          Category.RECOMMENDED
                                      ? Colors.black12
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0)),
                                  child: Center(
                                    child: Icon(
                                      widget.categoryIcons.recommendationIcon
                                          .icon,
                                      size: 22,
                                      color: widget.selectedCategory ==
                                              Category.RECOMMENDED
                                          ? widget.categoryIcons
                                              .recommendationIcon.selectedColor
                                          : widget.categoryIcons
                                              .recommendationIcon.color,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (widget.selectedCategory ==
                                        Category.RECOMMENDED) {
                                      return;
                                    }

                                    pageController.jumpToPage(0);
                                  },
                                ),
                        )
                      : Container(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 0
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.smileyIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 0
                                        ? widget.categoryIcons.smileyIcon
                                            .selectedColor
                                        : widget.categoryIcons.smileyIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 0) {
                                return;
                              }

                              pageController.jumpToPage(
                                  0 + recentPagesNum + recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 0
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.smileyIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 0
                                        ? widget.categoryIcons.smileyIcon
                                            .selectedColor
                                        : widget.categoryIcons.smileyIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 0) {
                                return;
                              }

                              pageController.jumpToPage(
                                  0 + recentPagesNum + recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 1
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.animalIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 1
                                        ? widget.categoryIcons.animalIcon
                                            .selectedColor
                                        : widget.categoryIcons.animalIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 1) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 1
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.animalIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 1
                                        ? widget.categoryIcons.animalIcon
                                            .selectedColor
                                        : widget.categoryIcons.animalIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 1) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 2
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.foodIcon.icon,
                                size: 22,
                                color: currentPage == 2
                                    ? widget
                                        .categoryIcons.foodIcon.selectedColor
                                    : widget.categoryIcons.foodIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 2) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 2
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.foodIcon.icon,
                                size: 22,
                                color: currentPage == 2
                                    ? widget
                                        .categoryIcons.foodIcon.selectedColor
                                    : widget.categoryIcons.foodIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 2) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 3
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.travelIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 3
                                        ? widget.categoryIcons.travelIcon
                                            .selectedColor
                                        : widget.categoryIcons.travelIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 3) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 3
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.travelIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 3
                                        ? widget.categoryIcons.travelIcon
                                            .selectedColor
                                        : widget.categoryIcons.travelIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 3) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color:
                                currentPage == 4
                                    ? Colors.black12
                                    : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.activityIcon.icon,
                                size: 22,
                                color: currentPage == 4 ? widget.categoryIcons.activityIcon
                                        .selectedColor
                                    : widget.categoryIcons.activityIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 4) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color:
                                currentPage == 4
                                    ? Colors.black12
                                    : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.activityIcon.icon,
                                size: 22,
                                color: currentPage == 4
                                    ? widget.categoryIcons.activityIcon
                                        .selectedColor
                                    : widget.categoryIcons.activityIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 4) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 5
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.objectIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 5
                                        ? widget.categoryIcons.objectIcon
                                            .selectedColor
                                        : widget.categoryIcons.objectIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 5) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 5
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.objectIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 5
                                        ? widget.categoryIcons.objectIcon
                                            .selectedColor
                                        : widget.categoryIcons.objectIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 5) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 6
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.symbolIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 6
                                        ? widget.categoryIcons.symbolIcon
                                            .selectedColor
                                        : widget.categoryIcons.symbolIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 6) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 6
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.symbolIcon.icon,
                                size: 22,
                                color:
                                    currentPage == 6
                                        ? widget.categoryIcons.symbolIcon
                                            .selectedColor
                                        : widget.categoryIcons.symbolIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 6) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    height: MediaQuery.of(context).size.width /
                        (widget.recommendKeywords == null ? 8 : 9),
                    child: widget.buttonMode == ButtonMode.MATERIAL
                        ? FlatButton(
                            padding: EdgeInsets.all(0),
                            color: currentPage == 7
                                ? Colors.black12
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.flagIcon.icon,
                                size: 22,
                                color: currentPage == 7
                                    ? widget
                                        .categoryIcons.flagIcon.selectedColor
                                    : widget.categoryIcons.flagIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 7) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  symbolPagesNum +
                                  recommendedPagesNum);
                            },
                          )
                        : CupertinoButton(
                            pressedOpacity: 0.4,
                            padding: EdgeInsets.all(0),
                            color: currentPage == 7
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            child: Center(
                              child: Icon(
                                widget.categoryIcons.flagIcon.icon,
                                size: 22,
                                color: currentPage == 7
                                    ? widget
                                        .categoryIcons.flagIcon.selectedColor
                                    : widget.categoryIcons.flagIcon.color,
                              ),
                            ),
                            onPressed: () {
                              if (currentPage == 7) {
                                return;
                              }

                              pageController.jumpToPage(recentPagesNum +
                                  smileyPagesNum +
                                  animalPagesNum +
                                  foodPagesNum +
                                  activityPagesNum +
                                  travelPagesNum +
                                  objectPagesNum +
                                  symbolPagesNum +
                                  recommendedPagesNum);
                            },
                          ),
                  ),
                ],
              ))
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          SizedBox(
            height: (MediaQuery.of(context).size.width / widget.columns) *
                widget.rows,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: widget.bgColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.progressIndicatorColor),
                ),
              ),
            ),
          ),
          Container(
            height: 6,
            width: MediaQuery.of(context).size.width,
            color: widget.bgColor,
            padding: EdgeInsets.only(top: 4, left: 2, right: 2),
            child: Container(
              color: widget.indicatorColor,
            ),
          ),
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                widget.recommendKeywords != null
                    ? defaultButton(widget.categoryIcons.recommendationIcon)
                    : Container(),
                defaultButton(widget.categoryIcons.recentIcon),
                defaultButton(widget.categoryIcons.smileyIcon),
                defaultButton(widget.categoryIcons.animalIcon),
                defaultButton(widget.categoryIcons.foodIcon),
                defaultButton(widget.categoryIcons.travelIcon),
                defaultButton(widget.categoryIcons.activityIcon),
                defaultButton(widget.categoryIcons.objectIcon),
                defaultButton(widget.categoryIcons.symbolIcon),
                defaultButton(widget.categoryIcons.flagIcon),
              ],
            ),
          )
        ],
      );
    }
  }
}

class _ProgressPainter extends CustomPainter {
  final BuildContext context;
  final PageController pageController;
  final Map<Category, int> pages;
  final Category selectedCategory;
  final Color indicatorColor;

  _ProgressPainter(this.context, this.pageController, this.pages,
      this.selectedCategory, this.indicatorColor);

  @override
  void paint(Canvas canvas, Size size) {
    double offsetInPages = pageController.page;

    double indicatorPageWidth = size.width / (pages.length -2);

    Rect bgRect = Offset(0, 0) & size;

    Rect indicator = Offset(max(0, offsetInPages * indicatorPageWidth), 0) &
        Size(
            indicatorPageWidth -
                max(
                    0,
                    (indicatorPageWidth +
                            (offsetInPages * indicatorPageWidth)) -
                        size.width) +
                min(0, offsetInPages * indicatorPageWidth),
            size.height);

    canvas.drawRect(bgRect, Paint()..color = Colors.black12);
    canvas.drawRect(indicator, Paint()..color = indicatorColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}