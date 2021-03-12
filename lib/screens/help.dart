import 'dart:io';

import 'package:Chatify/screens/appearance_setting.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker_saver/image_picker_saver.dart';

import '../main.dart';
import 'AccountSettings/AccountSettingsPage.dart';


class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => Bimeta()),
              // );
            }),
        title: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 15),
        child: ListView(
          children: <Widget>[
            ListTile(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Settings()),
                );
              },
              leading: Icon(
                Icons.person,
                color: Theme.of(context).textTheme.bodyText1.color,
                // color: Theme.of(context).primaryColor,
              ),
              title: Text("Profile", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color,
              ),),
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.notification_important,
            //     color: Theme.of(context).textTheme.bodyText1.color,
            //
            //     // color: Theme.of(context).primaryColor,
            //   ),
            //   title: Text("Notification", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color,
            //   ),),
            //   // subtitle: Text("Questions? Need help?"),
            // ),
            // ListTile(
            //   leading: Icon(
            //     Icons.chat,
            //     color: Theme.of(context).textTheme.bodyText1.color,
            //
            //     // color: Theme.of(context).primaryColor,
            //   ),
            //   title: Text("Chat", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color,
            //   ),),
            // ),
            ListTile(
              onTap: () async {
                // final pickedFile = await picker.getImage(source: ImageSource.gallery);
                // setState(() {
                //   if (pickedFile != null) {
                //     imageFileAvatar = File(pickedFile.path);
                //     isLoading = true;
                //   }
                // });


                final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                      prefs.setString('wallpaper',file.path);
                    }
                // final f = await File(pickedFile.path).readAsBytes();
                // var filePath = await ImagePickerSaver.saveFile(
                //     fileData: f);
                //
                // var savedFile= File.fromUri(Uri.file(filePath));
                // prefs.setString('wallpaper',savedFile.path);


                // final d = ImagePickerSaver.pickImage(source: ImageSource.gallery).then((value) async {
                //
                //   var filePath = await ImagePickerSaver.saveFile(
                //           fileData: await File(value.path).readAsBytes());
                //
                //   prefs.setString('wallpaper',filePath);
                //   print(filePath);
                //   print(filePath);
                //
                // });


                // final p = await ImagePickerSaver.pickImage(source: ImageSource.gallery);
                // final f = await File(p.path).readAsBytes();
                // var filePath = await ImagePickerSaver.saveFile(
                //         fileData: f);
                // var savedFile= File.fromUri(Uri.file(filePath));
                // prefs.setString('wallpaper',savedFile.path);




                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AppearanceSetting()));
              },
              leading: Icon(
                Icons.wallpaper,
                color: Theme.of(context).textTheme.bodyText1.color,

                // color: Theme.of(context).primaryColor,
              ),
              title: Text("Wallpaper", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color,
              ),),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AppearanceSetting()));
              },
              leading: Icon(
                Icons.settings_display,
                color: Theme.of(context).textTheme.bodyText1.color,

                // color: Theme.of(context).primaryColor,
              ),
              title: Text("Appearance", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color,
              ),),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.info,
                color: Theme.of(context).textTheme.bodyText1.color,

                // color: Theme.of(context).primaryColor,
              ),
              title: Text("Terms of Service", style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color,
              ),),
            ),
          ],
        ),
      ),
    );
  }
}
