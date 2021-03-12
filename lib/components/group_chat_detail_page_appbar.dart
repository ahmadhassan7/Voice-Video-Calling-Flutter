import 'package:Chatify/screens/Chats/add_participants.dart';
import 'package:Chatify/widgets/group_profile_details_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupChatDetailPageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String receiverAvatar;
  final String receiverName;
  final String receiverId;
  final List<String> users;

  final String currUserId;
  final String currUserAvatar;
  final String currUserName;

  // final data;

  GroupChatDetailPageAppBar({
    Key key,
    @required this.receiverAvatar,
    @required this.receiverName,
    @required this.users,
    @required this.receiverId,
    @required this.currUserAvatar,
    @required this.currUserName,
    @required this.currUserId,
    // @required this.data,
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
                  color: Theme.of(context).textTheme.bodyText1.color,
                  // color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return GroupProfileDetails(
                      id: receiverId,
                      name: receiverName,
                      photo: receiverAvatar,
                    );
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
                              // color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddParticipantsPage(
                          edit: true,
                          users: users,
                          groupId: receiverId,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.group_add,
                    color: Theme.of(context).textTheme.bodyText1.color,
                  )),
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
