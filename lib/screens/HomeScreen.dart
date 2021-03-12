import 'dart:io';

import 'package:Chatify/enum/user_state.dart';
import 'package:Chatify/resources/user_state_methods.dart';
import 'package:Chatify/screens/CallLogs/log_screen.dart';
import 'package:Chatify/screens/CallScreens/pickup/pickup_layout.dart';
import 'package:Chatify/screens/ChatDetail/ChattingPage.dart';
import 'package:Chatify/screens/Chats/Chats.dart';
import 'package:Chatify/screens/Chats/UserList.dart';
import 'package:Chatify/screens/Chats/create_new_group.dart';
import 'package:Chatify/screens/contacts/contacts_list_page.dart';
import 'package:Chatify/screens/threeSixtyView/ThreeSixtyView.dart';
import 'package:Chatify/statusView/statusView.dart';
import 'package:Chatify/widgets/admob_services.dart';
import 'package:Chatify/screens/contacts/invite_friends.dart';
// import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'help.dart';

class HomeScreen extends StatefulWidget {
  final String currentuserid;

  HomeScreen({Key key, @required this.currentuserid}) : super(key: key);

  @override
  _HomeScreenState createState() =>
      _HomeScreenState(currentuserid: currentuserid);
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  _HomeScreenState({Key key, @required this.currentuserid});

  var allUsersWithDetails = [];
  String currentuserid;
  String currentusername;
  String currentuserphoto;
  TextEditingController emailEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    // _getUsersDetails();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      UserStateMethods()
          .setUserState(userId: currentuserid, userState: UserState.Online);
    });

    if(prefs.containsKey('isPaidUser')){
      if(!prefs.getBool('isPaidUser')){
         // AdmobServices.initAdmob();
      }
    }

    WidgetsBinding.instance.addObserver(this);
  }

  // _getUsersDetails() async {
  //
  //   QuerySnapshot querySnapshot =
  //   await Firestore.instance.collection("Users").getDocuments();
  //
  //   setState(() {
  //     allUsersWithDetails = querySnapshot.documents;
  //     allUsersWithDetails
  //         .removeWhere((element) => element["uid"] == currentuserid);
  //   });
  // }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Online)
            : print("Resumed State");
        break;
      case AppLifecycleState.inactive:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Offline)
            : print("Inactive State");
        break;
      case AppLifecycleState.paused:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Waiting)
            : print("Paused State");
        break;
      case AppLifecycleState.detached:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid, userState: UserState.Offline)
            : print("Detached State");
        break;
    }
  }

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  // final String currentuserid;

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      uid: currentuserid,
      scaffold: Scaffold(
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool isLoading = false;

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    ChatsPage(),
    StatusView(),
    // UserList(),
    LogScreen(),
    ThreeSixtyView(),
    // Settings(),
  ];

  var allUsersWithDetails = [];
  String currentuserid;
  String currentusername;
  String currentuserphoto;

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }
  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // upload image to firebase storage
      uploadImageToFirestoreAndStorage(File(pickedFile.path));
    }
  }

  Future uploadImageToFirestoreAndStorage(File imageFileAvatar) async {
    final preferences = await SharedPreferences.getInstance();
    String id = preferences.getString("uid");
    String name = preferences.getString("name");
    String photoUrl = preferences.getString("photo");
    String email = preferences.getString("email");

    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(id);
    StorageUploadTask storageUploadTask =
        storageReference.putFile(imageFileAvatar);
    StorageTaskSnapshot storageTaskSnapshot;
    storageUploadTask.onComplete.then((value) {
      if (value.error == null) {
        String currTime = DateTime.now().millisecondsSinceEpoch.toString();

        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;
          Firestore.instance
              .collection("Users")
              .document(id)
              .collection('chatList')
              .document(currTime)
              .setData({
                "isGroup": true,
                "photoUrl": photoUrl,
                "adminEmail": email,
                "adminId": id,
                "timestamp": currTime,
                "adminName": name
              }, merge: true)
              .then((data) async {})
              .then((value) {
                Firestore.instance
                    .collection("messages")
                    .document(currTime)
                    .setData({
                  "isGroup": true,
                  "photoUrl": photoUrl,
                  "groupId": currTime,
                  "adminEmail": email,
                  "adminId": id,
                  "timestamp": currTime,
                  "adminName": name
                });
              });
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
    });
  }

  // void handleEvent(
  //     AdmobAdEvent event, Map<String, dynamic> args, String adType) {
  //   switch (event) {
  //     case AdmobAdEvent.loaded:
  //       // interstitialAd.show();
  //       // showSnackBar('New Admob $adType Ad loaded!');
  //       break;
  //     case AdmobAdEvent.opened:
  //       // showSnackBar('Admob $adType Ad opened!');
  //       break;
  //     case AdmobAdEvent.closed:
  //       // showSnackBar('Admob $adType Ad closed!');
  //       break;
  //     case AdmobAdEvent.failedToLoad:
  //       // showSnackBar('Admob $adType failed to load. :(');
  //       break;
  //     case AdmobAdEvent.rewarded:
  //       break;
  //     default:
  //   }
  // }

  // AdmobInterstitial interstitialAd;

  @override
  void initState() {
    // interstitialAd = AdmobInterstitial(
    //   adUnitId: AdmobServices.getInterstitialAdId(),
    //   listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    //     if (event == AdmobAdEvent.closed) interstitialAd.load();
    //     handleEvent(event, args, 'Interstitial');
    //   },
    // );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // interstitialAd.load();
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Theme.of(context).primaryColor,
          title: Text("BIMeta"),
          actions: <Widget>[
            // IconButton(
            //     icon: Icon(
            //       Icons.search,
            //       // color: Colors.white,
            //     ),
            //     onPressed: () {
            //
            //       // Navigator.push(context,
            //       //     MaterialPageRoute(builder: (context) => Search()));
            //     }),
            SizedBox(
              width: 1,
            ),
            IconButton(
                icon: Icon(
                  Icons.search,
                  // color: Colors.white,
                ),
                onPressed: () {
                  // createGroup(context);

                  // setState(() {
                  //   _selectedIndex = 2;
                  // });

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserList()),
                  );
                }),
            IconButton(
                icon: Icon(
                  Icons.group_add,
                  // color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewGroupWithParticipants(title:'Group')),
                  );
                }),
            PopupMenuButton(
              onSelected: (value) async {
                switch (value) {
                  case 'New broadcast':
                    print(value);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewGroupWithParticipants(title: 'Broadcast',)),
                    );
                    break;
                  case 'Contacts':
                    print(value);
                    if (await Permission.contacts.request().isGranted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactListPage()));
                    } else {
                      // Get.snackbar('Error','Contact Permission Required...');
                    }
                    break;
                  case 'Settings':
                    print(value);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Help()));
                    break;
                  case 'Invite Friends':
                    print(value);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Invitefriends()));
                    break;
                  case 'Buy BIMeta Pro':
                    print(value);
                    break;
                  case 'Log Out':
                    print(value);
                    UserStateMethods().logoutuser(context);

                    break;
                }
              },
              color: Theme.of(context).scaffoldBackgroundColor,
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'New broadcast',
                  child: Text(
                    "New broadcast",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
                PopupMenuItem(
                  value: 'Invite Friends',
                  child: Text(
                    "Invite Friends",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
                PopupMenuItem(
                  value: 'Contacts',
                  child: Text(
                    "Contacts",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
                PopupMenuItem(
                  value: 'Settings',
                  child: Text(
                    "Settings",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
                PopupMenuItem(
                  value: 'Buy BIMeta Pro',
                  child: Text(
                    "Buy BIMeta Pro",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
                PopupMenuItem(
                  value: 'Log Out',
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            onTap: (index) {},
            // indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(
                text: "Chat",
              ),
              Tab(
                text: "Status",
              ),
              Tab(
                text: "Calls",
              ),
              Tab(text: "360 View"),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: TabBarView(
              children: _widgetOptions,
            )),
            // !prefs.getBool('isPaidUser') ? AdmobBanner(
            //     adUnitId: AdmobServices.getHomeBannerId(),
            //     adSize: AdmobBannerSize.FULL_BANNER):Container(width: 1,height: 1,),
          ],
        ),

      ),
    );
  }
}

class DataSearch extends SearchDelegate {
  DataSearch(
      {this.allUsersList,
      this.currentuserid,
      this.currentusername,
      this.currentuserphoto});

  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
    // Actions for AppBar
    throw UnimplementedError();
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading Icon on left of appBar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on selection

    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when someone searches for something
    var userList = [];
    allUsersList.forEach((e) {
      userList.add(e);
    });
    var suggestionList = userList;

    if (query.isNotEmpty) {
      suggestionList = [];
      userList.forEach((element) {
        if (element["name"].toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      });
    }
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                close(context, null);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Chat(
                    receiverId: suggestionList[index]["uid"],
                    receiverAvatar: suggestionList[index]["photoUrl"],
                    receiverName: suggestionList[index]["name"],
                    currUserId: currentuserid,
                    currUserName: currentusername,
                    currUserAvatar: currentuserphoto,
                  );
                }));
              },
              leading: Icon(Icons.person),
              title: RichText(
                text: TextSpan(
                    text: suggestionList[index]["name"]
                        .toLowerCase()
                        .substring(0, query.length),
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: suggestionList[index]["name"]
                              .toLowerCase()
                              .substring(query.length),
                          style: TextStyle(color: Colors.grey))
                    ]),
              ),
            ),
        itemCount: suggestionList.length);
    throw UnimplementedError();
  }
}
