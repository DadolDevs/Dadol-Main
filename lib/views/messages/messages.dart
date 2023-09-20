import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:feelingapp/resources/localization.dart';
import 'package:feelingapp/resources/style_schemes.dart';
import 'package:feelingapp/views/messages/chat.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:feelingapp/main.dart';
import 'package:lottie/lottie.dart';

class MessagesPage extends StatefulWidget {
  final bottomBadgeSetter;

  const MessagesPage({Key key, @required this.bottomBadgeSetter});

  @override
  _StateMessagesPage createState() => _StateMessagesPage();
}

class _StateMessagesPage extends State<MessagesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  var chatRoomList;
  TextEditingController _controller = TextEditingController();
    FocusNode inputFieldFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    chatRoomList = currentUser.getActiveChatRooms();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Widget chatSearchbar() {
    return Theme(
        data: new ThemeData(
          primaryColor: Color.fromRGBO(178, 178, 178, 1),
          primaryColorDark: Color.fromRGBO(178, 178, 178, 1),
        ),
        child: Container(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.05,
                left: MediaQuery.of(context).size.width * 0.05),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(30),
              child:TextField(
                focusNode: inputFieldFocusNode,
              controller: _controller,
              style: TextStyle(color: Style().dadolGrey),
              decoration: InputDecoration(
                  prefixIcon: !inputFieldFocusNode.hasFocus ? Container( child: Icon(DadolIcons.x_search, color: Style().dadolGrey,), padding: EdgeInsets.only(left:10),) : SizedBox(),
                  hintText: !inputFieldFocusNode.hasFocus ? AppLocalization.of(context).searchChatPlaceholder : "",
                  hintStyle: TextStyle(fontFamily: "Comfortaa", color: Style().dadolGrey),
                  focusedBorder: Style().whiteInputBoxBorder,
                  enabledBorder: Style().whiteInputBoxBorder,
                  border: Style().whiteInputBoxBorder,
                  filled: true,
                  fillColor: Colors.white),
              onChanged: (text) {
                setState(() {});
              },
            ))));
  }

  @override
  Widget build(BuildContext context) {
    //return Container();

    return Container(
        padding: EdgeInsets.only(top: 35),
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: chatRoomList,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.active &&
                snapshot.data.size > 0) {
              return Column(children: [
                chatSearchbar(),
                Expanded(
                  child:
                  Scrollbar(
                    
                    child: ListView.builder(
                  padding: EdgeInsets.only(
                      top: 10,
                      right: MediaQuery.of(context).size.width * 0.05,
                      left: MediaQuery.of(context).size.width * 0.05,
                      bottom: 50),
                  itemBuilder: (context, index) {
                    var otherUid = snapshot.data.docs[index]
                                ['enabledUsers'][0] !=
                            currentUser.uid
                        ? snapshot.data.docs[index]['enabledUsers'][0]
                        : snapshot.data.docs[index]['enabledUsers'][1];

                    return FutureBuilder(
                        future: dbManager.getOtherUserDocument(otherUid),
                        builder: (context, otherUserData) {
                          if (otherUserData.hasData) {
                            if (_controller.text.length > 0) {
                              if (otherUserData.data['userName'].toLowerCase()
                                  .contains(_controller.text.toLowerCase())) {
                                return buildChatBubble(
                                    otherUserData.data['userName'],
                                    otherUserData.data['uid'],
                                    otherUserData.data['user_video_thumbnail'],
                                    snapshot.data.docs[index]);
                              } else
                                return Container();
                            } else {
                              return buildChatBubble(
                                  otherUserData.data['userName'],
                                  otherUserData.data['uid'],
                                  otherUserData.data['user_video_thumbnail'],
                                  snapshot.data.docs[index]);
                            }
                          } else
                            return Container();
                        });
                  },
                  itemCount: snapshot.data.docs.length,
                ))
              )]);
            } else
              return Container(
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.1,
                    left: MediaQuery.of(context).size.width * 0.1,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Text(
                        AppLocalization.of(context).emptyMatchesPlaceholder2,
                        style: TextStyle(
                          fontSize: 22,
                          color: Color.fromRGBO(96, 96, 96, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.more_horiz,
                        size: 50,
                        color: Color.fromRGBO(96, 96, 96, 1),
                      ),
                      Text(
                        AppLocalization.of(context).golikesomeone,
                        style: TextStyle(
                          fontSize: 22,
                          color: Color.fromRGBO(96, 96, 96, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        AppLocalization.of(context).emptyMatchesPlaceholder1,
                        style: TextStyle(
                          fontSize: 22,
                          color: Color.fromRGBO(96, 96, 96, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                          child: Lottie.asset("assets/lottie/cactus.json",
                              fit: BoxFit.fitWidth)),
                    ],
                  ));
          },
        ));
  }

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final aDate = DateTime(date.year, date.month, date.day);

    var formattedMinutes = date.minute.toString();
    if (date.minute < 10) formattedMinutes = "0" + date.minute.toString();

    if (aDate == today) {
      return date.hour.toString() + ":" + formattedMinutes;
    } else if (aDate == yesterday) {
      return AppLocalization.of(context).yesterday;
    } else {
      return date.day.toString() +
          "/" +
          date.month.toString() +
          "/" +
          date.year.toString();
    }
  }

  String truncateWithEllipsis(String string) {
    return (string.length < 40) ? string : '${string.substring(0, 40)}...';
  }

  Widget buildChatBubble(userName, otherUid, userPic, data) {
    DateTime lastActivity = data['last_updated'].toDate();
    String dateToDisplay = getFormattedDate(lastActivity);

    return Container(
        child: StreamBuilder(
      stream: currentUser.getLastMessageForChat(data.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          String messageToDisplay;
          var userLastOpen = "user1_last_open";
          bool isUnread = false;
          if (data.data()['enabledUsers'][0] == currentUser.uid) {
            userLastOpen = "user0_last_open";
          }

          if (snapshot.data.docs.length > 0) {
            messageToDisplay = truncateWithEllipsis(
                snapshot.data.docs[0].data()['message']);
            if (data.data()[userLastOpen] != null &&
                snapshot.data.docs[0].data()['timestamp'] != null) {
              if (snapshot.data.docs[0]
                      .data()['timestamp']
                      .millisecondsSinceEpoch >
                  data.data()[userLastOpen].millisecondsSinceEpoch) {
                isUnread = true;
              }
            }
          } else {
            messageToDisplay =
                AppLocalization.of(context).chatMessagePlaceholder;
            if (data.data()[userLastOpen] ==
                Timestamp.fromMillisecondsSinceEpoch(0)) isUnread = true;
          }

          return GestureDetector(
              onTap: () => navigateToChat(userName, otherUid, userPic,
                  data.id, data.data()['created']),
              child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        child: CircleAvatar(
                          radius: 35.0,
                          //backgroundImage: NetworkImage(userPic),
                          backgroundImage: CachedNetworkImageProvider(userPic),

                          backgroundColor: Colors.white,
                        ),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUnread
                                ? Style().dazzlePrimaryColor
                                : Colors.transparent),
                      ),
                      SizedBox(width: 20),
                      Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                        color: isUnread
                                            ? Style().dazzlePrimaryColor
                                            : Style().dazzleSecondaryColor,
                                        fontSize: 22),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  child: Text(
                                    dateToDisplay,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            isUnread == true
                                ? Text(
                                    messageToDisplay,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: messageToDisplay != null
                                            ? Style().dazzlePrimaryColor
                                            : Style().dazzlePrimaryColor),
                                  )
                                : Text(
                                    messageToDisplay,
                                  ),
                          ])),
                    ],
                  )));

          /*return ListTile(
              leading: Container(
                child:CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(userPic),),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnread? Style().dazzleSecondaryColor : Colors.transparent
                  ),
                ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(
                      userName,
                      style: TextStyle(
                          color: Style().dazzleSecondaryColor, fontSize: 22),
                    ),
                  ),
                  Container(
                    child: Text(dateToDisplay),
                  ),
                ],
              ),
              //subtitle: Text(messageToDisplay, style: TextStyle(fontWeight: FontWeight.w600,),),
              subtitle: isUnread == true
                  ? Text(
                      messageToDisplay,
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    )
                  : Text(messageToDisplay),
              onTap: () =>
                  navigateToChat(userName, otherUid, userPic, data.documentID));*/
        }
      },
    ));
  }

  navigateToChat(userName, otherUid, userPic, chatId, creationTimestamp) {
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: true,
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (BuildContext context, _, __) {
              return ChatPage(
                otherUid: otherUid,
                otherName: userName,
                otherPic: userPic,
                chatId: chatId,
                created: creationTimestamp,
              );
            },
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return SlideTransition(
                child: child,
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
              );
            }));
  }
}
