import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'Screens/SplashScreen.dart';
import 'models/themeStream.dart';
import 'package:callkeep/callkeep.dart';


SharedPreferences prefs;
String wallpaper = '';
const iOSLocalizedLabels = false;

final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false;

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initFirebase();
  prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('wallpaper')) {
    wallpaper = prefs.getString('wallpaper');
  }

  runApp(MyApp());
}
// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//
//   print('backgroundMessage: message => ${message.toString()}');
//   var payload = message['data'];
//   var callerId = payload['caller_id'] as String;
//   var callerNmae = payload['caller_name'] as String;
//   var uuid = payload['uuid'] as String;
//   var hasVideo = payload['has_video'] == "true";
//
//   final callUUID = 'uuid ?? Uuid().v4()';
//   _callKeep.on(CallKeepPerformAnswerCallAction(),
//           (CallKeepPerformAnswerCallAction event) {
//         print(
//             'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
//         _callKeep.startCall(event.callUUID, callerId, callerNmae);
//
//         Timer(const Duration(seconds: 1), () {
//           print(
//               '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerNmae');
//           _callKeep.setCurrentCallActive(callUUID);
//         });
//         //_callKeep.endCall(event.callUUID);
//       });
//
//   _callKeep.on(CallKeepPerformEndCallAction(),
//           (CallKeepPerformEndCallAction event) {
//         print('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
//       });
//   if (!_callKeepInited) {
//     _callKeep.setup(<String, dynamic>{
//       'ios': {
//         'appName': 'CallKeepDemo',
//       },
//       'android': {
//         'alertTitle': 'Permissions required',
//         'alertDescription':
//         'This application needs to access your phone accounts',
//         'cancelButton': 'Cancel',
//         'okButton': 'ok',
//       },
//     });
//     _callKeepInited = true;
//   }
//
//   _callKeep.displayIncomingCall('callUUID', 'callerId',
//       localizedCallerName: 'callerNmae', hasVideo: false);
//   _callKeep.backToForeground();
//   /*
//
//   if (message.containsKey('data')) {
//     // Handle data message
//     final dynamic data = message['data'];
//   }
//
//   if (message.containsKey('notification')) {
//     // Handle notification message
//     final dynamic notification = message['notification'];
//     print('notification => ${notification.toString()}');
//   }
//
//   // Or do other work.
//   */
//   return null;
// }

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  static ThemeStream themeStream = ThemeStream();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool themeMode;
  int primaryColor;
  int scaffoldBackgroundColor;
  int accentColor;
  int secondaryColor;

  bool prefsExists = true;

  @override
  void initState() {
    // _client = AgoraRtmClient.createInstance(APPID);

    // if (prefs.containsKey('themeMode')) {
    //   // prefsExists = true;
    //   themeMode = prefs.getBool("themeMode");
    //   primaryColor = prefs.getInt("primaryColor") ?? Colors.cyan.shade900.value;
    //   scaffoldBackgroundColor =
    //       prefs.getInt("scaffoldBackgroundColor") ?? Colors.cyan.shade900.value;
    //   accentColor = prefs.getInt("accentColor") ?? Colors.cyan.value;
    //   primaryColor = prefs.getInt("primaryColor") ?? Colors.white.value;
    //   // primaryColor = Colors.cyan.value;
    // }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MyApp.themeStream.darkThemeEnabled,
      initialData: {'darkTheme': prefs.containsKey('darkTheme') ? prefs.getBool('darkTheme') : false},
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BiMeta',
          theme: (snapshot.data['darkTheme'] ?? false)
              ? ThemeData.dark()
              : ThemeData(
                  primaryColor: Color(
                      prefs.containsKey('primaryColor') ? prefs.getInt('primaryColor') : Colors.cyan.shade900.value),
                  scaffoldBackgroundColor: Color(prefs.containsKey('scaffoldBackgroundColor')
                      ? prefs.getInt('scaffoldBackgroundColor')
                      : Colors.cyan.shade900.value),
                  accentColor:
                      Color(prefs.containsKey('accentColor') ? prefs.getInt('accentColor') : Colors.cyan.value),
                  dialogBackgroundColor: Color(
                      prefs.containsKey('primaryColor') ? prefs.getInt('primaryColor') : Colors.cyan.shade900.value),
                  popupMenuTheme: PopupMenuThemeData(
                    color: Color(
                        prefs.containsKey('primaryColor') ? prefs.getInt('primaryColor') : Colors.cyan.shade900.value),
                    textStyle: TextStyle(
                      color: Color(
                          prefs.containsKey('primaryTextColor') ? prefs.getInt('primaryTextColor') : Colors.cyan.value),
                    ),
                  ),
                  textTheme: TextTheme(
                    bodyText1:
                        // TextStyle(color: Color(prefs.getInt('primaryTextColor') ??  Colors.cyan.value)),
                        TextStyle(
                            color: Color(
                      prefs.containsKey('primaryTextColor') ? prefs.getInt('primaryTextColor') : Colors.cyan.value,
                    )),
                    bodyText2: TextStyle(
                        color: Color(prefs.containsKey('secondaryTextColor')
                            ? prefs.getInt('secondaryTextColor')
                            : Colors.cyan.value)),
                  ),

                  // backgroundColor: Colors.cyan.shade50,
                  // appBarTheme: AppBarTheme(
                  //   color: Colors.cyan.shade50,
                  // ),
                  // primarySwatch: Colors.cyan[300],
                  // primaryColor:,

                  // primaryColor: kPrimaryColor,
                  // scaffoldBackgroundColor: Colors.white,
                ),
          home: SplashScreen(),
        );
      },
    );
  }
}
Map<String, Call> calls = {};

void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
  // var callUUID = event.callUUID;
  // var number = event.handle;
  var callUUID = '88888';
  var number = '999999';
  print('[displayIncomingCall] $callUUID number: $number');

    calls[callUUID] = Call(number);

}
Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
  final String callUUID = event.callUUID;
  final String number = calls[callUUID].number;
  print('[answerCall] $callUUID, number: $number');

  _callKeep.startCall(event.callUUID, number, number);
  Timer(const Duration(seconds: 1), () {
    print('[setCurrentCallActive] $callUUID, number: $number');
    _callKeep.setCurrentCallActive(callUUID);
  });
}
Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
  print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
}
Future<void> didReceiveStartCallAction(
    CallKeepDidReceiveStartCallAction event) async {
  if (event.handle == null) {
    // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
    return;
  }
  final String callUUID = event.callUUID ?? 'newUUID()';
    calls[callUUID] = Call(event.handle);
  print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

  _callKeep.startCall(callUUID, event.handle, event.handle);

  Timer(const Duration(seconds: 1), () {
    print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
    _callKeep.setCurrentCallActive(callUUID);
  });
}
void setCallHeld(String callUUID, bool held) {
    calls[callUUID].held = held;
}

Future<void> didToggleHoldCallAction(
    CallKeepDidToggleHoldAction event) async {
  final String number = calls[event.callUUID].number;
  print(
      '[didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');

  setCallHeld(event.callUUID, event.hold);
}
void setCallMuted(String callUUID, bool muted) {
    calls[callUUID].muted = muted;
}

Future<void> didPerformSetMutedCallAction(
    CallKeepDidPerformSetMutedCallAction event) async {
  final String number = calls[event.callUUID].number;
  print(
      '[didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');

  setCallMuted(event.callUUID, event.muted);
}
void removeCall(String callUUID) {
    calls.remove(callUUID);
}

Future<void> endCall(CallKeepPerformEndCallAction event) async {
  print('endCall: ${event.callUUID}');
  removeCall(event.callUUID);
}
void onPushKitToken(CallKeepPushKitToken event) {
  print('[onPushKitToken] token => ${event.token}');
}
Future<void> displayIncomingCall(String number) async {
  // final String callUUID = 'newUUID()';
  final String callUUID = '999999';
    calls[callUUID] = Call('88888888');
  print('Display incoming call now');
  final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();
  // if (!hasPhoneAccount) {
  //   await _callKeep.hasDefaultPhoneAccount(Get.context , <String, dynamic>{
  //     'alertTitle': 'Permissions required',
  //     'alertDescription':
  //     'This application needs to access your phone accounts',
  //     'cancelButton': 'Cancel',
  //     'okButton': 'ok',
  //   });
  // }

  _callKeep.displayIncomingCall(callUUID, 'number',
      handleType: 'number', hasVideo: false);
}

void initFirebase() {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
  _callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
  _callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
  _callKeep.on(
      CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
  _callKeep.on(CallKeepDidToggleHoldAction(), didToggleHoldCallAction);
  _callKeep.on(
      CallKeepDidPerformSetMutedCallAction(), didPerformSetMutedCallAction);
  _callKeep.on(CallKeepPerformEndCallAction(), endCall);
  _callKeep.on(CallKeepPushKitToken(), onPushKitToken);

  _callKeep.setup(<String, dynamic>{
    'ios': {
      'appName': 'CallKeepDemo',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
      'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
    },
  });

  if (Platform.isAndroid) {
    //if (isIOS) iOS_Permission();
    //  _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.getToken().then((token) {
      print('[FCM] token => ' + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        if (message.containsKey('data')) {
          // Handle data message
          final dynamic data = message['data'];
          var number = data['body'] as String;
          // await displayIncomingCall('number');
        }
      },
      // onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        print('onLaunch: $message');
        print('onLaunch: $message');
        print('onLaunch: $message');
        print('onLaunch: $message');
        print('onLaunch: $message');
        // await displayIncomingCall('number');

      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        print('onResume: $message');
        print('onResume: $message');
        print('onResume: $message');
        print('onResume: $message');
        // await displayIncomingCall('number');

      },
    );
  }
}

