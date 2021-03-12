import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_360/video_player_360.dart';

class ThreeSixtyView extends StatefulWidget {
  ThreeSixtyView({Key key}) : super(key: key);

  @override
  _ThreeSixtyViewState createState() => _ThreeSixtyViewState();
}

class _ThreeSixtyViewState extends State<ThreeSixtyView> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  File videoFile;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Butterfly Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: Column(
        children: <Widget>[
          Visibility(
            visible: _controller != null,
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.done) {
                  // If the VideoPlayerController has finished initialization, use
                  // the data it provides to limit the aspect ratio of the video.
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(_controller),
                  );
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          RaisedButton(
            child: Text("Video"),
            onPressed: () {
              getVideo();
            },
          ),
        ],
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future getVideo() async {
    Future<File> _videoFile =
    ImagePicker.pickVideo(source: ImageSource.gallery);
    _videoFile.then((file) async {
      // String p = file.path.replaceAll('.jpg', '.mp4');
      MediaInfo mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );
      await VideoPlayer360.playVideoURL(mediaInfo.path);
      setState(()  {
        videoFile = file;

        _controller = VideoPlayerController.file(videoFile);


        // Initialize the controller and store the Future for later use.
        _initializeVideoPlayerFuture = _controller.initialize();

        // Use the controller to loop the video.
        _controller.setLooping(true);
      });


    });
  }
}
// import 'dart:async';
// import 'dart:io';
// import 'package:Chatify/widgets/ProgressWidget.dart';
// import 'package:Chatify/constants.dart';
// import 'package:Chatify/resources/user_state_methods.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_player_360/video_player_360.dart';
//
// class ThreeSixtyView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text(
//       //     "360 View",
//       //     style: TextStyle(
//       //         fontFamily: 'Courgette', letterSpacing: 1.25, fontSize: 24),
//       //   ),
//       //   backgroundColor: kPrimaryColor,
//       //   actions: [
//       //     IconButton(
//       //       icon: FaIcon(FontAwesomeIcons.signOutAlt),
//       //       onPressed: () => UserStateMethods().logoutuser(context),
//       //     )
//       //   ],
//       //   centerTitle: true,
//       // ),
//       body: ThreeSixtyScreen(),
//     );
//   }
// }
//
// class ThreeSixtyScreen extends StatefulWidget {
//   @override
//   State createState() => ThreeSixtyScreenState();
// }
//
// class ThreeSixtyScreenState extends State<ThreeSixtyScreen> {
//   final picker = ImagePicker();
//   VideoPlayerController _controller;
//   Future<void> _initializeVideoPlayerFuture;
//
//   @override
//   void initState() {
//
//     super.initState();
//   }
//
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 30,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//
//                 children: [
//                   Text('Open 360 Video'),
//                   GestureDetector(
//                       onTap: () async {
//                         final pickedFile = await picker.getImage(source: ImageSource.gallery);
//                           if (pickedFile != null) {
//                             _controller = VideoPlayerController.file(
//                               File(pickedFile.path)
//                             );
//
//
//                             _initializeVideoPlayerFuture = _controller.initialize();
//
//
//                            return Center(
//                                 child: AspectRatio(
//                                     aspectRatio: 16 / 9,
//                                     child: Container(
//                                       child: (_controller != null
//                                           ? VideoPlayer(
//                                         _controller,
//                                       )
//                                           : Container()),
//                                     )));
//
//                             // await VideoPlayer360.playVideoURL(
//                             //     "https://github.com/stephangopaul/video_samples/blob/master/gb.mp4?raw=true");
//                             // await VideoPlayer360.playVideoURL(pickedFile.path);
//
//
//                           }
//                       },
//                       child: Icon(Icons.add))
//                 ],
//               )
//             ],
//           ),
//           padding: EdgeInsets.only(left: 15.0, right: 15.0),
//         )
//       ],
//     );
//   }
//
//
// }