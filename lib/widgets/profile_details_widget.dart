import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDetails extends StatelessWidget {
  // DocumentSnapshot snapshot;
  final id;
  final photo;
  final name;

  ProfileDetails(
      // this.snapshot
      {this.id,
      this.name,
      this.photo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 360,
                width: Get.width,
                // color: Colors.red,
                child: Stack(
                  children: [
                    Container(
                      height: 360,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(photo),
                        ),
                      ),
                    ),

                    // FittedBox(
                    //     fit:BoxFit.fill,
                    //     child: Image.network(snapshot.data['photoUrl']),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.keyboard_backspace,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          name,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: Get.width,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Card(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 5,
                  child: Divider(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              StreamBuilder(
                stream: Firestore.instance.collection('Users').document(id).snapshots(),
                builder: (context, snapshot){

                  if(snapshot.hasData){
                    return               Container(
                      width: Get.width,
                      child: Card(
                        // shape: CircleBorder(),
                        color: Theme.of(context).primaryColor,
                        elevation: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About and Contact Details',
                              style: TextStyle(
                                color: Colors.white70,
                                // color: Theme.of(context).textTheme.bodyText2.color,
                              ),
                            ),


                            SizedBox(height: 20,),
                            snapshot.data['aboutText'] != '' ? Text(snapshot?.data['aboutText'] ?? '', style: TextStyle(fontSize: 18),): Container(),
                            SizedBox(height: 10,),
                            snapshot.data['email'] != '' ? Text(('Email:') + snapshot?.data['email'] ?? '', style: TextStyle(fontSize: 20),):Container(),
                            SizedBox(height: 10,),
                            snapshot.data['phone'] != '' ? Text(('Mobile:')+snapshot?.data['phone'] ?? '', style: TextStyle(fontSize: 20),):Container(),
                            SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    );

                  }else{
                    return Container();
                  }



                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
