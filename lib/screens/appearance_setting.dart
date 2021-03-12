import 'package:Chatify/main.dart';
import 'package:Chatify/models/themeStream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AppearanceSetting extends StatefulWidget {
  @override
  _AppearanceSettingState createState() => _AppearanceSettingState();
}

class _AppearanceSettingState extends State<AppearanceSetting> {


  bool isSwitchOn = false;
  ThemeStream themeStream = ThemeStream();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: ThemeMode.light == ThemeMode.system ? Theme.of(context).scaffoldBackgroundColor: ThemeData.dark().backgroundColor,
        appBar: AppBar(
          title: Text('Appearance Setting'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right:10.0),
              child: GestureDetector(
                  onTap: () async {
                    // prefs.setBool('darkTheme', false);
                    // // prefs.setBool('themeMode', false);
                    // prefs.setInt('primaryColor', Colors.cyan.shade900.value);
                    // prefs.setInt('scaffoldBackgroundColor', Colors.cyan.shade900.value);
                    // prefs.setInt('accentColor', Colors.cyan.value);
                    // // prefs.setInt('primaryColor', Colors.white.value);
                    // prefs.setInt('secondaryTextColor', Colors.white.value);
                    // prefs.setInt('primaryTextColor', Colors.white.value);
                    await prefs.remove('primaryColor');
                    await prefs.remove('scaffoldBackgroundColor');
                    await prefs.remove('primaryColor');
                    await prefs.remove('accentColor');
                    await prefs.remove('secondaryTextColor');
                    await prefs.remove('primaryTextColor');

                    setState(() {
                      MyApp.themeStream.changeTheme({'darkTheme': false});

                    });



                  },

                  child: Icon(Icons.refresh)),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'Base Theme',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2.color
                  ),
                ),
              ),
              ListTile(
                title:
                    Text('Dark Theme', style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                subtitle: Text('Apply a dark theme throughout the app',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                trailing: Switch(
                  value: prefs.getBool('darkTheme') ?? false,
                  onChanged: (value) {

                      // themeStream.changeTheme(value);

                      setState(() {
                        isSwitchOn = value;
                        prefs.setBool('darkTheme', value);

                        MyApp.themeStream.changeTheme({'darkTheme':value});
                      });
                      // isSwitched=value;
                      // print(isSwitched);

                  },
                  // activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.white,
                ),
              ),

              ///////////////////

              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  'ATE Color',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText2.color,
                  ),
                ),
              ),
              ListTile(
                // contentPadding: EdgeInsets.all(value),
                onTap: () {
                  _showDialogPrimaryColor(context);
                },
                title: Text('Primary Color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                    )),
                subtitle: Text('Change the primary theme color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                      color: Theme.of(context).primaryColor,

                      shape: BoxShape.circle
                  ),
                  width: 30,
                  height: 30,
                ),
              ),
              ///////////////////////
              ///////////////////

              ListTile(
                onTap: () {
                  _showDialogAccentColor(context);
                },
                title:
                    Text('Accent Color', style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                subtitle: Text('Change the accent theme color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                      color: Theme.of(context).accentColor,

                      shape: BoxShape.circle
                  ),
                  width: 30,
                  height: 30,
                ),
              ),
              ListTile(
                // contentPadding: EdgeInsets.all(value),
                onTap: () {
                  _showDialogScaffoldBackgroundColor(context);
                },
                title: Text('Page Background Color',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                    )),
                subtitle: Text('Change Page Background color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                      color: Theme.of(context).scaffoldBackgroundColor,

                      shape: BoxShape.circle
                  ),
                  width: 30,
                  height: 30,
                ),
              ),

              ///////////////////////

              ListTile(
                // contentPadding: EdgeInsets.all(value),
                onTap: () {
                  _showDialogPrimaryTextColor(context);
                },
                title: Text('Primary Text Color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                subtitle: Text('Change the primary text color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                trailing: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70),
                      color: Theme.of(context).textTheme.bodyText1.color,

                      shape: BoxShape.circle
                  ),
                  width: 30,
                  height: 30,
                ),
              ),

              ListTile(
                // contentPadding: EdgeInsets.all(value),
                onTap: () {
                  _showDialogSecorndaryTextColor(context);
                },
                title: Text('Secondary Text Color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                subtitle: Text('Change the Secondary text color',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color
                    )),
                trailing: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70),
                      color: Theme.of(context).textTheme.bodyText2.color,

                      shape: BoxShape.circle
                  ),
                  width: 30,
                  height: 30,
                ),
              ),///////////////////

              // Padding(
              //   padding: const EdgeInsets.only(left: 15.0),
              //   child: Text(
              //     'System UI Color',
              //     style: TextStyle(
              //         color: Theme.of(context).textTheme.bodyText2.color),
              //   ),
              // ),
              // ListTile(
              //   // contentPadding: EdgeInsets.all(value),
              //   onTap: () {
              //     _showAddMomentDialog(context);
              //   },
              //   title: Text('Colored status Bar Color',
              //       style: TextStyle(color: Colors.white60)),
              //   subtitle: Text('Toggle Status Bar Color',
              //       style: TextStyle(color: Colors.white60)),
              //   trailing: Switch(
              //     value: true,
              //     onChanged: (value){},
              //     // activeTrackColor: Colors.lightGreenAccent,
              //     activeColor: Colors.white,
              //   ),
              // ),
              ///////////////////////
              // ListTile(
              //   // contentPadding: EdgeInsets.all(value),
              //   onTap: () {
              //     _showAddMomentDialog(context);
              //   },
              //   title: Text('Colored Navigation Bar Color',
              //       style: TextStyle(color: Colors.white60)),
              //   subtitle: Text('Toggle Navigation bar coloring',
              //       style: TextStyle(color: Colors.white60)),
              //   trailing: Switch(
              //     value: true,
              //     onChanged: (value) {
              //       setState(() {
              //         // isSwitched=value;
              //         // print(isSwitched);
              //       });
              //     },
              //     // activeTrackColor: Colors.lightGreenAccent,
              //     activeColor: Colors.white,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _showDialogPrimaryTextColor(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(child: const Text('Pick Color')),
            children: <Widget>[
              ColorPicker(
                // paletteType: PaletteT,

                displayThumbColor: true,
                // paletteType: PaletteType.hsv,
                pickerColor: Theme.of(context).textTheme.bodyText1.color,
                onColorChanged: (color) {

                  prefs.setInt('primaryTextColor', color.value);
                  MyApp.themeStream.changeTheme({'darkTheme': prefs.getBool('themeMode') ?? false});

                },
                // showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
              RaisedButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<void> _showDialogAccentColor(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(child: const Text('Pick Color')),
            children: <Widget>[
              ColorPicker(
                // paletteType: PaletteT,

                displayThumbColor: true,
                // paletteType: PaletteType.hsv,
                pickerColor: Theme.of(context).accentColor,
                onColorChanged: (color) {

                  // prefs.setInt('primaryColor', color.value);
                  prefs.setInt('accentColor', color.value);
                  MyApp.themeStream.changeTheme({'darkTheme': prefs.getBool('themeMode') ?? false});

                },
                // showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
              RaisedButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
    // await showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return SimpleDialog(
    //         title: Center(child: const Text('Pick Color')),
    //         children: <Widget>[
    //           ColorPicker(
    //             // paletteType: PaletteT,
    //
    //             displayThumbColor: true,
    //             // paletteType: PaletteType.hsv,
    //             pickerColor: Theme.of(context).primaryColor,
    //             onColorChanged: (color) {
    //
    //               prefs.setInt('accentColor', color.value);
    //               MyApp.themeStream.changeTheme({'darkTheme': prefs.getBool('themeMode') ?? false});
    //
    //             },
    //             // showLabel: true,
    //             pickerAreaHeightPercent: 0.8,
    //           ),
    //           RaisedButton(
    //               child: Text('Done'),
    //               onPressed: () {
    //                 Navigator.pop(context);
    //               })
    //         ],
    //       );
    //     });
  }
  Future<void> _showDialogScaffoldBackgroundColor(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(child: const Text('Pick Color')),
            children: <Widget>[
              ColorPicker(
                // paletteType: PaletteT,

                displayThumbColor: true,
                // paletteType: PaletteType.hsv,
                pickerColor: Theme.of(context).scaffoldBackgroundColor,
                onColorChanged: (color) {

                  prefs.setInt('scaffoldBackgroundColor', color.value);
                  MyApp.themeStream.changeTheme({'darkTheme': prefs.getBool('themeMode') ?? false});

                },
                // showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
              RaisedButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<void> _showDialogPrimaryColor(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(child: const Text('Pick Color')),
            children: <Widget>[
              ColorPicker(
                // paletteType: PaletteT,

                displayThumbColor: true,
                // paletteType: PaletteType.hsv,
                pickerColor: Theme.of(context).primaryColor,
                onColorChanged: (color) {

                  prefs.setInt('primaryColor', color.value);
                  MyApp.themeStream.changeTheme({'darkTheme': prefs.getBool('themeMode') ?? false});

                },
                // showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
              RaisedButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<void> _showDialogSecorndaryTextColor(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Center(child: const Text('Pick Color')),
            children: <Widget>[
              ColorPicker(

                // paletteType: PaletteT,

                displayThumbColor: true,
                // paletteType: PaletteType.hsv,
                pickerColor: Theme.of(context).textTheme.bodyText2.color,
                onColorChanged: (color) {

                  prefs.setInt('secondaryTextColor', color.value);
                  MyApp.themeStream.changeTheme({'darkTheme': prefs.getBool('themeMode') ?? false});

                },
                // showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
              RaisedButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}
