import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewWidget extends StatelessWidget {
  final url;
  PhotoViewWidget(this.url);
  @override
  Widget build(BuildContext context) {
    // final String url = Get.arguments;
    return Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        )
    );
  }
}
