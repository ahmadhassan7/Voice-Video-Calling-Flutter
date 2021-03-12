import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';

class StoryPlayerPage extends StatefulWidget {
  List<DocumentSnapshot> documents;
  StoryPlayerPage(this.documents);


  @override
  _StoryPlayerPageState createState() => _StoryPlayerPageState();
}

class _StoryPlayerPageState extends State<StoryPlayerPage> {
  final controller = StoryController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(context) {
    List<StoryItem> storyItems = List();
    print(widget.documents);
    // Navigator.push(context,
    //     MaterialPageRoute(builder: (context) => StoryPlayerPage()));
    widget.documents.map((e) {
      if(e['type'] == 'image'){
        storyItems.add(StoryItem.pageImage(url:e['url'],duration: Duration(seconds: 5),controller: controller));
      }else{
        storyItems.add(StoryItem.pageVideo(e['url'],controller: controller,duration: Duration(seconds: e['duration'])));
      }
    }).toList();

    print(storyItems);

    // final List<Moment> moments = Get.arguments;


    // final Moment moment = Get.arguments;
    // List<StoryItem> storyItems = [
    //   moment.type == 'image'
    //       ? StoryItem.pageImage(url:moment.url,duration: 5.seconds,controller: controller)
    //       : StoryItem.pageVideo(moment.url,controller: controller,)
    // ];
    return StoryView(
        storyItems: storyItems,
        controller: controller,
        // pass controller here too
        repeat: true,
        // should the stories be slid forever
        onStoryShow: (s) {
          notifyServer(s);
        },
        onComplete: () {},
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        } // To disable vertical swipe gestures, ignore this parameter.
        // Preferrably for inline story view.
        );
  }

  void notifyServer(StoryItem s) {
  }
}
