import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Chatify/configs/configs.dart';
import 'package:Chatify/models/group.dart';
import 'package:Chatify/screens/Chats/add_participants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewGroupWithParticipants extends StatelessWidget {
  final List participants;
  final bool edit;
  final Groups group;
  String title ;

  NewGroupWithParticipants({
    this.participants,
    this.edit,
    this.group,
    this.title
  });

  @override
  Widget build(BuildContext context) {
    // if (edit == true) title = "Update";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create $title",
          style: TextStyle(
              // fontFamily: 'Courgette',
              letterSpacing: 1.25, fontSize: 24),
        ),
        // backgroundColor: kPrimaryColor,
        // actions: [
        //   IconButton(
        //     icon: FaIcon(FontAwesomeIcons.signOutAlt),
        //     onPressed: () => UserStateMethods().logoutuser(context),
        //   )
        // ],
        centerTitle: true,
      ),
      body: NewGroupPage(edit: edit, group: group, title: title,),
    );
  }
}

class NewGroupPage extends StatefulWidget {

  static List<String> participants = List();
  // final List participants;
  final bool edit;
  final Groups group;
  final title;

  NewGroupPage({
    this.edit,
    this.group,
    this.title
  });

  @override
  State createState() => NewGroupPageState();
}

class NewGroupPageState extends State<NewGroupPage> {
  SharedPreferences preferences;
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescController = TextEditingController();
  TextEditingController _aboutTextController = TextEditingController();
  String currentuserid;
  List admin = [];

  String gid = "";
  String name = "";
  String description = "";
  String photoUrl = "";
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  File imageFileAvatar;
  final picker = ImagePicker();
  bool isLoading = false;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  // bool _status = true;
  bool isInitialLoading = false;
  final FocusNode myFocusNode = FocusNode();
  PickedFile pickedFile;
  String actionbuttontext = "Create";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
    // print('create group : ${widget.participants}');
  }

  Future<String> readDataFromLocal() async {
    isInitialLoading = true;
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");
    if (widget.edit == true) {
      // name = preferences.getString("name");
      // photoUrl = preferences.getString("photo");
      // description = preferences.getString("description");
      gid = widget.group.gid;
      name = widget.group.name;
      photoUrl = widget.group.photoUrl;
      description = widget.group.description;
      actionbuttontext = "Update";
      for (int i = 0; i < widget.group.admin.length; i++) {
        admin.add(widget.group.admin[i]);
      }
    }

    _groupNameController = TextEditingController(text: name);
    _groupDescController = TextEditingController(text: description);
    isInitialLoading = false;
    setState(() {});
    // return Future.delayed(Duration(seconds: 2), () => "Hello");
    // return photoUrl;
  }

  Future<bool> callOnFcmApiSendPushNotifications(
      String userToken, String body, String image) async {
    print("SENDING PUSH NOTIFICATION to ${userToken}");
    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "notification": {
        "body": "$body",
        "title": "${preferences.getString('name')}",
        "image": image
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      "to": "$userToken"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': "key=$FCM_SERVER_KEY" // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(postUrl,
        body: jsonEncode(data),
        // encoding: Encoding.getByName('utf-8'),
        headers: headers);
    // print("sent");
    if (response.statusCode == 200) {
      // on success do sth
      // print('test ok push CFM');
      return true;
    } else {
      print(' CFM error ${response.reasonPhrase}');
      // on failure do sth
      return false;
    }
  }

  Future getImage() async {
    pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        imageFileAvatar = File(pickedFile.path);
        // isLoading = true;
      }
    });

    // if (pickedFile != null && widget.edit == true) {
    //   // upload image to firebase storage
    //   uploadImageToFirestoreAndStorage();
    // }
  }

  Future uploadImageToFirestoreAndStorage() async {
    String mFileName = gid;
    // StorageReference storageReference =
    //     FirebaseStorage.instance.ref().child(mFileName);
    final firebase_storage.StorageReference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child("group_profile_Images")
        .child(mFileName);
    final firebase_storage.StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvatar);
    firebase_storage.StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          Firestore.instance.collection("Groups").document(gid).updateData(
              {"photoUrl": photoUrl, "name": name}).then((data) async {
            // await preferences.setString("photo", photoUrl);

            setState(() {
              isLoading = false;
            });
            await Fluttertoast.showToast(msg: "Updated Successfully.");
          });
        }, onError: (errorMsg) async {
          setState(() {
            isLoading = false;
          });
          await Fluttertoast.showToast(
              msg: "Error occured in getting Download Url !");
        });
      }
    }, onError: (errorMsg) async {
      setState(() {
        isLoading = false;
      });
      await Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  void createGroup() async {
    List admin = [];
    print("current user id ${currentuserid}");
    // nameFocusNode.unfocus();
    // descriptionFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });
    gid = DateTime.now().toIso8601String();
    admin.add(currentuserid);
    Groups group = Groups(
      gid: gid,
      users: NewGroupPage.participants,
      admin: admin,
      name: name,
      description: description,
      photoUrl: photoUrl,
      state: 1,
      aboutText: _aboutTextController.text,
      fcmToken: ''
    );

    await Firestore.instance
        .collection("Groups")
        .document(gid)
        .setData(group.toMap())
        .then((data) async {
      setState(() {
        isLoading = false;
      });
      await Fluttertoast.showToast(msg: "Success.");
    });
    if (pickedFile != null) {
      // upload image to firebase storage
      await uploadImageToFirestoreAndStorage();
    }
    // final body = "You are added in '$name' group";
    // final title = "New Group";

    //send notifications
    for (int i = 0; i < NewGroupPage.participants.length; i++) {
      // await callOnFcmApiSendPushNotifications(participants.,body,title);
    }

    print("Notification sent");

    Navigator.pop(context);
    // var count = 0;
    // Navigator.popUntil(context, (route) {
    //   return count++ == 2;
    // });
  }

  void updateGroup() async {
    nameFocusNode.unfocus();
    descriptionFocusNode.unfocus();
    setState(() {
      isLoading = false;
    });

    //update group
    Firestore.instance.document('Groups/${widget.group.gid}/').updateData(
        {"name": name, "description": description, "photoUrl": photoUrl, 'aboutText': _aboutTextController.text});

    setState(() {
      isLoading = false;
    });
    await Fluttertoast.showToast(msg: "Success.");
    // });
    if (pickedFile != null) {
      // upload image to firebase storage
      await uploadImageToFirestoreAndStorage();
    }
    // final body = "You are added in '$name' group";
    // final title = "New Group";

    //send notifications
    // for(int i=0;i<widget.participants.length;i++){
    // await callOnFcmApiSendPushNotifications(participants.,body,title);
    // }

    // print("before update");
    var count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 2;
    });
  }

  void decide() {
    if (widget.edit == true)
      updateGroup();
    else
      createGroup();
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl == '' || photoUrl == null) photoUrl = defaultPhotoUrl;
    return isInitialLoading
        ? CircularProgressIndicator()
        : Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    //Profile Image - Avatar
                    Container(
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            (imageFileAvatar == null)
                                // ? (photoUrl != "")
                                ? Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                            // display already existing image
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .lightBlueAccent),
                                                ),
                                                width: 200.0,
                                                height: 200.0,
                                                padding: EdgeInsets.all(20.0),
                                              ),
                                              // imageUrl: defaultPhotoUrl,
                                              imageUrl: photoUrl,
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(125.0)),
                                            clipBehavior: Clip.hardEdge),
                                      ],
                                    ),
                                  )
                                // : Icon(
                                //     Icons.account_circle,
                                //     size: 90.0,
                                //     color: Colors.grey,
                                //   )
                                : Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                            // display new updated image
                                            child: Image.file(
                                              imageFileAvatar,
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(125.0)),
                                            clipBehavior: Clip.hardEdge),
                                      ],
                                    ),
                                  ),
                            GestureDetector(
                              onTap: getImage,
                              child: Padding(
                                  padding:
                                      EdgeInsets.only(top: 150.0, right: 120.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 25.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.all(20.0),
                    ),

                    Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(1.0),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Container(),
                      ),
                    ]),

                    new Container(
                      // color: Color(0xFFFFFFFF),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 25.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          '${widget.title} Information',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    // new Column(
                                    //   mainAxisAlignment: MainAxisAlignment.end,
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   children: <Widget>[
                                    //     _status
                                    //         ? _getEditIcon()
                                    //         : new Container(),
                                    //   ],
                                    // )
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Name',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextField(
                                        decoration: const InputDecoration(
                                          hintText: "Enter Group Name",
                                        ),
                                        controller: _groupNameController,
                                        keyboardType: TextInputType.name,
                                        // enabled: !_status,
                                        // autofocus: !_status,
                                        onChanged: (value) {
                                          name = value;
                                        },
                                        focusNode: nameFocusNode,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Description',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextField(
                                        // readOnly: true,
                                        decoration: const InputDecoration(
                                            hintText:
                                                "Enter Group Description"),
                                        // enabled: !_status,
                                        controller: _groupDescController,
                                        keyboardType: TextInputType.name,
                                        focusNode: descriptionFocusNode,
                                        onChanged: (value) {
                                          description = value;
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            // Padding(
                            //     padding: EdgeInsets.only(
                            //         left: 25.0, right: 25.0, top: 25.0),
                            //     child: new Row(
                            //       mainAxisSize: MainAxisSize.max,
                            //       children: <Widget>[
                            //         new Column(
                            //           mainAxisAlignment:
                            //           MainAxisAlignment.start,
                            //           mainAxisSize: MainAxisSize.min,
                            //           children: <Widget>[
                            //             new Text(
                            //               'About',
                            //               style: TextStyle(
                            //                   fontSize: 16.0,
                            //                   fontWeight: FontWeight.bold),
                            //             ),
                            //           ],
                            //         ),
                            //       ],
                            //     )),
                            // Padding(
                            //     padding: EdgeInsets.only(
                            //         left: 25.0, right: 25.0, top: 2.0),
                            //     child: new Row(
                            //       mainAxisSize: MainAxisSize.max,
                            //       children: <Widget>[
                            //         new Flexible(
                            //           child: new TextField(
                            //             // readOnly: true,
                            //             decoration: const InputDecoration(
                            //                 hintText:
                            //                 "Enter About Text"),
                            //             // enabled: !_status,
                            //             controller: _aboutTextController,
                            //             keyboardType: TextInputType.name,
                            //             // focusNode: descriptionFocusNode,
                            //             onChanged: (value) {
                            //               // description = value;
                            //             },
                            //           ),
                            //         ),
                            //       ],
                            //     )),

                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: RaisedButton(
                                // disabledColor: Colors.black38,
                                // disabledTextColor: Colors.black,
                                child: new Text("Add Participants"),
                                // textColor: Theme.of(context).textTheme.bodyText1.color,
                                textColor:Colors.white,
                                color: Colors.green,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddParticipantsPage(
                                      ),
                                    ),
                                  );

                                },
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0)),
                              ),
                            ),
                            _getActionButtons()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
              )
            ],
          );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    bool disable = false;
    if (widget.edit == true && !admin.contains(currentuserid)) disable = true;
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                disabledColor: Colors.black38,
                disabledTextColor: Colors.black,
                child: new Text("$actionbuttontext"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: !disable
                    ? () {
                        if (widget.edit == true &&
                            admin.contains(currentuserid))
                          setState(() {
                            // _status = true;
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          });
                        decide();
                      }
                    : null,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }

// Widget _getEditIcon() {
//   return new GestureDetector(
//     child: new CircleAvatar(
//       backgroundColor: Colors.red,
//       radius: 14.0,
//       child: new Icon(
//         Icons.edit,
//         color: Colors.white,
//         size: 16.0,
//       ),
//     ),
//     onTap: () {
//       setState(() {
//         // _status = false;
//       });
//     },
//   );
// }
}
