import 'dart:async';

import 'package:Chatify/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_360/video_player_360.dart';

class ThreeSixtyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     "360 View",
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
      body: ThreeSixtyScreen(),
    );
  }
}

class ThreeSixtyScreen extends StatefulWidget {
  @override
  State createState() => ThreeSixtyScreenState();
}

class ThreeSixtyScreenState extends State<ThreeSixtyScreen> {
  final picker = ImagePicker();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  showProgress(context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Pick Image'),
            children: <Widget>[],
          );
        });
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              isLoading
                  ? Center(
                      child: Column(
                        children: [
                          Text(
                            '     Please Wait \nPreparing 360 View',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                          circularprogress()
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Open 360 Video',
                            style:
                                TextStyle(color: Colors.white, fontSize: 30)),
                        SizedBox(width: 10,),
                        GestureDetector(
                            onTap: () async {
                              final pickedFile = await picker.getVideo(
                                  source: ImageSource.gallery);
                              if (pickedFile != null) {
                                // showProgress(context);
                                setState(() {
                                  isLoading = true;
                                });

                                MediaInfo mediaInfo =
                                    await VideoCompress.compressVideo(
                                  pickedFile.path,
                                  quality: VideoQuality.LowQuality,
                                  deleteOrigin: false, // It's false by default
                                );
                                setState(() {
                                  isLoading = false;
                                });
                                await VideoPlayer360.playVideoURL(
                                    mediaInfo.path,
                                    radius: 50);

                                // await VideoPlayer360.playVideoURL(
                                //     "https://github.com/stephangopaul/video_samples/blob/master/gb.mp4?raw=true");
                                // await VideoPlayer360.playVideoURL(pickedFile.path);

                              }
                            },
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.white,
                            ))
                      ],
                    )
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        )
      ],
    );
  }
}
