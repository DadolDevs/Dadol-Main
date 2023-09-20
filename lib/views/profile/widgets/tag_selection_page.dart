import 'package:feelingapp/includes/measure_widget.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/carousel/widgets/tutorial.dart';
import 'package:feelingapp/views/profile/widgets/tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:lottie/lottie.dart';
import '../../../main.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class UserTagSelectorWidget extends StatefulWidget {
  final onSubmittedCallback;
  final bool registration;
  final bool withTutorial;

  UserTagSelectorWidget(
      {Key key, this.onSubmittedCallback, this.registration = false, this.withTutorial = false})
      : super(key: key);
  @override
  _UserTagSelectorWidget createState() => _UserTagSelectorWidget();
}

class _UserTagSelectorWidget extends State<UserTagSelectorWidget>
    with SingleTickerProviderStateMixin {
  List<Tag> additionalTags = [];
  TextEditingController _controller;
  TagService tagService;
  FocusNode inputFieldFocusNode = FocusNode();
  bool isKeyboardVisible = false;
  int isAttributeOrInterestExpanded = 0;
  bool animateListViewCollapse = false;
  var keyboardLsitener;
  ScrollController _tagListScrollController = ScrollController();
  var fancyExpandedSectionSize;
  bool isTutorialStarted = false;

  GlobalKey _tag_list_button = GlobalObjectKey("widget_tappable");
  GlobalKey _actual_tag_list = GlobalObjectKey("widget_tag_list");

  @override
  void initState() {
    for (int i = 0; i < currentUser.additionalTags.length; i++) {
      var tag = TAG_TYPE.values[currentUser.additionalTags[i]["type"]];
      additionalTags.add(Tag(
          name: tag == TAG_TYPE.INTEREST
              ? currentUser.tagInterests[currentUser.additionalTags[i]["id"]]
                  ["val"]
              : currentUser.tagAttributes[currentUser.additionalTags[i]["id"]]
                  ["val"],
          id: currentUser.additionalTags[i]["id"],
          type: TAG_TYPE.values[currentUser.additionalTags[i]["type"]]));
    }
    _controller = TextEditingController();

    keyboardLsitener =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });

    if (widget.withTutorial && isTutorialStarted == false){
        isTutorialStarted = true;
        //Future.delayed(
           // const Duration(milliseconds: 1000), () => startTutorial());
    }
    super.initState();
  }

  @override
  void dispose() {
    keyboardLsitener.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!showingCoach && !currentUser.tagsCoachShown)
      WidgetsBinding.instance.addPostFrameCallback((_) => showTagTutorial());
    return Container(
        //height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.05,
            left: MediaQuery.of(context).size.width * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          tagSearchBar(),
          SizedBox(height: 10),
          tagMiddlePage(),
          SizedBox(height: 10),
          tagPreviewer(),
        ]));
  }

  void startTutorial() {
    CoachMark coachMarkFAB = CoachMark();

    RenderBox target = _tag_list_button.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _tag_list_button.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            child: TutorialWidget(
              type: "tag_list_button",
              onTapCallback: () {
              },
            ),
          ))
        ],
        duration: null,
        onClose: () {
          setState(() {
            isAttributeOrInterestExpanded = 1;
          });
          //Future.delayed(
            //const Duration(milliseconds: 500), () => showListTutorial());
        });
  }

    void showListTutorial() {
    CoachMark coachMarkFAB = CoachMark();

    RenderBox target = _actual_tag_list.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);

    coachMarkFAB.show(
        targetContext: _actual_tag_list.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            child: TutorialWidget(
              type: "tag_full_list",
              onTapCallback: () {
              },
            ),
          ))
        ],
        duration: null,
        onClose: () {
          setState(() {
            isAttributeOrInterestExpanded = 0;
          });
        });
  }

  bool showingCoach = false;
  GlobalKey _fabKey = GlobalObjectKey("tagIcons");
  void showTagTutorial() {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = _fabKey.currentContext.findRenderObject();

    Rect markRect = Offset(20, target.localToGlobal(Offset.zero).dy) & target.size;
    markRect = Rect.fromCenter(
        center: markRect.center,
        width: markRect.shortestSide * 1.15,
        height: markRect.longestSide * 1);

    showingCoach = true;
    coachMarkFAB.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.top - 20,
              left: markRect.right * 1.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: markRect.width * 0.8,
                    child: Text(AppLocalization.of(context).touchIcons,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        )),
                  ),
                  Image.asset('assets/images/whiteArrow.png', width: markRect.width * 0.4,)
                ],
              )),
        ],
        duration: null,
        onClose: () {
          currentUser.updateTagsCoachShown(true);
          showingCoach = false;
        });
  }

  Widget tagSearchBar() {
    return Theme(
        data: new ThemeData(
          primaryColor: Color.fromRGBO(178, 178, 178, 1),
          primaryColorDark: Color.fromRGBO(178, 178, 178, 1),
        ),
        child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(30),
            child: TextField(
              controller: _controller,
              style:
                  TextStyle(color: Style().dadolGrey, fontFamily: "Comfortaa"),
              decoration: InputDecoration(
                  focusedBorder: Style().whiteInputBoxBorder,
                  enabledBorder: Style().whiteInputBoxBorder,
                  border: Style().whiteInputBoxBorder,
                  hintText: inputFieldFocusNode.hasFocus
                      ? ""
                      : AppLocalization.of(context).searchByTag,
                  hintStyle: TextStyle(color: Style().dadolGrey),
                  filled: true,
                  fillColor: widget.registration ? Colors.white : Colors.white),
              focusNode: inputFieldFocusNode,
              onTap: () {
                setState(() {
                  isAttributeOrInterestExpanded = 0;
                });
              },
              onChanged: (text) {
                setState(() {});
              },
            )));
  }

  Widget tagsRow(TAG_TYPE type) {
    List<Tag> filteredTags =
        additionalTags.where((element) => element.type == type).toList();
    return Container(
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.02,
            left: MediaQuery.of(context).size.width * 0.02),
        child: Tags(
          alignment: WrapAlignment.start,
          runSpacing: 5,
          itemCount: filteredTags.length,
          itemBuilder: (index) {
            final item = filteredTags[index];
            return GestureDetector(
              onTap: () {
                if (additionalTags.length == 1)
                  return true; // Force to keep at least one tag
                setState(() {
                  additionalTags.remove(filteredTags[index]);
                });
                currentUser.updateUserSecondaryTags(additionalTags);
                return true;
              },
              child: ItemTags(
                key: Key(index.toString()),
                index: index,
                title: item.name,
                pressEnabled: false,
                activeColor: type == TAG_TYPE.ATTRIBUTE
                    ? Style().dazzlePrimaryColor
                    : Style().dazzleSecondaryColor,
              ),
            );
          },
        ));
  }

  Widget tagPreviewer() {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(
        child: Text(
          currentUser.additionalTags.length.toString() + "/6",
          style: TextStyle(
              color: Colors.white,
              shadows: widget.registration ? null : null,
              fontSize: 18),
        ),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [tagsRow(TAG_TYPE.ATTRIBUTE), tagsRow(TAG_TYPE.INTEREST)],
          ))
    ]);
  }

  void tagChipTappedCallback(name, id, type) {
    if (additionalTags.map((e) => e.id).toList().contains(id))
      additionalTags.remove(Tag(name: name, id: id, type: type));
    else {
      if (currentUser.additionalTags.length < 6)
        additionalTags.add(Tag(name: name, id: id, type: type));
    }

    setState(() {
      currentUser.additionalTags = additionalTags;
    });

    currentUser.updateUserSecondaryTags(additionalTags);
    widget.onSubmittedCallback();
  }

  List<Widget> getAllAttributes() {
    return TagService.getAttributes("", currentUser.gender)
        .map<Widget>((e) => TagChip(
              title: e.name,
              id: e.id,
              type: TAG_TYPE.ATTRIBUTE,
              enabled:
                  additionalTags.map((e) => e.name).toList().contains(e.name),
              onTapCallback: (name, id, type) {
                tagChipTappedCallback(name, id, type);
              },
            ))
        .toList();
  }

  List<Widget> getAllInterests() {
    return TagService.getInterests("")
        .map<Widget>((e) => TagChip(
              title: e.name,
              id: e.id,
              type: TAG_TYPE.INTEREST,
              enabled:
                  additionalTags.map((e) => e.name).toList().contains(e.name),
              onTapCallback: (name, id, type) {
                tagChipTappedCallback(name, id, type);
              },
            ))
        .toList();
  }

  List<Widget> getTagsPreview({type}) {
    List<Widget> res;
    Widget emptyTagChip = Visibility(
        visible: false,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: TagChip(
          title: "null",
          id: "null",
          type: TAG_TYPE.ATTRIBUTE,
          enabled: false,
          onTapCallback: (title) {},
        ));
    if (type == "attributes") {
      try {
        res = TagService.getInterests(_controller.text)
            .map<Widget>((e) => TagChip(
                  title: e.name,
                  id: e.id,
                  type: TAG_TYPE.INTEREST,
                  enabled: additionalTags
                      .map((e) => e.name)
                      .toList()
                      .contains(e.name),
                  onTapCallback: (name, id, type) {
                    tagChipTappedCallback(name, id, type);
                  },
                ))
            .toList();
      } catch (e) {
        res = [];
      }
    } else if (type == "interests") {
      try {
        res = TagService.getAttributes(_controller.text, currentUser.gender)
            .map<Widget>((e) => TagChip(
                  title: e.name,
                  id: e.id,
                  type: TAG_TYPE.ATTRIBUTE,
                  enabled: additionalTags
                      .map((e) => e.name)
                      .toList()
                      .contains(e.name),
                  onTapCallback: (name, id, type) {
                    tagChipTappedCallback(name, id, type);
                  },
                ))
            .toList();
      } catch (e) {
        res = [];
      }
    } else {
      throw ("Wrong tag type");
    }

    int len = res.length;
    if (len >= 4)
      res = res.getRange(0, 4).toList();
    else {
      for (int i = 0; i < 4 - len; i++) res.add(emptyTagChip);
    }

    res.add(SizedBox(
      height: 5,
    ));

    return res;
  }

  Widget tagMiddlePage() {
    List<Widget> interests = getTagsPreview(type: "interests");
    List<Widget> attributes = getTagsPreview(type: "attributes");

    Widget content;

    Widget rightHandContent = Column(
      children: [
        MeasureSize(
            onChange: (size) {
              setState(() {
                fancyExpandedSectionSize = size;
              });
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalization.of(context).mostPopular,
                  style: TextStyle(
                      color: Colors.white,
                      shadows: widget.registration ? null : null)),
              SizedBox(
                height: 5,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.47,
                  padding: EdgeInsets.only(right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: interests,
                    ),
                  ))
            ])),
        SizedBox(height: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalization.of(context).mostPopular,
              style: TextStyle(
                  color: Colors.white,
                  shadows: widget.registration ? null : null)),
          SizedBox(
            height: 5,
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.47,
              padding: EdgeInsets.only(right: 10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: attributes,
                ),
              ))
        ]),
      ],
    );
    if (isAttributeOrInterestExpanded > 0) {
      _controller.text = "";
      inputFieldFocusNode.unfocus();
      rightHandContent = Flexible(
          flex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalization.of(context).mostPopular,
                  style: TextStyle(
                      color: Colors.white,
                      shadows: widget.registration ? null : null)),
              SizedBox(
                height: 5,
              ),
              Expanded(
                  child: Scrollbar(
                      key:_actual_tag_list,
                      controller: _tagListScrollController,
                      isAlwaysShown: true,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.47,
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                              padding: EdgeInsets.only(top: 0, bottom: 5),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: ListView(
                                  controller: _tagListScrollController,
                                  children: isAttributeOrInterestExpanded == 2
                                      ? getAllInterests()
                                      : getAllAttributes()))))),
            ],
          ));
    }
    if (fancyExpandedSectionSize != null) {
      content = Container(
          height: fancyExpandedSectionSize.height * 2 + 11,
          key: isAttributeOrInterestExpanded > 0
              ? ValueKey<int>(1)
              : ValueKey<int>(2),
          padding: EdgeInsets.only(top: 1),
          child: Row(
            children: [
              Spacer(),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Container(
                    key: _fabKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () {
                              setState(() {
                                isAttributeOrInterestExpanded =
                                    isAttributeOrInterestExpanded == 1 ? 0 : 1;
                                animateListViewCollapse = true;
                              });
                            },
                            child: Opacity(
                                opacity:
                                    isAttributeOrInterestExpanded != 2 ? 1 : 0.1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        key: _tag_list_button,
                                        child: Lottie.asset(
                                            'assets/lottie/smiley.json',
                                            alignment: Alignment.topLeft,
                                            animate:
                                                isAttributeOrInterestExpanded !=
                                                    2,
                                            fit: BoxFit.fill,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3),),
                                    Text(AppLocalization.of(context).attributes,
                                        style: TextStyle(
                                            color: Colors.white,
                                            shadows: widget.registration
                                                ? null
                                                : null)),
                                  ],
                                ))),
                        SizedBox(height: 10),
                        InkWell(
                            onTap: () {
                              setState(() {
                                isAttributeOrInterestExpanded =
                                    isAttributeOrInterestExpanded == 2 ? 0 : 2;
                                animateListViewCollapse = true;
                              });
                            },
                            child: Opacity(
                                opacity:
                                    isAttributeOrInterestExpanded != 1 ? 1 : 0.1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.asset('assets/lottie/rocket.json',
                                        animate:
                                            isAttributeOrInterestExpanded != 1,
                                        fit: BoxFit.fitHeight,
                                        width: MediaQuery.of(context).size.width *
                                            0.3),
                                    Text(AppLocalization.of(context).interests,
                                        style: TextStyle(
                                            color: Colors.white,
                                            shadows: widget.registration
                                                ? null
                                                : null)),
                                    SizedBox(height: 10),
                                  ],
                                ))),
                      ],
                    ),
                  )),
              Spacer(),
              rightHandContent,
              Spacer(),
            ],
          ));
    } else {
      content = Container(
          key: isAttributeOrInterestExpanded > 0
              ? ValueKey<int>(1)
              : ValueKey<int>(2),
          padding: EdgeInsets.only(top: 1),
          child: Row(
            children: [
              Spacer(),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      InkWell(
                          onTap: () {
                            setState(() {
                              isAttributeOrInterestExpanded =
                                  isAttributeOrInterestExpanded == 1 ? 0 : 1;
                              animateListViewCollapse = true;
                            });
                          },
                          child: Opacity(
                              opacity:
                                  isAttributeOrInterestExpanded != 2 ? 1 : 0.1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      key: _tag_list_button,
                                      child: Lottie.asset(
                                          'assets/lottie/smiley.json',
                                          alignment: Alignment.topLeft,
                                          animate:
                                              isAttributeOrInterestExpanded !=
                                                  2,
                                          fit: BoxFit.fill,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3)),
                                  Text(AppLocalization.of(context).attributes,
                                      style: TextStyle(
                                          color: Colors.white,
                                          shadows: widget.registration
                                              ? null
                                              : null)),
                                ],
                              ))),
                      //SizedBox(height: 20),
                      InkWell(
                          onTap: () {
                            setState(() {
                              isAttributeOrInterestExpanded =
                                  isAttributeOrInterestExpanded == 2 ? 0 : 2;
                              animateListViewCollapse = true;
                            });
                          },
                          child: Opacity(
                              opacity:
                                  isAttributeOrInterestExpanded != 1 ? 1 : 0.1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset('assets/lottie/rocket.json',
                                      animate:
                                          isAttributeOrInterestExpanded != 1,
                                      fit: BoxFit.fitHeight,
                                      width: MediaQuery.of(context).size.width *
                                          0.3),
                                  Text(AppLocalization.of(context).interests,
                                      style: TextStyle(
                                          color: Colors.white,
                                          shadows: widget.registration
                                              ? null
                                              : null)),
                                ],
                              ))),
                    ],
                  )),
              Spacer(),
              rightHandContent,
              Spacer(),
            ],
          ));
    }

    if (animateListViewCollapse)
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: content,
      );

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: content,
      //switchOutCurve: Curves.easeOutExpo,
      switchInCurve: Curves.easeInExpo,
      transitionBuilder: (widget, animation) => ScaleTransition(
        scale: animation,
        child: widget,
      ),
    );
  }
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}
