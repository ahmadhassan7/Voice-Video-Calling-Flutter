import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupProfileDetails extends StatefulWidget {
  // DocumentSnapshot snapshot;
  final id;
  final photo;
  final name;

  GroupProfileDetails(
      // this.snapshot
      {this.id,
      this.name,
      this.photo});

  @override
  _GroupProfileDetailsState createState() => _GroupProfileDetailsState();
}

class _GroupProfileDetailsState extends State<GroupProfileDetails> {
  bool edit = false;

  TextEditingController descriptionController = TextEditingController();

  TextEditingController aboutTextController = TextEditingController();

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
                          image: NetworkImage(widget.photo),
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
                          widget.name,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 300,
                      right: 10,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            edit = ! edit;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 25.0,
                          child: new Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
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
                stream: Firestore.instance
                    .collection('Groups')
                    .document(widget.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<String> users = snapshot.data['users'].cast<String>();

                    aboutTextController.text = snapshot?.data['aboutText'] ?? '';
                    descriptionController.text = snapshot?.data['description'] ?? '';
                    return Column(
                      children: [
                        Container(
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
                                  'About and Description',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    // color: Theme.of(context).textTheme.bodyText2.color,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                // snapshot.data['aboutText'] != ''
                                //     ?
                                TextField(

                                  controller: aboutTextController,
                                  enabled: edit,
                                  style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),

                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),

                                      enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.white),
                                )
                                  ),


                                ),
                                // Text(
                                //   snapshot?.data['aboutText'] ?? '',
                                //   style: TextStyle(fontSize: 18),
                                // ),
                                //     : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                                // snapshot.data['email'] != ''
                                //     ?
                                // Text(
                                //   snapshot?.data['email'] ?? '',
                                //   style: TextStyle(fontSize: 20),
                                // ),
                                //     : Container(),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                // snapshot.data['phone'] != ''
                                //     ?
                                // Text(
                                //   snapshot?.data['phone'] ?? '',
                                //   style: TextStyle(fontSize: 20),
                                // ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                TextField(
                                  controller: descriptionController,
                                  enabled: edit,
style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
                                  decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.white),
                                      )



                                  ),


                                ),
                                // Text(
                                //   snapshot?.data['description'] ?? '',
                                //   style: TextStyle(fontSize: 20),
                                // ),
                                //     : Container(),
                                SizedBox(
                                  height: 10,
                                ),

                               !edit ? Container(): Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Container(
                                        child: new RaisedButton(
                                          child: new Text("Update"),
                                          textColor: Colors.white,
                                          color: Colors.green,
                                          onPressed: () {

                                            Firestore.instance.collection('Groups').document(widget.id).updateData(
                                              {
                                                'description':descriptionController.text,
                                                'aboutText': aboutTextController.text
                                              }

                                            ).then((value) {
                                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Groupt Info Updated')));

                                              setState(() {
                                                edit = !edit;
                                              });
                                            });





                                            // setState(() {
                                            //   // _status = true;
                                            //   FocusScope.of(context).requestFocus(new FocusNode());
                                            // });
                                            // updateData();
                                          },
                                          shape: new RoundedRectangleBorder(
                                              borderRadius: new BorderRadius.circular(20.0)),
                                        )),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: Get.width,
                          child: Card(
                            color: Theme.of(context).primaryColor,
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize:MainAxisSize.min,
                              children: [
                                Text('Participants', style: TextStyle(

                                  color: Colors.white70,                                ),),
                                SizedBox(height: 10,),

                                ...users.map((e) {
                                  return StreamBuilder(
                                    stream: Firestore.instance
                                        .collection('Users')
                                        .document(e)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData){

                                        return                                  Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(snapshot.data['name']),
                                        );



                                      }else{
                                        return Container();
                                      }
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),


                      ],
                    );
                  } else {
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
