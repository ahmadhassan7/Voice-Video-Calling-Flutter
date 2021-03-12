// import 'dart:async';
import 'dart:io';

import 'package:Chatify/main.dart';
import 'package:Chatify/statusView/story_player_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class StatusView extends StatefulWidget {
  @override
  _StatusViewState createState() => _StatusViewState();
}

class _StatusViewState extends State<StatusView> {
  final controller = StoryController();
  List<StoryItem> storyItems = List();

  // SharedPreferences preferences;

  var allUsersList;

  bool isInitialLoading;
  String id = "";
  String name = "";
  String email = "";
  String photoUrl = "";
  File imageFileAvatar;
  final picker = ImagePicker();
  bool isLoading = false;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  bool _status = true;

  Future<String> readDataFromLocal() async {
    isInitialLoading = true;
    // preferences = await SharedPreferences.getInstance();
    id = prefs.getString("uid");
    name = prefs.getString("name");
    photoUrl = prefs.getString("photo");
    email = prefs.getString("email");
    // return Future.delayed(Duration(seconds: 2), () => "Hello");
    // return photoUrl;
  }

  Future<String> saveStatus(File file, String type, int duration) async {
    //////////
    ///////////

    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('${id}/status/${path.basename(file.path)}');
    StorageUploadTask storageUploadTask = storageReference.putFile(file);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          Firestore.instance
              .collection("Users")
              .document(id)
              .collection('status')
              .document()
              .setData({
            'uid': id,
            'url': photoUrl,
            'type': type,
            'duration': duration,
            // 'imageUrl': userController.userInfo.value.imageUrl,
            // 'name': userController.userInfo.value.name,
            'createdOn': Timestamp.now()
          }).then((data) async {
            // await preferences.setString("photo", photoUrl);

            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Status Updated");
          });
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Error occured in getting Download Url !");
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    });

    ///////////
    /////////

    // StorageReference storageReference = FirebaseStorage.instance
    //     .ref()
    //     .child('${id}/status/image/${path.basename(file.path)}');
    // final task = storageReference.putFile(file);
    // try {
    //   StorageUploadTask snapshot = await task;
    //
    //   return storageReference.getDownloadURL();
    // } on Exception catch (e) {
    //   print(task.lastSnapshot);
    //   print(e);
    //   return null;
    // }
  }

  Future<void> _showAddStatusOptions(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Pick Image'),
            children: <Widget>[
              // ListTile(
              //   dense: true,
              //   leading: Icon(Icons.camera),
              //   title: Text("Camera"),
              //   onTap: () async {
              //     Get.back();
              //     Get.toNamed(NewMomentCameraPageRoute);
              //
              //     // final picker = ImagePicker();
              //     // final pickedFile = await picker.getImage(
              //     //     source: ImageSource.camera, maxWidth: 800);
              //     // if (pickedFile != null) {
              //     //   postController.saveMoment(File(pickedFile.path), 'image');
              //     // }
              //   },
              // ),
              ListTile(
                dense: true,
                leading: Icon(Icons.camera),
                title: Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  // Get.back();
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                  );
                  if (pickedFile != null) {
                    // postController.saveMoment(
                    //     File(pickedFile.path), 'image', 1);
                    try {
                      // showProgressDialog(title: "", message: "Uploading");
                      final url =
                          await saveStatus(File(pickedFile.path), 'image', 1);

                      // Firestore.instance.collection('users').document(id).collection('status').document().setData({
                      //   'uid': id,
                      //   'url': url,
                      //   'type': 'image',
                      //   'duration': 1,
                      //   // 'imageUrl': userController.userInfo.value.imageUrl,
                      //   // 'name': userController.userInfo.value.name,
                      //   'createdOn': Timestamp.now()
                      // });

                      // _store.collection('moments').doc(getUid()).set({
                      //   'uid': getUid(),
                      //   'url': url,
                      //   'type': type,
                      //   'imageUrl': userController.userInfo.value.imageUrl,
                      //   'name': userController.userInfo.value.name
                      // });
                      // Get.back();
                      // Get.back();
                      // Get.snackbar("Success", "Moment saved");
                    } catch (e) {
                      print(e);
                    }

                    ////////
                    //////
                    //////////

                  }
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.collections),
                title: Text("Image (Gallery)"),
                onTap: () async {
                  Navigator.pop(context);
                  // Get.back();
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(
                      source: ImageSource.gallery, maxWidth: 800);
                  if (pickedFile != null) {
                    await saveStatus(File(pickedFile.path), 'image', 1);
                  }
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.camera),
                title: Text("Video"),
                onTap: () async {
                  Navigator.pop(context);
                  // Get.back();
                  final picker = ImagePicker();
                  final pickedFile = await picker.getVideo(
                      source: ImageSource.camera,
                      maxDuration: Duration(seconds: 10));
                  VideoPlayerController controller =
                      new VideoPlayerController.file(File(pickedFile.path));
                  await controller.initialize();
                  Duration duration = controller.value.duration;
                  await saveStatus(
                      File(pickedFile.path), 'video', duration.inSeconds);

                  // if (pickedFile != null) {
                  //   // postController.postVideo.value = File(pickedFile.path);
                  //   VideoPlayerController controller =
                  //       new VideoPlayerController.file(File(pickedFile.path));
                  //   await controller.initialize();
                  //   Duration duration = controller.value.duration;
                  //   // postController.saveMoment(
                  //   //     File(pickedFile.path), 'video', duration.inSeconds);
                  // }
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.collections),
                title: Text("Video (Gallery)"),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.getVideo(
                      source: ImageSource.gallery,
                      maxDuration: Duration(seconds: 10));
                  VideoPlayerController controller =
                      new VideoPlayerController.file(File(pickedFile.path));
                  await controller.initialize();
                  Duration duration = controller.value.duration;
                  await saveStatus(
                      File(pickedFile.path), 'video', duration.inSeconds);
                  // // Get.back();
                  // final picker = ImagePicker();
                  // final pickedFile = await picker.getVideo(
                  //     source: ImageSource.gallery, maxDuration: 15.seconds);
                  // if (pickedFile != null) {
                  //   // postController.postVideo.value = File(pickedFile.path);
                  //   VideoPlayerController controller =
                  //       new VideoPlayerController.file(File(pickedFile.path));
                  //   await controller.initialize();
                  //   Duration duration = controller.value.duration;
                  //   postController.saveMoment(
                  //       File(pickedFile.path), 'video', duration.inSeconds);

                  // postController.postVideo.value = File(pickedFile.path);
                  // }
                  // final pickedFile1 = await picker.getVideo(
                  //   source: ImageSource.gallery,
                  //   // maxDuration: Duration(seconds: 30),
                  // );
                  // if (pickedFile1 != null) {
                  //
                  //   postController.saveMoment(File(pickedFile1.path), 'video');
                  // }
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    readDataFromLocal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.cyan[900],
      // appBar: AppBar(
      //   title: Text(
      //     "Status View",
      //     style: TextStyle(
      //         fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
      //   ),
      //   backgroundColor: kPrimaryColor,
      //   actions: [
      //     IconButton(
      //       icon: FaIcon(FontAwesomeIcons.signOutAlt),
      //       onPressed: () => UserStateMethods().logoutuser(context),
      //     )
      //   ],
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {},
              child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // print('$id ,  adjfl');
                          //////////
                          ////////////
                          final res = await Firestore.instance
                              .collection('Users')
                              .document(id)
                              .collection('status')
                              .orderBy('createdOn', descending: true)
                              .limit(5)
                              .getDocuments();
                          if (res.documents.length != 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StoryPlayerPage(res.documents)));
                          } else {
                            _showAddStatusOptions(context);
                          }
                          ///////////
                          ////////
                        },
                        child: Row(
                          children: <Widget>[
                            Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(photoUrl),
                                  maxRadius: 30,
                                ),
                                // Positioned(
                                //   left: 0,
                                //   top: 30,
                                //   child: StatusIndicator(
                                //     uid: widget.data["id"],
                                //     screen: "chatListScreen",
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'My Status',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      'Tap To View Status',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showAddStatusOptions(context);
                      },
                      child: Icon(
                        Icons.add,
                        size: 25,
                        color: Colors.cyan[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            StreamBuilder(
              stream: Firestore.instance
                  .collection("Users")
                  .document(id)
                  .collection('chatList')
                  .snapshots(),
              builder: (context, snapshot) {
                // print(id);
                if (!snapshot.hasData) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                        Colors.cyan[900],
                      )),
                    ),
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 16),
                    itemCount: snapshot.data.documents.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // print(photoUrl);

                      return FutureBuilder<DocumentSnapshot>(
                        future: Firestore.instance
                            .collection('Users')
                            .document(snapshot.data.documents[index]['id'])
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if(snapshot.hasData){
                            return Container(
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 10, bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          // print('$id ,  adjfl');
                                          //////////
                                          ////////////
                                          final res = await Firestore.instance
                                              .collection('Users')
                                              .document(snapshot.data['uid'])
                                              .collection('status')
                                              .orderBy('createdOn',
                                              descending: true)
                                              .limit(5)
                                              .getDocuments();
                                          if (res.documents.length != 0) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoryPlayerPage(
                                                            res.documents)));
                                          }
                                          else{
                                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('No Story')));

                                          }
                                          ///////////
                                          ////////
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot?.data['photoUrl'] ??
                                                      'https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg'),
                                              maxRadius: 30,
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot.data['name'] ??
                                                          'User',
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                    Text(
                                                      snapshot.data['email'] != '' ? snapshot.data['email']:snapshot.data['phone'],
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // GestureDetector(
                                    //
                                    //   onTap: (){
                                    //     _showAddStatusOptions(context);
                                    //
                                    //   },
                                    //   child: Icon(
                                    //     Icons.add,
                                    //     size: 25,
                                    //     color: Colors.cyan[900],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );


                          }else{return Container();}
                        },
                      );

                      print(snapshot.data.documents[index]['id']);

                      // QuerySnapshot res;
                      //  Firestore.instance
                      //     .collection('Users')
                      //     .document(snapshot.data.documents[index]['id']).get();
                      //      .then((value) {
                      //    res = value;
                      //    print(res.documents[0]['uid']);
                      //    return Text('sldkjaljflajfljfljfl');
                      //
                      //  });
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picker = ImagePicker();
          final pickedFile = await picker.getImage(
            source: ImageSource.camera,
            maxWidth: 800,
          );
          if (pickedFile != null) {
            // postController.saveMoment(
            //     File(pickedFile.path), 'image', 1);
            try {
              // showProgressDialog(title: "", message: "Uploading");
              final url = await saveStatus(File(pickedFile.path), 'image', 1);
            } catch (e) {
              print(e);
            }
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}

// class SettingsScreen extends StatefulWidget {
//   @override
//   State createState() => SettingsScreenState();
// }

// class SettingsScreenState extends State<SettingsScreen> {
//   SharedPreferences preferences;
//   TextEditingController nameTextEditingController;
//   TextEditingController emailTextEditingController;
//
//   String id = "";
//   String name = "";
//   String email = "";
//   String photoUrl = "";
//   File imageFileAvatar;
//   final picker = ImagePicker();
//   bool isLoading = false;
//   final FocusNode nameFocusNode = FocusNode();
//   final FocusNode emailFocusNode = FocusNode();
//   bool _status = true;
//   bool isInitialLoading = false;
//   final FocusNode myFocusNode = FocusNode();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     readDataFromLocal();
//   }
//
//   Future<String> readDataFromLocal() async {
//     isInitialLoading = true;
//     preferences = await SharedPreferences.getInstance();
//     id = preferences.getString("uid");
//     name = preferences.getString("name");
//     photoUrl = preferences.getString("photo");
//     email = preferences.getString("email");
//
//     nameTextEditingController = TextEditingController(text: name);
//     emailTextEditingController = TextEditingController(text: email);
//     isInitialLoading = false;
//     setState(() {});
//     // return Future.delayed(Duration(seconds: 2), () => "Hello");
//     // return photoUrl;
//   }
//
//   Future getImage() async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     setState(() {
//       if (pickedFile != null) {
//         imageFileAvatar = File(pickedFile.path);
//         isLoading = true;
//       }
//     });
//
//     if (pickedFile != null) {
//       // upload image to firebase storage
//       uploadImageToFirestoreAndStorage();
//     }
//   }
//
//   Future uploadImageToFirestoreAndStorage() async {
//     String mFileName = id;
//     StorageReference storageReference =
//         FirebaseStorage.instance.ref().child(mFileName);
//     StorageUploadTask storageUploadTask =
//         storageReference.putFile(imageFileAvatar);
//     StorageTaskSnapshot storageTaskSnapshot;
//     storageUploadTask.onComplete.then((value) {
//       if (value.error == null) {
//         storageTaskSnapshot = value;
//         storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
//           photoUrl = newImageDownloadUrl;
//           Firestore.instance.collection("Users").document(id).updateData(
//               {"photoUrl": photoUrl, "name": name}).then((data) async {
//             await preferences.setString("photo", photoUrl);
//
//             setState(() {
//               isLoading = false;
//             });
//             Fluttertoast.showToast(msg: "Updated Successfully.");
//           });
//         }, onError: (errorMsg) {
//           setState(() {
//             isLoading = false;
//           });
//           Fluttertoast.showToast(
//               msg: "Error occured in getting Download Url !");
//         });
//       }
//     }, onError: (errorMsg) {
//       setState(() {
//         isLoading = false;
//       });
//       Fluttertoast.showToast(msg: errorMsg.toString());
//     });
//   }
//
//   void updateData() {
//     nameFocusNode.unfocus();
//     emailFocusNode.unfocus();
//     setState(() {
//       isLoading = false;
//     });
//
//     Firestore.instance
//         .collection("Users")
//         .document(id)
//         .updateData({"name": name}).then((data) async {
//       await preferences.setString("photo", photoUrl);
//       await preferences.setString("name", name);
//
//       setState(() {
//         isLoading = false;
//       });
//       Fluttertoast.showToast(msg: "Updated Successfully.");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isInitialLoading
//         ? oldcircularprogress()
//         : Stack(
//             children: <Widget>[
//               SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     //Profile Image - Avatar
//                     Container(
//                       child: Center(
//                         child: Stack(
//                           children: <Widget>[
//                             (imageFileAvatar == null)
//                                 // ? (photoUrl != "")
//                                 ? Container(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         // Material(
//                                         //     // display already existing image
//                                         //     child: CachedNetworkImage(
//                                         //       placeholder: (context, url) =>
//                                         //           Container(
//                                         //         child:
//                                         //             CircularProgressIndicator(
//                                         //           strokeWidth: 2.0,
//                                         //           valueColor:
//                                         //               AlwaysStoppedAnimation<
//                                         //                       Color>(
//                                         //                   Colors
//                                         //                       .lightBlueAccent),
//                                         //         ),
//                                         //         width: 200.0,
//                                         //         height: 200.0,
//                                         //         padding: EdgeInsets.all(20.0),
//                                         //       ),
//                                         //       imageUrl: photoUrl,
//                                         //       width: 200.0,
//                                         //       height: 200.0,
//                                         //       fit: BoxFit.cover,
//                                         //     ),
//                                         //     borderRadius: BorderRadius.all(
//                                         //         Radius.circular(125.0)),
//                                         //     clipBehavior: Clip.hardEdge),
//                                       ],
//                                     ),
//                                   )
//                                 // : Icon(
//                                 //     Icons.account_circle,
//                                 //     size: 90.0,
//                                 //     color: Colors.grey,
//                                 //   )
//                                 : Container(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Material(
//                                             // display new updated image
//                                             child: Image.file(
//                                               imageFileAvatar,
//                                               width: 200.0,
//                                               height: 200.0,
//                                               fit: BoxFit.cover,
//                                             ),
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(125.0)),
//                                             clipBehavior: Clip.hardEdge),
//                                       ],
//                                     ),
//                                   ),
//                             GestureDetector(
//                               onTap: getImage,
//                               child: Padding(
//                                   padding:
//                                       EdgeInsets.only(top: 150.0, right: 120.0),
//                                   child: new Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: <Widget>[
//                                       new CircleAvatar(
//                                         backgroundColor: Colors.red,
//                                         radius: 25.0,
//                                         child: new Icon(
//                                           Icons.camera_alt,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     ],
//                                   )),
//                             )
//                           ],
//                         ),
//                       ),
//                       width: double.infinity,
//                       margin: EdgeInsets.all(20.0),
//                     ),
//
//                     Column(children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.all(1.0),
//                         child: isLoading ? oldcircularprogress() : Container(),
//                       ),
//                     ]),
//
//                     new Container(
//                       // color: Color(0xFFFFFFFF),
//                       child: Padding(
//                         padding: EdgeInsets.only(bottom: 25.0),
//                         child: new Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: <Widget>[
//                             Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 25.0, right: 25.0, top: 25.0),
//                                 child: new Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: <Widget>[
//                                     new Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: <Widget>[
//                                         new Text(
//                                           'Personal Information',
//                                           style: TextStyle(
//                                               fontSize: 18.0,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                     new Column(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: <Widget>[
//                                         _status
//                                             ? _getEditIcon()
//                                             : new Container(),
//                                       ],
//                                     )
//                                   ],
//                                 )),
//                             Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 25.0, right: 25.0, top: 25.0),
//                                 child: new Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: <Widget>[
//                                     new Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: <Widget>[
//                                         new Text(
//                                           'Name',
//                                           style: TextStyle(
//                                               fontSize: 16.0,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 )),
//                             Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 25.0, right: 25.0, top: 2.0),
//                                 child: new Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: <Widget>[
//                                     new Flexible(
//                                       child: new TextField(
//                                         decoration: const InputDecoration(
//                                           hintText: "Enter Your Name",
//                                         ),
//                                         controller: nameTextEditingController,
//                                         enabled: !_status,
//                                         autofocus: !_status,
//                                         onChanged: (value) {
//                                           name = value;
//                                         },
//                                         focusNode: nameFocusNode,
//                                       ),
//                                     ),
//                                   ],
//                                 )),
//                             Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 25.0, right: 25.0, top: 25.0),
//                                 child: new Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: <Widget>[
//                                     new Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: <Widget>[
//                                         new Text(
//                                           'Email ID',
//                                           style: TextStyle(
//                                               fontSize: 16.0,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 )),
//                             Padding(
//                                 padding: EdgeInsets.only(
//                                     left: 25.0, right: 25.0, top: 2.0),
//                                 child: new Row(
//                                   mainAxisSize: MainAxisSize.max,
//                                   children: <Widget>[
//                                     new Flexible(
//                                       child: new TextField(
//                                         readOnly: true,
//                                         decoration: const InputDecoration(
//                                             hintText: "Enter Email ID"),
//                                         enabled: !_status,
//                                         controller: emailTextEditingController,
//                                         focusNode: emailFocusNode,
//                                       ),
//                                     ),
//                                   ],
//                                 )),
//                             !_status ? _getActionButtons() : new Container(),
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 padding: EdgeInsets.only(left: 15.0, right: 15.0),
//               )
//             ],
//           );
//   }
//
//   @override
//   void dispose() {
//     // Clean up the controller when the Widget is disposed
//     myFocusNode.dispose();
//     super.dispose();
//   }
//
//   Widget _getActionButtons() {
//     return Padding(
//       padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
//       child: new Row(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(right: 10.0),
//               child: Container(
//                   child: new RaisedButton(
//                 child: new Text("Update"),
//                 textColor: Colors.white,
//                 color: Colors.green,
//                 onPressed: () {
//                   setState(() {
//                     _status = true;
//                     FocusScope.of(context).requestFocus(new FocusNode());
//                   });
//                   updateData();
//                 },
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: new BorderRadius.circular(20.0)),
//               )),
//             ),
//             flex: 2,
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(left: 10.0),
//               child: Container(
//                   child: new RaisedButton(
//                 child: new Text("Cancel"),
//                 textColor: Colors.white,
//                 color: Colors.red,
//                 onPressed: () {
//                   setState(() {
//                     _status = true;
//                     FocusScope.of(context).requestFocus(new FocusNode());
//                   });
//                   // logoutuser();
//                 },
//                 shape: new RoundedRectangleBorder(
//                     borderRadius: new BorderRadius.circular(20.0)),
//               )),
//             ),
//             flex: 2,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _getEditIcon() {
//     return new GestureDetector(
//       child: new CircleAvatar(
//         backgroundColor: Colors.red,
//         radius: 14.0,
//         child: new Icon(
//           Icons.edit,
//           color: Colors.white,
//           size: 16.0,
//         ),
//       ),
//       onTap: () {
//         setState(() {
//           _status = false;
//         });
//       },
//     );
//   }
// }
