import 'package:Chatify/screens/HomeScreen.dart';
import 'package:Chatify/screens/Signup/signup_screen.dart';
import 'package:Chatify/widgets/Progresswidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  SharedPreferences preferences;
  final bool obscureText = true;
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  static const kPrimaryColor = Color(0xFF6F35A5);
  final FirebaseMessaging _messaging = FirebaseMessaging();
  String fcmToken;
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController nameEditingController = new TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _passwordVisible = false;
  bool isloading = false;
  bool _signUpWithEmail = true;
  bool codeSent = false;
  String _verificationId;
  TextEditingController phoneNumberEdittingController =
      new TextEditingController();
  String initialCountry = 'PK';
  PhoneNumber number = PhoneNumber(isoCode: 'PK');
  TextEditingController verifyCodeEdittingController =
      new TextEditingController();
  String phoneNumber;

  @override
  void initState() {
    // _passwordVisible = false;
    _messaging.getToken().then((value) {
      fcmToken = value;
    });
  }




  _signInWithCredential(_phoneAuthCredential) async {
    preferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;
    setState(() {
      isloading = true;
    });
    try {
      await FirebaseAuth.instance
          .signInWithCredential(_phoneAuthCredential)
          .then((AuthResult authRes) {
        firebaseUser = authRes.user;
        // print(authRes.toString());
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
            "email": '',
            "name": 'New User',
            "phone": phoneNumberEdittingController.text,
            "photoUrl": defaultPhotoUrl,
            "isPaidUser": false,
            "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            "state": 1,
            "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
            "aboutText": '',
            "fcmToken": fcmToken
          });

          FirebaseUser currentuser = firebaseUser;
          await preferences.setString("uid", currentuser.uid);
          await preferences.setString("name", nameEditingController.text);
          await preferences.setString("photo", defaultPhotoUrl);
          await preferences.setString("email", currentuser?.email ?? '');
          await preferences.setString("email", '');
          await preferences.setString("aboutText", '');
          await preferences.setString(
              "phone", phoneNumberEdittingController.text);
          await preferences.setBool("isPaidUser", false);
        } else {
          // FirebaseUser currentuser = firebaseUser;
          await preferences.setString("uid", documents[0]["uid"]);
          await preferences.setString("name", documents[0]["name"]);
          await preferences.setString("photo", documents[0]["photoUrl"]);
          await preferences.setString("email", documents[0]["email"]);
          await preferences.setString("phone", documents[0]["phone"]);
          await preferences.setString("aboutText", documents[0]["aboutText"]);
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
        Fluttertoast.showToast(msg: "Sign up Failed");
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isloading = false;
    });
  }

  void _registerWithPhone() async {
    preferences = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser;

    setState(() {
      isloading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
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
          isloading = false;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print(verificationId);
      },
    );

    print('credential');
    // setState(() {
    //   isloading = false;
    //
    // });

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
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /////////////
                  //////////////
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
                  // TextFieldWidget(
                  //   labelText: "Email",
                  //   obscureText: false,
                  //   prefixIconData: Icons.mail_outline,
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                                  phoneNumber = number.phoneNumber;
                                },
                                onInputValidated: (bool value) {
                                  print(value);
                                  // return true;
                                },
                                selectorConfig: SelectorConfig(
                                  selectorType: PhoneInputSelectorType.DIALOG,
                                ),
                                // ignoreBlank: true,
                                autoValidateMode: AutovalidateMode.disabled,
                                selectorTextStyle: TextStyle(
                                    color: Colors.white70),
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
                              keyboardType: TextInputType.emailAddress,

                              validator: (emailValue) {
                                if (emailValue.isEmpty) {
                                  return 'Email Required';
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
                              // obscureText: obscureText,
                              controller: emailEditingController,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(
                                  Icons.email_outlined,
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
                                  // color: Colors.black,
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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
                      !_signUpWithEmail
                          ? Container()
                          : TextFormField(
                              validator: (pwValue) {
                                if (pwValue.isEmpty) {
                                  return 'Password Required';
                                }
                                // if (pwValue.length < 6) {
                                //   return 'Password must be at least 6 characters';
                                // }

                                return null;
                              },
                              controller: passwordEditingController,
                              obscureText: !_passwordVisible,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock_open_outlined,
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
                                  // color: Colors.black,
                                  color: Colors.white,
                                ),
                                // focusColor: Colors.white,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.cyan[700]),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 8,
                      ),
                      !_signUpWithEmail
                          ? Container()
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPassword(),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgotten Password?",
                                style: TextStyle(
                                    color: Colors.cyan[700], fontSize: 20),
                              ),
                            )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  codeSent
                      ? RaisedButton(
                          onPressed: () {
                            {
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
                            }
                          },
                          color: Colors.cyan[700],
                          child: isloading
                              ? circularprogress()
                              : Text(
                                  "Verify",
                                  style: TextStyle(color: Colors.white),
                                ),
                        )
                      : RaisedButton(
                          onPressed: () {
                            {
                              if (_signUpWithEmail) {
                                if (_formkey.currentState.validate()) {
                                  loginUser();
                                }
                              } else {
                                _registerWithPhone();
                              }
                            }
                          },
                          color: Colors.cyan[700],
                          child: isloading
                              ? circularprogress()
                              : Text(
                                  "LOGIN",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 40),
                      Text(
                        "Sign In With ",
                        style: TextStyle(color: Colors.cyan[700], fontSize: 20),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      !_signUpWithEmail
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _signUpWithEmail = true;
                                });
                              },
                              child: Text(
                                "Email",
                                style: TextStyle(
                                    color: Colors.cyan[300], fontSize: 20),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  _signUpWithEmail = false;
                                });
                              },
                              child: Text(
                                "Phone Number",
                                style: TextStyle(
                                    color: Colors.cyan[300], fontSize: 20),
                              ),
                            )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 40),
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.cyan[700], fontSize: 20),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SignUpScreen();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Sign-Up",
                          style:
                              TextStyle(color: Colors.cyan[300], fontSize: 20),
                        ),
                      )
                    ],
                  ),

                  /////////
                  /////////

                  // Text(
                  //   "LOGIN",
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: size.height * 0.03),
                  // SvgPicture.asset(
                  //   "assets/icons/login.svg",
                  //   height: size.height * 0.35,
                  // ),
                  // SizedBox(height: size.height * 0.03),
                  // TextFieldContainer(
                  //   child: TextFormField(
                  //     controller: emailEditingController,
                  //     validator: (emailValue) {
                  //       if (emailValue.isEmpty) {
                  //         return 'This field is mandatory';
                  //       }
                  //
                  //       String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                  //           "\\@" +
                  //           "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                  //           "(" +
                  //           "\\." +
                  //           "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                  //           ")+";
                  //       RegExp regExp = new RegExp(p);
                  //
                  //       if (regExp.hasMatch(emailValue)) {
                  //         // So, the email is valid
                  //         return null;
                  //       }
                  //
                  //       return 'This is not a valid email';
                  //     },
                  //     cursorColor: kPrimaryColor,
                  //     decoration: InputDecoration(
                  //       icon: Icon(
                  //         Icons.email,
                  //         color: kPrimaryColor,
                  //       ),
                  //       hintText: "Your Email",
                  //       border: InputBorder.none,
                  //     ),
                  //   ),
                  // ),
                  // TextFieldContainer(
                  //   child: TextFormField(
                  //     controller: passwordEditingController,
                  //     obscureText: !_passwordVisible,
                  //     validator: (pwValue) {
                  //       if (pwValue.isEmpty) {
                  //         return 'This field is mandatory';
                  //       }
                  //       // if (pwValue.length < 6) {
                  //       //   return 'Password must be at least 6 characters';
                  //       // }
                  //
                  //       return null;
                  //     },
                  //     cursorColor: kPrimaryColor,
                  //     decoration: InputDecoration(
                  //       hintText: "Password",
                  //       icon: Icon(
                  //         Icons.lock,
                  //         color: kPrimaryColor,
                  //       ),
                  //       suffixIcon: IconButton(
                  //         icon: Icon(
                  //           _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  //           color: kPrimaryColor,
                  //         ),
                  //         onPressed: () {
                  //           setState(() {
                  //             _passwordVisible = !_passwordVisible;
                  //           });
                  //         },
                  //       ),
                  //       border: InputBorder.none,
                  //     ),
                  //   ),
                  // ),
                  // RoundedButton(
                  //   child: isloading
                  //       ? circularprogress()
                  //       : Text(
                  //           "LOGIN",
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //   press: () {
                  //     if (_formkey.currentState.validate()) {
                  //       loginUser();
                  //     }
                  //   },
                  // ),
                  // SizedBox(height: size.height * 0.03),
                  // AlreadyHaveAnAccountCheck(
                  //   press: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return SignUpScreen();
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    this.setState(() {
      isloading = true;
    });
    preferences = await SharedPreferences.getInstance();

    FirebaseUser firebaseUser;

    await _auth
        .signInWithEmailAndPassword(
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
      Firestore.instance
          .collection("Users")
          .document(firebaseUser.uid)
          .updateData({"fcmToken": fcmToken});

      Firestore.instance
          .collection("Users")
          .document(firebaseUser.uid)
          .get()
          .then((datasnapshot) async {
        print(datasnapshot.data["photoUrl"]);

        await preferences.setString("uid", datasnapshot.data["uid"]);
        await preferences.setString("name", datasnapshot.data["name"]);
        await preferences.setString("photo", datasnapshot.data["photoUrl"]);
        await preferences.setString("email", datasnapshot.data["email"]);
        await preferences.setString("phone", datasnapshot.data["phone"]);
        await preferences.setString("aboutText", datasnapshot.data["aboutText"]);
        await preferences.setBool(
            "isPaidUser", datasnapshot.data["isPaidUser"]);

        this.setState(() {
          isloading = false;
        });

        Navigator.pop(context);
        Route route = MaterialPageRoute(
            builder: (c) => HomeScreen(
                  currentuserid: firebaseUser.uid,
                ));
        Navigator.pushReplacement(context, route);
      });
    } else {
      this.setState(() {
        isloading = false;
      });
      Fluttertoast.showToast(msg: "Login Failed");
    }
  }
}
