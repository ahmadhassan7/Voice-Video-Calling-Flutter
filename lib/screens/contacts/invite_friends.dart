import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Invitefriends extends StatelessWidget {
  String text = 'https://bimeta.net';
  String subject = 'Join BIMeta Network';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 3,
        // backgroundColor: Colors.white,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => BottomProfile()));
        //   },
        //   icon: Icon(
        //     Icons.arrow_back_ios,
        //     color: Colors.black,
        //   ),
        // ),
        centerTitle: true,
        title: Text(
          "Invite Friends",
          // style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Center(
                  child: Container(
                    child: Text(
                      "Invite to BIMeta",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).accentColor
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Center(
                  child: Container(
                    child: Text(
                      "Send invitation to your friends and family members to join you on BIMeta!",
                      style: TextStyle(
                          fontSize: 18,
                          // fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyText2.color
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 300,
                child: Center(
                  child: Image.asset(
                    'assets/images/icon.png', // App icon image here
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(),
                child: Center(
                  child: Container(
                    child: Text(
                      "Send Invitation",
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText2.color),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Padding(
                padding: EdgeInsets.only(),
                // child: Center(
                child: Container(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          elevation: 0.0,
                          color: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(50))),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.message,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                                Text("TEXT", style: TextStyle(color: Colors.black),)
                              ],
                            ),
                          ),
                          onPressed: _launchURL,
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          elevation: 0.0,
                          color: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(50))),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.share,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                                Text("SHARE", style: TextStyle(color: Colors.black))
                              ],
                            ),
                          ),
                          onPressed: () {
                            final RenderBox box = context.findRenderObject();
                            Share.share(text,
                                subject: subject,
                                sharePositionOrigin:
                                box.localToGlobal(Offset.zero) & box.size);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.only(),
                child: Center(
                  child: Text(
                    "OR COPY YOUR LINK",
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 17),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.only(),
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    selectedTileColor: Colors.white,
                    tileColor: Colors.white,
                    title: Text(
                      'https://bimeta.net',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      // textScaleFactor: 1.5,
                    ),
                    trailing: Text(
                      "COPY",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    onTap: () {
                      Clipboard.setData(new ClipboardData(text: text));
                      _scaffoldKey.currentState.showSnackBar(
                          SnackBar(content: Text("Link Copied to Clipboard")));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_launchURL() async {
  const uri = 'sms:?body=Visit\nhttps://bimeta.net';
  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    // iOS
    const uri = 'sms:?body=Visit\nhttps://bimeta.net';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}