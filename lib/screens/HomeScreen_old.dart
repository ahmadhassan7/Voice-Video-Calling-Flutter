// import 'dart:io';
//
// import 'package:Chatify/enum/user_state.dart';
// import 'package:Chatify/resources/user_state_methods.dart';
// import 'package:Chatify/screens/AccountSettings/AccountSettingsPage.dart';
// import 'package:Chatify/screens/CallLogs/log_screen.dart';
// import 'package:Chatify/screens/CallScreens/pickup/pickup_layout.dart';
// import 'package:Chatify/screens/ChatDetail/ChattingPage.dart';
// import 'package:Chatify/screens/Chats/Chats.dart';
// import 'package:Chatify/screens/Chats/UserList.dart';
// import 'package:Chatify/screens/Chats/create_new_group.dart';
// import 'package:Chatify/screens/newbroadcast.dart';
// import 'package:Chatify/screens/threeSixtyView/ThreeSixtyView.dart';
// import 'package:Chatify/statusView/statusView.dart';
// import 'package:Chatify/widgets/admob_services.dart';
// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// // import 'package:firebase_admob/firebase_admob.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'help.dart';
//
// class HomeScreen extends StatefulWidget {
//   final String currentuserid;
//
//   HomeScreen({Key key, @required this.currentuserid}) : super(key: key);
//
//   @override
//   _HomeScreenState createState() =>
//       _HomeScreenState(currentuserid: currentuserid);
// }
//
// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   _HomeScreenState({Key key, @required this.currentuserid});
//
//   var allUsersWithDetails = [];
//   String currentuserid;
//   String currentusername;
//   String currentuserphoto;
//   TextEditingController emailEditingController = new TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     // _getUsersDetails();
//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//       UserStateMethods()
//           .setUserState(userId: currentuserid, userState: UserState.Online);
//     });
//     AdmobServices.initAdmob();
//
//     WidgetsBinding.instance.addObserver(this);
//   }
//
//   // _getUsersDetails() async {
//   //
//   //   QuerySnapshot querySnapshot =
//   //   await Firestore.instance.collection("Users").getDocuments();
//   //
//   //   setState(() {
//   //     allUsersWithDetails = querySnapshot.documents;
//   //     allUsersWithDetails
//   //         .removeWhere((element) => element["uid"] == currentuserid);
//   //   });
//   // }
//   @override
//   void dispose() {
//     super.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     switch (state) {
//       case AppLifecycleState.resumed:
//         currentuserid != null
//             ? UserStateMethods().setUserState(
//                 userId: currentuserid, userState: UserState.Online)
//             : print("Resumed State");
//         break;
//       case AppLifecycleState.inactive:
//         currentuserid != null
//             ? UserStateMethods().setUserState(
//                 userId: currentuserid, userState: UserState.Offline)
//             : print("Inactive State");
//         break;
//       case AppLifecycleState.paused:
//         currentuserid != null
//             ? UserStateMethods().setUserState(
//                 userId: currentuserid, userState: UserState.Waiting)
//             : print("Paused State");
//         break;
//       case AppLifecycleState.detached:
//         currentuserid != null
//             ? UserStateMethods().setUserState(
//                 userId: currentuserid, userState: UserState.Offline)
//             : print("Detached State");
//         break;
//     }
//   }
//
//   TextEditingController searchTextEditingController = TextEditingController();
//   Future<QuerySnapshot> futureSearchResults;
//
//   // final String currentuserid;
//
//   @override
//   Widget build(BuildContext context) {
//     return PickupLayout(
//       uid: currentuserid,
//       scaffold: Scaffold(
//         body: MyStatefulWidget(),
//       ),
//     );
//   }
// }
//
// class MyStatefulWidget extends StatefulWidget {
//   MyStatefulWidget({Key key}) : super(key: key);
//
//   @override
//   _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
// }
//
// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   bool isLoading = false;
//
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle =
//       TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//   List<Widget> _widgetOptions = <Widget>[
//     ChatsPage(),
//     StatusView(),
//     UserList(),
//     LogScreen(),
//     ThreeSixtyView(),
//     Settings(),
//   ];
//
//   var allUsersWithDetails = [];
//   String currentuserid;
//   String currentusername;
//   String currentuserphoto;
//
//   // void _onItemTapped(int index) {
//   //   setState(() {
//   //     _selectedIndex = index;
//   //   });
//   // }
//   Future getImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       // upload image to firebase storage
//       uploadImageToFirestoreAndStorage(File(pickedFile.path));
//     }
//   }
//
//   Future uploadImageToFirestoreAndStorage(File imageFileAvatar) async {
//     final preferences = await SharedPreferences.getInstance();
//     String id = preferences.getString("uid");
//     String name = preferences.getString("name");
//     String photoUrl = preferences.getString("photo");
//     String email = preferences.getString("email");
//
//     StorageReference storageReference =
//         FirebaseStorage.instance.ref().child(id);
//     StorageUploadTask storageUploadTask =
//         storageReference.putFile(imageFileAvatar);
//     StorageTaskSnapshot storageTaskSnapshot;
//     storageUploadTask.onComplete.then((value) {
//       if (value.error == null) {
//         String currTime = DateTime.now().millisecondsSinceEpoch.toString();
//
//         storageTaskSnapshot = value;
//         storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
//           photoUrl = newImageDownloadUrl;
//           Firestore.instance
//               .collection("Users")
//               .document(id)
//               .collection('chatList')
//               .document(currTime)
//               .setData({
//                 "isGroup": true,
//                 "photoUrl": photoUrl,
//                 "adminEmail": email,
//                 "adminId": id,
//                 "timestamp": currTime,
//                 "adminName": name
//               }, merge: true)
//               .then((data) async {})
//               .then((value) {
//                 Firestore.instance
//                     .collection("messages")
//                     .document(currTime)
//                     .setData({
//                   "isGroup": true,
//                   "photoUrl": photoUrl,
//                   "groupId": currTime,
//                   "adminEmail": email,
//                   "adminId": id,
//                   "timestamp": currTime,
//                   "adminName": name
//                 });
//               });
//         }, onError: (errorMsg) {
//           setState(() {
//             isLoading = false;
//           });
//         });
//       }
//     }, onError: (errorMsg) {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
//
//
//   void handleEvent(
//       AdmobAdEvent event, Map<String, dynamic> args, String adType) {
//     switch (event) {
//       case AdmobAdEvent.loaded:
//         // interstitialAd.show();
//         // showSnackBar('New Admob $adType Ad loaded!');
//         break;
//       case AdmobAdEvent.opened:
//         // showSnackBar('Admob $adType Ad opened!');
//         break;
//       case AdmobAdEvent.closed:
//         // showSnackBar('Admob $adType Ad closed!');
//         break;
//       case AdmobAdEvent.failedToLoad:
//         // showSnackBar('Admob $adType failed to load. :(');
//         break;
//       case AdmobAdEvent.rewarded:
//
//         break;
//       default:
//     }
//   }
//   AdmobInterstitial interstitialAd;
//
//
//   @override
//   void initState() {
//
//
//     interstitialAd = AdmobInterstitial(
//       adUnitId: AdmobServices.getInterstitialAdId(),
//       listener: (AdmobAdEvent event, Map<String, dynamic> args) {
//         if (event == AdmobAdEvent.closed) interstitialAd.load();
//         handleEvent(event, args, 'Interstitial');
//       },
//     );
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // interstitialAd.load();
//     return DefaultTabController(
//       length: 4,
//       initialIndex: 0,
//       child: Scaffold(
//         appBar: AppBar(
//           // backgroundColor: Theme.of(context).primaryColor,
//           title: Text("BIMeta"),
//           actions: <Widget>[
//             // IconButton(
//             //     icon: Icon(
//             //       Icons.search,
//             //       // color: Colors.white,
//             //     ),
//             //     onPressed: () {
//             //
//             //       // Navigator.push(context,
//             //       //     MaterialPageRoute(builder: (context) => Search()));
//             //     }),
//             SizedBox(
//               width: 1,
//             ),
//             IconButton(
//                 icon: Icon(
//                   Icons.search,
//                   // color: Colors.white,
//                 ),
//                 onPressed: () {
//                   // createGroup(context);
//
//                   // setState(() {
//                   //   _selectedIndex = 2;
//                   // });
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => UserList()),
//                   );
//                 }),
//             IconButton(
//                 icon: Icon(
//                   Icons.group_add,
//                   // color: Colors.white,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _selectedIndex = 2;
//                   });
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => NewGroupWithParticipants()),
//                   );
//                 }),
//             PopupMenuButton(
//               icon: Icon(
//                 Icons.more_vert,
//                 // color: Colors.white,
//               ),
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => NewGroupWithParticipants()),
//                       );
//
//                       // Navigator.push(
//                       //     context,
//                       //     MaterialPageRoute(
//                       //         builder: (context) => NewBroadCast()));
//                     },
//                     child: Text("New broadcast"),
//                   ),
//                 ),
//                 // PopupMenuItem(
//                 //   child: GestureDetector(
//                 //     onTap: () {
//                 //       Navigator.pop(context);
//                 //
//                 //       /////////code here
//                 //     },
//                 //     child: Text("Invite"),
//                 //   ),
//                 // ),
//                 PopupMenuItem(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => Help()));
//                     },
//                     child: Text("Settings"),
//                   ),
//                 ),
//                 PopupMenuItem(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//
//                       ////////// code here
//                     },
//                     child: Text("Buy BIMeta Pro"),
//                   ),
//                 ),
//                 PopupMenuItem(
//                   child: GestureDetector(
//                     onTap: () {
//                       UserStateMethods().logoutuser(context);
//                       ////////// code here
//                     },
//                     child: Text("Sign Out"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           bottom: TabBar(
//             indicatorColor: Theme.of(context).primaryColor,
//             tabs: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _selectedIndex = 0;
//                   });
//                 },
//                 child: Tab(
//                   text: "Chat",
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () async {
//                     setState(() {
//                       _selectedIndex = 1;
//                     });
//                   // if (await interstitialAd.isLoaded) {
//                   //   interstitialAd.show();
//                   // }
//                 },
//                 child: Tab(
//                   text: "Status",
//                 ),
//               ),
//               // GestureDetector(
//               //   onTap: (){
//               //   setState(() {
//               //     _selectedIndex = 1;
//               //   });
//               //
//               //   },
//               //   child: Tab(
//               //     text: "Users",
//               //   ),
//               // ),
//               GestureDetector(
//                 onTap: () async {
//                   setState(() {
//                     _selectedIndex = 2;
//                   });
//
//                   // interstitialAd.show();
//                   // if (await interstitialAd.isLoaded) {
//                   //   interstitialAd.show();
//                   // }
//                   // interstitialAd.load();
//
//                 },
//                 child: Tab(
//                   text: "Calls",
//                 ),
//               ),
//               GestureDetector(
//                   onTap: () async {
//                     setState(() {
//                       _selectedIndex = 4;
//                     });
//                     if (await interstitialAd.isLoaded) {
//                       interstitialAd.show();
//                     }
//                   },
//                   child: Tab(text: "360 View")),
//               // GestureDetector(
//               //   onTap: (){
//               //     setState(() {
//               //       _selectedIndex = 4;
//               //     });
//               //
//               //   },
//               //   child: Tab(
//               //     text: "About",
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: _widgetOptions.elementAt(_selectedIndex),
//               ),
//             ),
//             AdmobBanner(
//                 adUnitId: AdmobServices.getHomeBannerId(),
//                 adSize: AdmobBannerSize.FULL_BANNER),
//           ],
//         ),
//         // bottomNavigationBar: CurvedNavigationBar(
//         //   height: 65.0,
//         //   backgroundColor: Colors.white,
//         //   color: kPrimaryLightColor,
//         //   buttonBackgroundColor: kPrimaryLightColor,
//         //   items: [
//         //     Padding(
//         //       padding: EdgeInsets.all(10.0),
//         //       child: Icon(
//         //         Icons.chat,
//         //         color: _selectedIndex == 0 ? kPrimaryColor : Colors.black,
//         //       ),
//         //     ),
//         //     Padding(
//         //       padding: EdgeInsets.all(10.0),
//         //       child: Icon(
//         //         Icons.supervised_user_circle,
//         //         color: _selectedIndex == 1 ? kPrimaryColor : Colors.black,
//         //       ),
//         //     ),
//         //     Padding(
//         //       padding: EdgeInsets.all(10.0),
//         //       child: Icon(
//         //         Icons.call,
//         //         color: _selectedIndex == 2 ? kPrimaryColor : Colors.black,
//         //       ),
//         //     ),
//         //     Padding(
//         //       padding: EdgeInsets.all(10.0),
//         //       child: Icon(
//         //         Icons.person_outline,
//         //         color: _selectedIndex == 3 ? kPrimaryColor : Colors.black,
//         //       ),
//         //     ),
//         //   ],
//         //   // currentIndex: _selectedIndex,
//         //   // selectedItemColor: kPrimaryColor,
//         //   // selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
//         //   // unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
//         //   onTap: _onItemTapped,
//         // ),
//       ),
//     );
//   }
// }
//
// class DataSearch extends SearchDelegate {
//   DataSearch(
//       {this.allUsersList,
//       this.currentuserid,
//       this.currentusername,
//       this.currentuserphoto});
//
//   var allUsersList;
//   String currentuserid;
//   String currentusername;
//   String currentuserphoto;
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = "";
//         },
//       )
//     ];
//     // Actions for AppBar
//     throw UnimplementedError();
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     // Leading Icon on left of appBar
//     return IconButton(
//       icon: AnimatedIcon(
//         icon: AnimatedIcons.menu_arrow,
//         progress: transitionAnimation,
//       ),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//     throw UnimplementedError();
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     // show some result based on selection
//
//     throw UnimplementedError();
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // Show when someone searches for something
//     var userList = [];
//     allUsersList.forEach((e) {
//       userList.add(e);
//     });
//     var suggestionList = userList;
//
//     if (query.isNotEmpty) {
//       suggestionList = [];
//       userList.forEach((element) {
//         if (element["name"].toLowerCase().startsWith(query.toLowerCase())) {
//           suggestionList.add(element);
//         }
//       });
//     }
//     return ListView.builder(
//         itemBuilder: (context, index) => ListTile(
//               onTap: () {
//                 close(context, null);
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return Chat(
//                     receiverId: suggestionList[index]["uid"],
//                     receiverAvatar: suggestionList[index]["photoUrl"],
//                     receiverName: suggestionList[index]["name"],
//                     currUserId: currentuserid,
//                     currUserName: currentusername,
//                     currUserAvatar: currentuserphoto,
//                   );
//                 }));
//               },
//               leading: Icon(Icons.person),
//               title: RichText(
//                 text: TextSpan(
//                     text: suggestionList[index]["name"]
//                         .toLowerCase()
//                         .substring(0, query.length),
//                     style: TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.bold),
//                     children: [
//                       TextSpan(
//                           text: suggestionList[index]["name"]
//                               .toLowerCase()
//                               .substring(query.length),
//                           style: TextStyle(color: Colors.grey))
//                     ]),
//               ),
//             ),
//         itemCount: suggestionList.length);
//     throw UnimplementedError();
//   }
// }
