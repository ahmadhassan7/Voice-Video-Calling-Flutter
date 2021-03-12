import 'dart:io';

// import 'package:admob_flutter/admob_flutter.dart';

// import 'package:admob_flutter/admob_flutter.dart';

class AdmobServices {
  static final AppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static final appIdIOS = 'ca-app-pub-3940256099942544~1458002511';

  static initAdmob() {
    // Admob.initialize();
  }

  static String getAppId() {
    if (Platform.isAndroid) {
      return AppIdAndroid;
    } else if (Platform.isIOS) {
      return appIdIOS;
    }
  }

  static String getHomeBannerId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
  }

  static String getInterstitialAdId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
  }
}
