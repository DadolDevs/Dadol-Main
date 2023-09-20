import 'package:feelingapp/includes/measure_widget.dart';
import 'package:feelingapp/main.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/profile/widgets/tags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:lottie/lottie.dart';

class UserTagSelectorFancy extends StatefulWidget {
  final onExpandedCallback;
  final onTappedCallback;
  final onFilterChanged;
  final enabled;

  UserTagSelectorFancy(
      {Key key,
      this.enabled = true,
      @required this.onExpandedCallback,
      @required this.onTappedCallback,
      @required this.onFilterChanged})
      : super(key: key);
  @override
  _UserTagSelectorFancy createState() => _UserTagSelectorFancy();
}

class _UserTagSelectorFancy extends State<UserTagSelectorFancy>
    with SingleTickerProviderStateMixin {
  List<Tag> additionalTags = [];

  TextEditingController _controller;
  ScrollController _tagListScrollController = ScrollController();

  bool isExpanded = false;
  bool isFullyOpen = false;
  bool isFullyClosed = true;
  bool isAnimating = false;

  int isAttributeOrInterestExpanded = 0;
  bool animateListViewCollapse = false;

  FocusNode inputFieldFocusNode = FocusNode();
  List<Tag> additionalTagsOld = [];
  Size fancyExpandedSectionSize;

  @override
  void initState() {
    _controller = TextEditingController();
    inputFieldFocusNode.addListener(() {
      if (inputFieldFocusNode.hasFocus) {
        setState(() {
          isExpanded = true;
        });
        additionalTagsOld.clear();
        additionalTagsOld.addAll(additionalTags);
      } else {
        setState(() {
          isExpanded = false;
        });
        _controller.clear();

        if (listEquals(additionalTagsOld, additionalTags) == false)
          updateUserSearchFilter();
      }
      //widget.onExpandedCallback(isExpanded);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      buildFancySelector(),
    ]);
  }

  Widget tagChip(String title, {int type: 0}) {
    return Container(
        padding: EdgeInsets.only(top: 5, right: 5, left: 5),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Style().dazzlePrimaryColor, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              shadows: Style().textOutlineWithShadows,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ));
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
        res = TagService.getAttributes(_controller.text, currentUser.genderPreference)
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

  Widget tagSearchBar() {
    List<Tag> prefixTags = [];
    if (additionalTags.length > 0) prefixTags.add(additionalTags[0]);
    if (additionalTags.length > 1) prefixTags.add(additionalTags[1]);
    if (additionalTags.length > 2)
      prefixTags.add(Tag(
          id: "more",
          name: "+" + (additionalTags.length - 2).toString(),
          type: additionalTags[1].type));

    var expandedBorder = OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        borderSide: BorderSide(width: 1, color: Colors.white));

    return Theme(
        data: new ThemeData(
          primaryColor: Color.fromRGBO(178, 178, 178, 1),
          primaryColorDark: Color.fromRGBO(178, 178, 178, 1),
        ),
        child: TextField(
          controller: _controller,
          enabled: widget.enabled,
          enableInteractiveSelection: false,
          style: TextStyle(color: Colors.white, fontFamily: "Comfortaa"),
          decoration: InputDecoration(
              prefixIcon: isExpanded
                  ? SizedBox()
                  : (isFullyClosed
                      ? Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Tags(
                            alignment: WrapAlignment.start,
                            itemCount: prefixTags.length,
                            itemBuilder: (index) {
                              final item = prefixTags[index];
                              return ItemTags(
                                key: Key(index.toString()),
                                index: index,
                                title: index != 2 ? item.name : item.name,
                                pressEnabled: false,
                                activeColor: item.type == TAG_TYPE.ATTRIBUTE
                                    ? Style().dazzlePrimaryColor
                                    : Style().dazzleSecondaryColor,
                              );
                            },
                          ),
                        )
                      : SizedBox()),
              enabledBorder: isExpanded
                  ? expandedBorder
                  : (isFullyClosed
                      ? Style().whiteInputBoxBorder
                      : expandedBorder),
              disabledBorder: Style().whiteInputBoxBorder,
              focusedBorder: isExpanded
                  ? expandedBorder
                  : (isFullyClosed
                      ? Style().whiteInputBoxBorder
                      : expandedBorder),
              filled: true,
              fillColor: isExpanded
                  ? Colors.black.withOpacity(0.5)
                  : (isFullyClosed
                      ? Colors.black.withOpacity(0.1)
                      : Colors.black.withOpacity(0.5))),
          focusNode: inputFieldFocusNode,
          onChanged: (text) {
            setState(() {});
          },
          onTap: () {
            if (!widget.enabled) return;
            setState(() {
              isExpanded = !isExpanded;
            });
            if (isExpanded == false) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              inputFieldFocusNode.unfocus();
            }
            widget.onTappedCallback(isExpanded);
          },
        ));
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
            child:Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalization.of(context).mostPopular,
              style: TextStyle(
                  color: Colors.white,
                  shadows: Style().textOutlineWithShadows)),
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
                  shadows: Style().textOutlineWithShadows)),
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
    if (isAttributeOrInterestExpanded > 0)

      rightHandContent = Flexible(
          flex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalization.of(context).mostPopular,
                  style: TextStyle(
                      color: Colors.white,
                      shadows: Style().textOutlineWithShadows)),
              SizedBox(
                height: 5,
              ),
              Expanded(
                  child: Scrollbar(
                      controller: _tagListScrollController,
                      isAlwaysShown: true,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.47,
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height:10),
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
                                          shadows:
                                              Style().textOutlineWithShadows)),
                                ],
                              ))),
                      SizedBox(height:10),
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
                                          shadows:
                                              Style().textOutlineWithShadows)),
                                ],
                              ))),
                    ],
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
                                          shadows:
                                              Style().textOutlineWithShadows)),
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
                                          shadows:
                                              Style().textOutlineWithShadows)),
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

  Widget buildFancySelector() {
    Widget content = Column(
      children: [
        tagSearchBar(),
        ExpandedSection(
            expand: isExpanded,
            animationCompletedCallback: (misFullyOpen, misFullyClosed) {
              widget.onExpandedCallback(misFullyOpen, misFullyClosed);
              setState(() {
                isFullyOpen = misFullyOpen;
                isFullyClosed = misFullyClosed;
              });
              if (misFullyClosed) {
                setState(() {
                  isAttributeOrInterestExpanded = 0;
                });
              }
            },
            isAnimatingCallback: (misAnimating) {
              setState(() {
                isAnimating = misAnimating;
              });
            },
            child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: new BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: new BorderRadius.only(
                        bottomLeft: const Radius.circular(20.0),
                        bottomRight: const Radius.circular(20.0)),
                        border: Border.all(color: Colors.white)
                        ),
                constraints: new BoxConstraints(
                  minHeight: 5.0,
                  maxHeight: (MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewInsets.bottom) *
                      0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      child: tagsRow(),
                      width: double.infinity,
                    ),
                    SizedBox(height: 10),
                    tagMiddlePage()
                  ],
                ))),
      ],
    );

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: content,
    );
  }

  List<Widget> getAllAttributes() {
    return TagService.getAttributes(_controller.text, currentUser.genderPreference)
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
    return TagService.getInterests(_controller.text)
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

  Widget tagsRow() {
    return Container(
        constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.03),
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.02,
            left: MediaQuery.of(context).size.width * 0.02),
        child: Tags(
          alignment: WrapAlignment.start,
          runSpacing: 5,
          itemCount: additionalTags.length,
          itemBuilder: (index) {
            final item = additionalTags[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  additionalTags.remove(additionalTags[index]);
                });
                //widget.onSubmittedCallback();
                return true;
              },
              child: ItemTags(
                key: Key(index.toString()),
                index: index,
                title: item.name,
                pressEnabled: false,
                activeColor: item.type == TAG_TYPE.ATTRIBUTE
                    ? Style().dazzlePrimaryColor
                    : Style().dazzleSecondaryColor,
              ),
            );
          },
        ));
  }

  void tagChipTappedCallback(name, id, type) {
    if (additionalTags.map((e) => e.id).toList().contains(id))
      additionalTags.remove(Tag(name: name, id: id, type: type));
    else {
      if (additionalTags.length < 4)
        additionalTags.add(Tag(name: name, id: id, type: type));
    }

    setState(() {});
  }

  void updateUserSearchFilter() {
    List<String> tagFilterIds = [];
    for (int i = 0; i < additionalTags.length; i++) {
      tagFilterIds.add(additionalTags[i].id);
    }
    widget.onFilterChanged(tagFilterIds);
  }
}

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  final animationCompletedCallback;
  final isAnimatingCallback;
  ExpandedSection(
      {this.expand = false,
      this.child,
      this.animationCompletedCallback,
      this.isAnimatingCallback});

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    Animation curve = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addListener(() {
        setState(() {});
      });

    expandController.addListener(() {
      if (!expandController.isAnimating) {
        widget.animationCompletedCallback(
            expandController.isCompleted, expandController.isDismissed);
        widget.isAnimatingCallback(false);
      } else {
        widget.isAnimatingCallback(true);
      }
    });
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: SizeTransition(
            axisAlignment: 1.0, sizeFactor: animation, child: widget.child));
  }
}

