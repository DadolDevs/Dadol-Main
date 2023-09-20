import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/blocs/playback/playback_bloc.dart';
//import 'package:emoji_picker/emoji_picker.dart';
import 'package:feelingapp/includes/emoji_picker/emoji_picker.dart';
import 'package:feelingapp/includes/video_player.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/carousel/widgets/report_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatPage extends StatefulWidget {
  final otherName;
  final otherPic;
  final otherUid;
  final chatId;
  final created;

  ChatPage({
    Key key,
    this.otherName,
    this.otherUid,
    this.otherPic,
    this.chatId,
    this.created,
  });

  @override
  _ChatPage createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  var textEditingController = TextEditingController();
  Timer userOnlinePollingTimer;
  Future<Map> otherUserProfile;
  bool isUserOnline;
  FocusNode inputFieldFocusNode = FocusNode();
  bool showReport = false;
  bool showEmojis = false;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    otherUserProfile = dbManager.getOtherUserDocument(widget.otherUid);
    super.initState();
    checkOtherUserOnline();
    userOnlinePollingTimer = Timer.periodic(
        Duration(seconds: serverSettings.chatPollingInterval),
        (Timer t) => checkOtherUserOnline());

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool isKeyboardVisible) {
      setState(() {
        this.isKeyboardVisible = isKeyboardVisible;
      });
    });
  }

  @override
  void dispose() {
    userOnlinePollingTimer.cancel();
    super.dispose();
  }

  Future<void> checkOtherUserOnline() async {
    var otherUserData = await dbManager.getOtherUserDocument(widget.otherUid);
    await currentUser.keepUserAliveOnServer();
    var otherOnline = Timestamp(otherUserData['last_online']["_seconds"],
        otherUserData['last_online']["_nanoseconds"]);

    if (otherOnline != null) {
      if (currentUser.lastServerTimestamp
              .toDate()
              .difference(otherOnline.toDate())
              .inSeconds <
          10) {
        setState(() {
          isUserOnline = true;
        });
      } else {
        setState(() {
          isUserOnline = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    currentUser.updateSeenMessages(widget.chatId);

    if (isKeyboardVisible) {
      final viewInsets = EdgeInsets.fromWindowPadding(
          WidgetsBinding.instance.window.viewInsets,
          WidgetsBinding.instance.window.devicePixelRatio);
      debugPrint("Debug!" + viewInsets.bottom.toString());
      debugPrint(
          "Debug!" + MediaQuery.of(context).viewInsets.bottom.toString());
      sharedPrefs.setDouble('keyboardHeight', viewInsets.bottom);
    }

    debugPrint("OtherUser: " + isUserOnline.toString());
    var onlineWidget = Text(
      "",
      style: Theme.of(context).textTheme.subtitle2.apply(
            color: Colors.green,
          ),
    );

    if (isUserOnline == true) {
      onlineWidget = Text(
        AppLocalization.of(context).online,
        style: Theme.of(context).textTheme.subtitle2.apply(
              color: Colors.green,
            ),
      );
    } else {
      onlineWidget = Text(
        AppLocalization.of(context).offline,
        style: Theme.of(context).textTheme.subtitle2.apply(
              color: Colors.grey,
            ),
      );
    }

    return WillPopScope(
        onWillPop: () {
          if (showEmojis) {
            setState(() {
              showEmojis = false;
            });
          } else
            Navigator.pop(context);
          return;
        },
        child: Scaffold(
            body: Stack(children: [
          Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(70),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  shadowColor: Colors.white,
                  flexibleSpace: Column(children:[
                    Spacer(),
                    Row(children: [
                    IconButton(
                      icon: Icon(DadolIcons.x_back_arrow,
                          color: Style().dadolGrey),
                      onPressed: () {
                        Navigator.of(context).pop();
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.otherPic),
                        backgroundColor: Colors.transparent,
                      ),
                      onTap: () {
                        debugPrint("Tapped");
                        showDialog(
                          context: context,
                          builder: (_) => FunkyOverlay(
                              otherUserProfile: otherUserProfile,
                              chatCreationTime: widget.created),
                        );
                      },
                      customBorder: CircleBorder(),
                    ),
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.otherName,
                          style: Theme.of(context).textTheme.subtitle1,
                          overflow: TextOverflow.clip,
                        ),
                        onlineWidget,
                      ],
                    ),
                    Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Style().dadolGrey,
                        size: 40,
                      ),
                      onSelected: (item) async {
                        if (item == AppLocalization.of(context).deleteMatch) {
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(AppLocalization.of(context)
                                      .confirmUnmachTitle),
                                  content: Text(AppLocalization.of(context)
                                      .confirmUnmachBody),
                                  actions: [
                                    FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalization.of(context)
                                            .cancel)),
                                    FlatButton(
                                        onPressed: () async {
                                          currentUser
                                              .blockOtherUser(widget.otherUid);
                                          Navigator.pop(context);
                                        },
                                        child: Text(AppLocalization.of(context)
                                            .continue_))
                                  ],
                                );
                              });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            showReport = true;
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          AppLocalization.of(context).deleteMatch,
                          AppLocalization.of(context).reportIssue
                        ].map((item) {
                          return PopupMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList();
                      },
                    ),
                  ]),
                  SizedBox(height:5),
                  ]),
                )),
            body: buildChatBody(),
          ),
          ReportCard(
            otherUid: widget.otherUid,
            enabled: showReport,
            onSubmittedCallback: onReportSubmitted,
            dark: true,
          ),
        ])));
  }

  List<Widget> buildTopBar() {
    return [
      CircleAvatar(
        radius: 30.0,
        backgroundImage: CachedNetworkImageProvider(widget.otherPic),
        backgroundColor: Colors.transparent,
      ),
      Text(
        widget.otherName,
        style: TextStyle(color: Style().dazzleSecondaryColor, fontSize: 22),
      ),
    ];
  }

  Widget buildChatBody() {
    return Stack(children: [
      Container(
        height: double.maxFinite,
        child: new Column(
          //alignment:new Alignment(x, y)
          children: <Widget>[
            Expanded(
              child: buildMessageBody(),
            ),
            Container(
              child: new Align(
                alignment: FractionalOffset.bottomCenter,
                child: buildInput(),
              ),
            ),
            Offstage(
              child: buildEmojiSelector(),
              offstage: !showEmojis,
            )
          ],
        ),
      ),
    ]);
  }

  void onReportSubmitted(submitted) {
    setState(() {
      showReport = false;
    });
    if (submitted == true) {
      currentUser.blockOtherUser(widget.otherUid);
      Navigator.pop(context);
    }
  }

  Widget buildMessageBody() {
    return GestureDetector(
      // Close emoji screen and keyboard when tapping away
      onTap: () {
        if (showEmojis)
          setState(() {
            showEmojis = false;
          });
        if (isKeyboardVisible) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      },
      child: StreamBuilder(
        stream: currentUser.getChatStream(widget.chatId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("Popping");
            Navigator.pop(context);
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Scrollbar(
                child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              reverse: true,
              itemBuilder: (context, index) {
                var previousMessage;
                if (index < snapshot.data.docs.length - 1)
                  previousMessage = snapshot.data.docs[index + 1];

                return Column(children: [
                  buildDateBubble(
                      previousMessage != null
                          ? previousMessage.data()['timestamp'].toDate()
                          : DateTime(1990),
                      snapshot.data.docs[index].data()['timestamp'] != null
                          ? snapshot.data.docs[index]
                              .data()['timestamp']
                              .toDate()
                          : DateTime.now()),
                  buildMessageBubble(
                      snapshot.data.docs[index].data()['author'],
                      snapshot.data.docs[index].data()['message'],
                      snapshot.data.docs[index].data()['timestamp'],
                      previousMessage)
                ]);
              },
              itemCount: snapshot.data.docs.length,
            ));
          }
        },
      ),
    );
  }

  Widget buildEmojiSelector() {
    return EmojiPicker(
      rows: 5,
      columns: 8,
      numRecommended: 0,
      onEmojiSelected: (emoji, category) {
        debugPrint(textEditingController.selection.toString());
        int offset = textEditingController.selection.baseOffset < 0
            ? 0
            : textEditingController.selection.baseOffset;
        String firstPart = textEditingController.text.substring(0, offset);
        String secondPart = textEditingController.text
            .substring(offset, textEditingController.text.length);

        textEditingController.text = firstPart + emoji.emoji;
        int newOffset = textEditingController.text.length;
        textEditingController.text += secondPart;
        textEditingController.selection =
            TextSelection.collapsed(offset: newOffset);

        setState(() {
          // Need to enable the sending of only emojis
        });
      },
    );
  }

  void onClickedEmojiButton() async {
    if (showEmojis) {
      inputFieldFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    } else if (isKeyboardVisible) {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(Duration(milliseconds: 100));
    }

    setState(() {
      showEmojis = !showEmojis;
    });
  }

  Widget buildInput() {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 5, right: 15, left: 15),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: showEmojis == false
                          ? Icon(
                              DadolIcons.x_smile,
                              color: Color.fromRGBO(96, 96, 96, 1),
                            )
                          : Icon(Icons.keyboard),
                      onPressed: () {
                        onClickedEmojiButton();
                      }),
                  Expanded(
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300.0,
                      ),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (event) {
                          print(event.data.logicalKey.keyId);
                          if (event.runtimeType == RawKeyDownEvent &&
                              (event.logicalKey.keyId == 54)) {
                            sendMessage(textEditingController.text);
                            FocusScope.of(context)
                                .requestFocus(inputFieldFocusNode);
                          }
                        },
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          focusNode: inputFieldFocusNode,
                          controller: textEditingController,
                          textInputAction: TextInputAction.send,
                          onFieldSubmitted: (term) {
                            sendMessage(textEditingController.text);
                            FocusScope.of(context)
                                .requestFocus(inputFieldFocusNode);
                          },
                          onTap: () {
                            if (showEmojis == true)
                              setState(() {
                                showEmojis = false;
                              });
                          },
                          onChanged: (val) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: "",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  textEditingController.text != ""
                      ? IconButton(
                          icon: Container(
                            child: Icon(
                              DadolIcons.x_send,
                              color: Style().dadolGrey,
                            ),
                            padding: EdgeInsets.only(right: 10),
                          ),
                          onPressed: () {
                            sendMessage(textEditingController.text);
                          },
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(message) {
    if (message.length == 0) return;
    setState(() {
      textEditingController.clear();
    });
    currentUser.addNewChatMessage(widget.chatId, message);
  }

  String getFormattedTime(DateTime date) {
    var formattedMinutes = date.minute.toString();
    if (date.minute < 10) formattedMinutes = "0" + date.minute.toString();
    return date.hour.toString() + ":" + formattedMinutes;
  }

  String getFormattedDate(DateTime date) {
    return date.day.toString() +
        "/" +
        date.month.toString() +
        "/" +
        date.year.toString();
  }

  bool isNewDay(DateTime prevDate, DateTime newDate) {
    final dateOld = DateTime(prevDate.year, prevDate.month, prevDate.day);
    final dateNew = DateTime(newDate.year, newDate.month, newDate.day);

    if (dateOld != dateNew) return true;

    return false;
  }

  Widget buildDateBubble(DateTime prevDate, DateTime newDate) {
    Widget dateWidget = Container(
      padding: EdgeInsets.all(5),
      child: Text(
        getFormattedDate(newDate),
        style: TextStyle(color: Colors.white),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(125),
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
    );

    if (isNewDay(prevDate, newDate)) {
      return Row(
        children: [Spacer(), dateWidget, Spacer()],
      );
    }
    return SizedBox();
  }

  Widget buildMessageBubble(author, message, timestamp, previousMessage) {
    bool isMessageSequence = false;

    if (timestamp == null) return Container();

    /*if (previousMessage != null) {
      if (previousMessage.data()['author'] != author) {
        isMessageSequence = true;
      }
    }*/

    if (author == currentUser.uid) {
      return Row(
        children: [
          Spacer(),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMessageSequence ? AppLocalization.of(context).me : "",
                style: Theme.of(context).textTheme.caption,
              ),
              Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * .6),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Style().dazzleLightSecondaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            padding: EdgeInsets.only(right: 15),
                            child: Text(
                              message,
                              style:
                                  Theme.of(context).textTheme.bodyText2.apply(
                                        color: Colors.black87,
                                      ),
                            )),
                        SizedBox(height: 5),
                        Text(
                          getFormattedTime(timestamp.toDate()),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ])),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMessageSequence ? widget.otherName : "",
              style: Theme.of(context).textTheme.caption,
            ),
            Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .6),
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Style().dazzleLightPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 15),
                          child: Text(
                            message,
                            style: Theme.of(context).textTheme.bodyText2.apply(
                                  color: Colors.black87,
                                ),
                          )),
                      SizedBox(height: 5),
                      Text(
                        getFormattedTime(timestamp.toDate()),
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ])),
          ],
        ),
      ],
    );
  }
}

class FunkyOverlay extends StatefulWidget {
  final otherUserProfile;
  final chatCreationTime;
  FunkyOverlay({
    Key key,
    this.otherUserProfile,
    this.chatCreationTime,
  });

  @override
  State<StatefulWidget> createState() => FunkyOverlayState();
}

class FunkyOverlayState extends State<FunkyOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutQuint);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Material(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: FutureBuilder(
              future: widget.otherUserProfile,
              builder: (context, otherUserData) {
                if (otherUserData.connectionState == ConnectionState.waiting)
                  return Container();
                return Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                        //margin: EdgeInsets.all(10),
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: buildMatchedUserProfilePreview(otherUserData.data),
                    )));
              }),
        ),
      ),
    ));
  }

  buildMatchedUserProfilePreview(dynamic otherUserData) {
    final backButton = Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.02,
              left: MediaQuery.of(context).size.height * 0.02),
          child: RawMaterialButton(
            constraints: BoxConstraints.tight(Size(
                (MediaQuery.of(context).size.height * 0.05),
                MediaQuery.of(context).size.height * 0.05)),
            onPressed: () {
              Navigator.pop(context);
            },
            shape: CircleBorder(),
            //fillColor: Colors.black.withOpacity(0.05),
            child: IconShadowWidget(
              Icon(
                DadolIcons.x_back_arrow,
                color: Colors.white,
                size: MediaQuery.of(context).size.height * 0.05,
              ),
              shadowColor: Colors.black,
            ),
          ),
        ));
    return Stack(
      children: [
        BlocProvider(
          create: (BuildContext context) => PlaybackBloc(),
          child: UserVideoPlayer(
            autoPlaying: true,
            parentEvents: null,
            userDetailsPermitted: true,
            overLayInformation: otherUserData,
            isLooping: false,
            showReplay: true,
            index: -1,
            carouselStreamEvents: null,
          ),
        ),
        backButton,
      ],
    );
  }

  String getFormattedDate(DateTime date) {
    return date.day.toString() +
        "/" +
        date.month.toString() +
        "/" +
        date.year.toString();
  }
}
