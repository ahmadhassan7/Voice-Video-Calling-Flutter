import 'package:Chatify/screens/HomeScreen.dart';
import 'package:Chatify/screens/Login/login_screen.dart';
import 'package:Chatify/widgets/Progresswidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  static const kPrimaryColor = Color(0xFF6F35A5);
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging();
  String fcmToken;
  TextEditingController nameEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController phoneNumberEdittingController = new TextEditingController();
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'NG');
  TextEditingController verifyCodeEdittingController =
      new TextEditingController();
  SharedPreferences preferences;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedin = false;
  bool isloading = false;
  bool _passwordVisible = true;
  bool _signUpWithEmail = true;
  bool codeSent = false;
  String _verificationId;

  @override
  void initState() {
    super.initState();
    // _passwordVisible = false;

    _messaging.getToken().then((value) {
      fcmToken = value;
    });
  }

  void _registerWithEmail() async {
    this.setState(() {
      isloading = true;
    });
    preferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;

    await _auth
        .createUserWithEmailAndPassword(
            email: emailEditingController.text.trim(),
            password: passwordEditingController.text.trim())
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((err) {
      this.setState(() {
        isloading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(err.message)));
    });

    if (firebaseUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection("Users")
          .where("uid", isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        Firestore.instance
            .collection("Users")
            .document(firebaseUser.uid)
            .setData({
          "uid": firebaseUser.uid,
          "email": firebaseUser.email,
          "name": nameEditingController.text,
          "aboutText": 'Available',
          "phone": '',
          "photoUrl": defaultPhotoUrl,
          "isPaidUser": false,
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "state": 1,
          "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
          "fcmToken": fcmToken
        });
        FirebaseUser currentuser = firebaseUser;
        await preferences.setString("uid", currentuser.uid);
        await preferences.setString("name", nameEditingController.text);
        await preferences.setString("photo", defaultPhotoUrl);
        await preferences.setString("email", currentuser.email);
        await preferences.setString("aboutText", '');
        await preferences.setBool("isPaidUser", false);
      } else {
        // FirebaseUser currentuser = firebaseUser;
        await preferences.setString("uid", documents[0]["uid"]);
        await preferences.setString("name", documents[0]["name"]);
        await preferences.setString("photo", documents[0]["photoUrl"]);
        await preferences.setString("email", documents[0]["email"]);
        await preferences.setString("aboutText", '');
        await preferences.setBool("isPaidUser", false);
      }

      this.setState(() {
        isloading = false;
      });
      Navigator.pop(context);
      Route route = MaterialPageRoute(
          builder: (c) => HomeScreen(
                currentuserid: firebaseUser.uid,
              ));
      Navigator.pushReplacement(context, route);
    } else {
      this.setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(msg: "Sign up Failed");
    }
  }
  _signInWithCredential(_phoneAuthCredential) async {
    preferences =
    await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;
    try {
      await FirebaseAuth.instance
          .signInWithCredential(
          _phoneAuthCredential)
          .then((AuthResult authRes) {
        firebaseUser = authRes.user;
        // print(authRes.toString());
      });
      if (firebaseUser != null) {
        final QuerySnapshot result =
            await Firestore.instance
            .collection("Users")
            .where("uid",
            isEqualTo: firebaseUser.uid)
            .getDocuments();

        final List<DocumentSnapshot> documents =
            result.documents;
        if (documents.length == 0) {
          Firestore.instance
              .collection("Users")
              .document(firebaseUser.uid)
              .setData({
            "uid": firebaseUser.uid,
            "email": '',
            "name": nameEditingController.text,
            "phone": phoneNumberEdittingController
                .text,
            "photoUrl": defaultPhotoUrl,
            "aboutText": 'Available',
            "isPaidUser": false,
            "createdAt": DateTime.now()
                .millisecondsSinceEpoch
                .toString(),
            "state": 1,
            "lastSeen": DateTime.now()
                .millisecondsSinceEpoch
                .toString(),
            "fcmToken": fcmToken
          });

          FirebaseUser currentuser = firebaseUser;
          await preferences.setString(
              "uid", currentuser.uid);
          await preferences.setString(
              "name", nameEditingController.text);
          await preferences.setString(
              "photo", defaultPhotoUrl);
          await preferences.setString(
              "email", currentuser.email);
          await preferences.setString(
              "aboutText", '');
          await preferences.setString("phone",
              phoneNumberEdittingController.text);
          await preferences.setBool(
              "isPaidUser", false);
        } else {
          // FirebaseUser currentuser = firebaseUser;
          await preferences.setString(
              "uid", documents[0]["uid"]);
          await preferences.setString(
              "name", documents[0]["name"]);
          await preferences.setString(
              "photo", documents[0]["photoUrl"]);
          await preferences.setString(
              "email", documents[0]["email"]);
          await preferences.setString(
              "phone", documents[0]["phone"]);
          await preferences.setString(
              "aboutText", '');
          await preferences.setBool(
              "isPaidUser",  documents[0]["isPaidUser"]);
        }

        this.setState(() {
          isloading = false;
        });
        Navigator.pop(context);
        Route route = MaterialPageRoute(
            builder: (c) => HomeScreen(
              currentuserid: firebaseUser.uid,
            ));
        Navigator.pushReplacement(context, route);
      } else {
        this.setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: "Sign up Failed");
      }
    } catch (e) {
      print(e.toString());
    }




  }

  void _registerWithPhone() async {

    preferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;
    setState(() {
      isloading = true;

    });
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumberEdittingController.text.trim(),
      verificationCompleted: (credential) {

        _signInWithCredential(credential);
        // print(credential);
        // print(credential);
        // print(credential);
      },
      timeout: Duration(milliseconds: 10000),
      verificationFailed: (e) {
        print('error sign up');
        setState(() {
          isloading = false;

        });
      },
      codeSent: (verificationId, [int code]) {
        print('codeSent');

        setState(() {
          codeSent = true;
          isloading = true;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print(verificationId);
      },
    );

    print('credential');

    // if (firebaseUser != null) {
    //   final QuerySnapshot result = await Firestore.instance
    //       .collection("Users")
    //       .where("uid", isEqualTo: firebaseUser.uid)
    //       .getDocuments();
    //
    //   final List<DocumentSnapshot> documents = result.documents;
    //   if (documents.length == 0) {
    //     Firestore.instance
    //         .collection("Users")
    //         .document(firebaseUser.uid)
    //         .setData({
    //       "uid": firebaseUser.uid,
    //       "email": firebaseUser.email,
    //       "name": nameEditingController.text,
    //       "phone": '',
    //       "photoUrl": defaultPhotoUrl,
    //       "isPaidUser": false,
    //       "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
    //       "state": 1,
    //       "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
    //       "fcmToken": fcmToken
    //     });
    //     FirebaseUser currentuser = firebaseUser;
    //     await preferences.setString("uid", currentuser.uid);
    //     await preferences.setString("name", nameEditingController.text);
    //     await preferences.setString("photo", defaultPhotoUrl);
    //     await preferences.setString("email", currentuser.email);
    //     await preferences.setBool("isPaidUser", false);
    //   } else {
    //     // FirebaseUser currentuser = firebaseUser;
    //     await preferences.setString("uid", documents[0]["uid"]);
    //     await preferences.setString("name", documents[0]["name"]);
    //     await preferences.setString("photo", documents[0]["photoUrl"]);
    //     await preferences.setString("email", documents[0]["email"]);
    //     await preferences.setBool("isPaidUser", false);
    //   }
    //
    //   this.setState(() {
    //     isloading = false;
    //   });
    //   Navigator.pop(context);
    //   Route route = MaterialPageRoute(
    //       builder: (c) => HomeScreen(
    //             currentuserid: firebaseUser.uid,
    //           ));
    //   Navigator.pushReplacement(context, route);
    // } else {
    //   this.setState(() {
    //     isloading = false;
    //   });
    //   Fluttertoast.showToast(msg: "Sign up Failed");
    // }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formkey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Text(
                    //   "SIGNUP",
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    Image.asset('assets/logo.png', height: 150, width: 200),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: "BIMeta ",
                        style: TextStyle(
                            color: Colors.cyan[300],
                            fontSize: 40,
                            fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: "Chatting",
                            style: TextStyle(
                              color: Colors.cyan[700],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      enabled: !codeSent,

                      controller: nameEditingController,

                      // obscureText: _passwordVisible,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: "Your Name",
                        prefixIcon: Icon(
                          Icons.person,
                          size: 22,
                          color: Colors.white,
                        ),
                        filled: true,
                        //Dolgunluğu sağlıyor

                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        focusColor: Colors.white,
                      ),
                        validator: (emailValue) {
                          if (emailValue.isEmpty) {
                            return 'Please Enter Name';
                          }

                          // return true;
                        }
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    !_signUpWithEmail
                        ? Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.white)
                            // ),
                            child: InternationalPhoneNumberInput(
                              textStyle: TextStyle(color: Colors.white70),

                              isEnabled: !codeSent,
                              inputDecoration: InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: Icon(
                                  Icons.phone,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                filled: true,
                                //Dolgunluğu sağlıyor
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                focusColor: Colors.white,
                              ),
                              onInputChanged: (PhoneNumber number) {
                                print(number.phoneNumber);
                              },
                              onInputValidated: (bool value) {
                                print(value);
                              },
                              selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                              ),
                              ignoreBlank: true,
                              autoValidateMode: AutovalidateMode.disabled,
                              selectorTextStyle: TextStyle(color: Colors.black),
                              initialValue: number,
                              textFieldController:
                                  phoneNumberEdittingController,
                              formatInput: false,
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              inputBorder: OutlineInputBorder(),
                              onSaved: (PhoneNumber number) {
                                print('On Saved: $number');
                              },
                            ),
                          )
                        : TextFormField(
                            controller: emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            // obscureText: _passwordVisible,
                            validator: (emailValue) {
                              if (emailValue.isEmpty) {
                                return 'This field is mandatory';
                              }

                              String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                                  "\\@" +
                                  "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                                  "(" +
                                  "\\." +
                                  "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                                  ")+";
                              RegExp regExp = new RegExp(p);

                              if (regExp.hasMatch(emailValue)) {
                                // So, the email is valid
                                return null;
                              }

                              return 'This is not a valid email';
                            },
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email,
                                size: 22,
                                color: Colors.white,
                              ),
                              filled: true,
                              //Dolgunluğu sağlıyor
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              focusColor: Colors.white,
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    !codeSent
                        ? Container()
                        : TextFormField(
                            controller: verifyCodeEdittingController,

                            // obscureText: _passwordVisible,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: "Enter Code (OTP)",
                              prefixIcon: Icon(
                                Icons.vpn_key,
                                size: 22,
                                color: Colors.white,
                              ),
                              filled: true,
                              //Dolgunluğu sağlıyor
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              focusColor: Colors.white,
                            ),
                          ),

                    _signUpWithEmail
                        ? TextFormField(
                            controller: passwordEditingController,
                            // keyboardType: TextInputType.emailAddress,
                            obscureText: _passwordVisible,
                            validator: (pwValue) {
                              if (pwValue.isEmpty) {
                                return 'This field is mandatory';
                              }
                              if (pwValue.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                    !_passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.cyan[700]),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                size: 22,
                                color: Colors.white,
                              ),
                              filled: true,
                              //Dolgunluğu sağlıyor
                              enabledBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              focusColor: Colors.white,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    codeSent
                        ? RaisedButton(
                            onPressed: () async {
                              if (!_signUpWithEmail) {
                                if (verifyCodeEdittingController.text != '') {

                                  String smsCode = verifyCodeEdittingController
                                      .text
                                      .toString()
                                      .trim();

                                  /// when used different phoneNumber other than the current (running) device
                                  /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
                                  AuthCredential _phoneAuthCredential =
                                      PhoneAuthProvider.getCredential(
                                          verificationId: _verificationId,
                                          smsCode: smsCode);
                                  this.setState(() {
                                    isloading = true;
                                  });
                                  _signInWithCredential(_phoneAuthCredential);
                                }
                              }
                            },
                            color: Colors.cyan[700],
                            child: isloading
                                ? circularprogress()
                                : Text(
                                    "verify",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          )
                        : RaisedButton(
                            onPressed: () {
                              if (_signUpWithEmail) {
                                if (_formkey.currentState.validate()) {
                                  _registerWithEmail();
                                }
                              } else {
                                _registerWithPhone();
                              }
                            },
                            color: Colors.cyan[700],
                            child: isloading
                                ? circularprogress()
                                : Text(
                                    "Sign Up",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 55),
                        Text(
                          "Sign Up with",
                          style:
                              TextStyle(color: Colors.cyan[700], fontSize: 20),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        _signUpWithEmail
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _signUpWithEmail = false;
                                  });
                                },
                                child: Text(
                                  "Phone Number",
                                  style: TextStyle(
                                      color: Colors.cyan[300], fontSize: 21),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _signUpWithEmail = true;
                                  });
                                },
                                child: Text(
                                  "Email",
                                  style: TextStyle(
                                      color: Colors.cyan[300], fontSize: 21),
                                ),
                              )
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 55),
                        Text(
                          "Have an account?",
                          style:
                              TextStyle(color: Colors.cyan[700], fontSize: 20),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign-In",
                            style: TextStyle(
                                color: Colors.cyan[300], fontSize: 21),
                          ),
                        )
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
