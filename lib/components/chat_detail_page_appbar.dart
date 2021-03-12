import 'package:Chatify/screens/CallScreens/voice_call_screen.dart';
import 'package:Chatify/utils/call_utilites.dart';
import 'package:Chatify/utils/permissions.dart';
import 'package:Chatify/utils/voice_call_utilites.dart';
import 'package:Chatify/widgets/profile_details_widget.dart';
import 'package:Chatify/widgets/StatusIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';


class ChatDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String receiverAvatar;
  final String receiverName;
  final String receiverId;

  final String currUserId;
  final String currUserAvatar;
  final String currUserName;
  // final data;

  ChatDetailPageAppBar({
    Key key,
    @required this.receiverAvatar,
    @required this.receiverName,
    @required this.receiverId,
    @required this.currUserAvatar,
    @required this.currUserName,
    @required this.currUserId,
    // this.data
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 15,
      automaticallyImplyLeading: false,
      // backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          // color: Colors.cyan.shade900,
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  // color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) {
                            return ProfileDetails(
                                id:receiverId, name: receiverName, photo: receiverAvatar,);
                          }));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(receiverAvatar),
                      maxRadius: 20,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          receiverName,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 130,
                            height: 15,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit:BoxFit.contain,
                                child: StatusIndicator(
                                  uid: receiverId,
                                  screen: "chatDetailScreen",
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              // CircleAvatar(
              //   backgroundImage: NetworkImage(receiverAvatar),
              //   maxRadius: 20,
              // ),
              // SizedBox(
              //   width: 12,
              // ),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Text(
              //         receiverName,
              //         style: TextStyle(
              //             color: Colors.white, fontWeight: FontWeight.w600),
              //       ),
              //       SizedBox(
              //         height: 6,
              //       ),
              //       StatusIndicator(
              //         uid: receiverId,
              //         screen: "chatDetailScreen",
              //       )
              //     ],
              //   ),
              // ),
              Spacer(),
              IconButton(
                  icon: Icon(
                    Icons.phone,
                    color: Colors.white,
                    // color: Colors.grey.shade700,
                  ),
                  onPressed: () async {
                    print('voice call pressed');
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? VoiceCallUtils.dial(
                        currUserId: currUserId,
                        currUserName: currUserName,
                        currUserAvatar: currUserAvatar,
                        receiverId: receiverId,
                        receiverAvatar: receiverAvatar,
                        receiverName: receiverName,
                        context: context)
                        : {};
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => VoiceCall(
                    //       ),
                    //     ));


                  }),
              IconButton(
                icon: Icon(
                  Icons.video_call,
                  color: Colors.white,
                  // color: Colors.grey.shade700,
                ),
                onPressed: () async =>
                    await Permissions.cameraAndMicrophonePermissionsGranted()
                        ? CallUtils.dial(
                            currUserId: currUserId,
                            currUserName: currUserName,
                            currUserAvatar: currUserAvatar,
                            receiverId: receiverId,
                            receiverAvatar: receiverAvatar,
                            receiverName: receiverName,
                            context: context)
                        : {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
