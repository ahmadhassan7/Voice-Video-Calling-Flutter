import 'package:flutter/material.dart';
import 'package:Chatify/screens/Login/login_screen.dart';
import 'package:Chatify/screens/Signup/signup_screen.dart';
import 'package:Chatify/screens/Welcome/components/background.dart';
import 'package:Chatify/components/rounded_button.dart';
import 'package:Chatify/constants.dart';
import 'package:flutter_svg/svg.dart';

import 'package:shared_preferences/shared_preferences.dart';


class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  SharedPreferences preferences;

  void initState() {
    super.initState();
    //isSignedIn();
  }

  // void isSignedIn() async {
  //   preferences = await SharedPreferences.getInstance();

  //   await FirebaseAuth.instance.currentUser().then((user) {
  //     if (user != null) {
  //       Route route = MaterialPageRoute(
  //           builder: (c) =>
  //               HomeScreen(currentuserid: preferences.getString("uid")));
  //       Navigator.pushReplacement(context, route);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Text(
              //   "WELCOME TO CHAT APP",
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),

              //////////
              /////////
              Image.asset('assets/logo.png', height: 150, width: 200),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  text: "BIMeta ",
                  style: TextStyle(
                      color: Colors.cyan[200],
                      // color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text: "Chatting",
                      style: TextStyle(color: Colors.cyan[700]),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),


              //////////////////
              //////////




              // SizedBox(height: size.height * 0.05),
              // SvgPicture.asset(
              //   "assets/icons/chat.svg",
              //   height: size.height * 0.45,
              // ),
              // SizedBox(height: size.height * 0.05),
              RoundedButton(
                child: Text(
                  "LOGIN",
                  // style: TextStyle(color: Colors.cyan[700]),
                ),
                  color: Colors.cyan[700],
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginScreen();
                      },
                    ),
                  );
                },
              ),
              RoundedButton(
                child: Text(
                  "SIGN UP",
                  style: TextStyle(color: Colors.black),
                ),
                color: Colors.cyan[200],
                textColor: Colors.black,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
              // Padding(
              //   padding: EdgeInsets.all(1.0),
              //   child: circularprogress(),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
