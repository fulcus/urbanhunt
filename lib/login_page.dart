import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hunt_app/utils/validation_helper.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:hunt_app/explore/explore.dart';
import 'package:hunt_app/navbar.dart';
import 'package:hunt_app/utils/network.dart';

// Backend utils
const Color fbBlue = Color(0xFF4267B2);
//TODO global keys here gives exception when logging out: Duplicate GlobalKey detected in widget tree. (but without consequences)
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey1 =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey2 =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey3 =
    GlobalKey<ScaffoldMessengerState>();

// To be used in main.dart (App build) as home property (i.e. home: redirectHomeOrLogin()).
StreamBuilder redirectHomeOrLogin() {
  // Fast track for already authenticated users
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.active) {
        return Center(child: CircularProgressIndicator());
      }

      final hasUser = snapshot.hasData;
      if (hasUser && FirebaseAuth.instance.currentUser!.emailVerified) {
        // return BottomNavContainer();
        return Navbar(menuScreenContext: context);
      } else {
        return LoginPage();
      }
    },
  );
}

Future<void> _addUserToDB(String uid, String? imageURL) async {
  var randomUsername = 'user' + (Random().nextInt(99999)).toString();
  try {
    var myCountry = await getCountry();
    await db.collection('users').doc(uid).set(<String, dynamic>{
      'imageURL': imageURL ?? '',
      'score': 0,
      'username': randomUsername,
      'country': myCountry
    });
  } on Exception catch (e) {
    print(e);
  }
}

Future<bool> loginFacebook() async {
  bool logged = false;

  try {
    // Trigger the sign-in flow
    final loginResult = await FacebookAuth.instance.login();

    if (loginResult.status == LoginStatus.success) {
      // Create a credential from the access token
      final facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Once signed in, return the UserCredential
      var userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential)
          .catchError((Object error) async {
        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'account-exists-with-different-credential':
              var pendingCred = error.credential;
              var email = error.email;

              List<String> methods = await FirebaseAuth.instance
                  .fetchSignInMethodsForEmail(email!);
              if (methods.contains('google.com')) {
                final googleUser = (await GoogleSignIn().signIn())!;
                final googleAuth = await googleUser.authentication;
                final credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );
                var userCredential = await FirebaseAuth.instance
                    .signInWithCredential(credential);
                userCredential.user!.linkWithCredential(pendingCred!);
              } else if (methods.contains('password')) {
                var prevUser = FirebaseAuth.instance.currentUser;
                prevUser!.linkWithCredential(pendingCred!);
              }
              logged = true;
              break;
            case 'invalid-credential':
              _showInSnackBar('Invalid credential', _scaffoldMessengerKey1);
              logged = false;
              break;
            case 'user-not-found':
              _showInSnackBar('User not found', _scaffoldMessengerKey1);
              logged = false;
              break;
          }
        }
      });
      if (userCredential.additionalUserInfo!.isNewUser) {
        //User logging in for the first time
        var name = userCredential.user!.displayName;
        var picture = userCredential.user!.photoURL; // use in NetworkImage
        print('$name $picture');
        await _addUserToDB(userCredential.user!.uid, picture);
      }
      logged = true;
    } else if (loginResult.status == LoginStatus.cancelled) {
      logged = false;
    } else if (loginResult.status == LoginStatus.failed) {
      _showInSnackBar(
          'Login has failed. Try again later', _scaffoldMessengerKey1);
      logged = false;
    }
  } on Exception catch (e) {
    print('Error: $e');
    logged = false;
  }
  return logged;
}

Future<bool> loginGoogle() async {
  bool logged = false;

  try {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return false;

    // Obtain the auth details from the request
    final googleAuth = await googleUser.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    var userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential)
        .catchError((Object error) async {
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'account-exists-with-different-credential':
            var pendingCred = error.credential;
            var email = error.email;

            List<String> methods =
                await FirebaseAuth.instance.fetchSignInMethodsForEmail(email!);
            if (methods.contains('facebook.com')) {
              final loginResult = await FacebookAuth.instance.login();
              if (loginResult.status == LoginStatus.success) {
                final facebookAuthCredential = FacebookAuthProvider.credential(
                    loginResult.accessToken!.token);
                var userCredential = await FirebaseAuth.instance
                    .signInWithCredential(facebookAuthCredential);
                userCredential.user!.linkWithCredential(pendingCred!);
              }
            } else if (methods.contains('password')) {
              var prevUser = FirebaseAuth.instance.currentUser;
              prevUser!.linkWithCredential(pendingCred!);
            }
            logged = true;
            break;
          case 'invalid-credential':
            _showInSnackBar('Invalid credential', _scaffoldMessengerKey1);
            logged = false;
            break;
          case 'user-not-found':
            _showInSnackBar('User not found', _scaffoldMessengerKey1);
            logged = false;
            break;
        }
      }
    });
    if (userCredential.additionalUserInfo!.isNewUser) {
      //User logging in for the first time
      var name = userCredential.user!.displayName;
      var picture = userCredential.user!.photoURL; // use in NetworkImage
      print('$name $picture');
      await _addUserToDB(userCredential.user!.uid, picture);
    }
    logged = true;
  } on Exception catch (e) {
    print('Error: $e');
    logged = false;
  }
  return logged;
}

Future<bool> loginEmailPassword(String email, String password) async {
  return await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password)
      .then((_) {
    return true;
  }).catchError((Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          _showInSnackBar('Invalid email', _scaffoldMessengerKey1);
          break;
        case 'user-disabled':
          _showInSnackBar('The user associated to this email is disabled',
              _scaffoldMessengerKey1);
          break;
        case 'user-not-found':
          _showInSnackBar('This email is not associated to any user',
              _scaffoldMessengerKey1);
          break;
        case 'wrong-password':
          _showInSnackBar('The password is wrong', _scaffoldMessengerKey1);
          break;
      }
    }
    print(error);
    return false;
  });
}

Future<bool> signupAndLoginEmailPassword(String email, String password) async {
  return await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((userCredential) async {
    if (userCredential.additionalUserInfo!.isNewUser) {
      //User logging in for the first time
      userCredential.user!.sendEmailVerification(ActionCodeSettings(
          url: 'https://hunt-app-ef3f2.firebaseapp.com/__/auth/action',
          handleCodeInApp: true));
      await _addUserToDB(userCredential.user!.uid, null);
    }
    return loginEmailPassword(email, password);
  }).catchError((Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          _showInSnackBar('Invalid email', _scaffoldMessengerKey2);
          break;
        case 'email-already-in-use':
          _showInSnackBar('This email is already associated to another account',
              _scaffoldMessengerKey2);
          break;
        case 'weak-password':
          _showInSnackBar('The password is too weak', _scaffoldMessengerKey2);
          break;
      }
    }
    print(error);
    return false;
  });
}

bool validateForm(GlobalKey<FormState> formKey) {
  final form = formKey.currentState;
  if (form!.validate()) {
    form.save();
    return true;
  }
  return false;
}

void _showInSnackBar(
    String value, GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey) {
  _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
  _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
    content: Text(value),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(14),
        topLeft: Radius.circular(14),
      ),
    ),
  ));
}

// Frontend utils
ValidationHelper validationHelper = ValidationHelper();
Color mainColor = Colors.greenAccent[400]!;
Color mainColorContrast = Colors.green[400]!;

TextStyle styleHeading1 = TextStyle(
    fontSize: 92.0, fontWeight: FontWeight.bold);
TextStyle styleHeading2 = TextStyle(
    fontSize: 72.0, fontWeight: FontWeight.bold);
TextStyle styleNormal =
    TextStyle(fontSize: 18.0, color: Colors.black87);
TextStyle styleBold = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: Colors.black);
TextStyle styleHint = TextStyle(
    fontSize: 14.0, color: Colors.grey.withOpacity(0.75));
TextStyle styleLink = TextStyle(
    fontSize: 18.0,
    color: mainColor,
    decoration: TextDecoration.underline);
TextStyle styleButtonified = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Colors.white);

Widget heading1(String text, double x, double y) {
  return Positioned(
    top: y,
    left: x,
    child: Text(text, style: styleHeading1),
  );
}

Widget heading2(String text, double x, double y) {
  return Positioned(
    top: y,
    left: x,
    child: Text(text, style: styleHeading2),
  );
}

Widget iconLock(double x, double y) {
  return Positioned(
    top: y,
    left: x,
    child: Container(
      height: 20.0,
      width: 20.0,
      child: Icon(
        Icons.lock_open_rounded,
        color: mainColor,
      ),
    ),
  );
}

Widget emailField(void Function(String?) onTextChanged) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'EMAIL',
      labelStyle: styleHint,
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: mainColor)),
    ),
    onChanged: onTextChanged,
    validator: validationHelper.validateEmail,
  );
}

Widget passwordField(void Function(String?) onTextChanged) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'PASSWORD',
      labelStyle: styleHint,
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: mainColor)),
    ),
    obscureText: true,
    onChanged: onTextChanged,
    validator: validationHelper.validatePassword,
  );
}

Widget link(String text, void Function() onTap) {
  return InkWell(
    child: Text(text, style: styleLink),
    onTap: onTap,
  );
}

Widget lineLink(String prefix, String text, void Function() onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(prefix, style: styleNormal),
      SizedBox(width: 5.0),
      InkWell(
        onTap: onTap,
        child: Text(text, style: styleLink),
      ),
    ],
  );
}

Widget buttonify(String text) {
  return Material(
    borderRadius: BorderRadius.circular(25.0),
    shadowColor: mainColorContrast,
    color: mainColor,
    elevation: 7.0,
    child: Center(
      child: Text(text, style: styleButtonified),
    ),
  );
}

// Pages and navigation
// - LoginPage -> SignupPage, ResetPasswordPage
// - SignupPage -> LoginPage
// - ResetPasswordPage -> LoginPage

class LoginPage extends StatefulWidget {
  final String title = 'Login';

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldMessengerKey1,
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: _buildLoginForm(context),
            ),
          ),
        ));
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (validateForm(_formKey)) {
          loginEmailPassword(_email, _password).then((ok) {
            if (ok) {
              pushNewScreen<void>(
                context,
                screen: Navbar(
                  menuScreenContext: context,
                ),
              );
              //   Navigator.of(context, rootNavigator: true).pushReplacement(
              //       MaterialPageRoute<void>(
              //           builder: (context) => BottomNavContainer()));
            }
          });
        }
      },
      child: Container(
        height: 50.0,
        child: buttonify('LOGIN'),
      ),
    );
  }

  Widget _buildLoginFacebookButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        loginFacebook().then((ok) {
          if (ok) {
            pushNewScreen<void>(
              context,
              screen: Navbar(
                menuScreenContext: context,
              ),
            );

            // Navigator.of(context, rootNavigator: true).pushReplacement(
            //     MaterialPageRoute<void>(
            //         builder: (context) => BottomNavContainer()));
          }
        });
      },
      child: Container(
        height: 50.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: fbBlue,
              style: BorderStyle.solid,
              width: 1.0,
            ),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image(
                  image: AssetImage('assets/images/facebook.png'),
                  width: 22.0,
                  height: 22.0,
                  color: fbBlue,
                ),
              ),
              SizedBox(width: 10.0),
              Center(
                child: const Text('Login with facebook',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: fbBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginGoogleButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        loginGoogle().then((ok) {
          if (ok) {
            pushNewScreen<void>(
              context,
              screen: Navbar(
                menuScreenContext: context,
              ),
            );

            // Navigator.of(context).push<MaterialPageRoute>(
            //   MaterialPageRoute(builder: (context) => BottomNavContainer()),
            // );
          }
        });
      },
      child: Container(
        height: 50.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              style: BorderStyle.solid,
              width: 1.0,
            ),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image(
                  image: AssetImage('assets/images/google.png'),
                  width: 22.0,
                  height: 22.0,
                  color: null,
                ),
              ),
              SizedBox(width: 10.0),
              Center(
                child: Text('Login with Google', style: styleBold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: ListView(
        children: [
          SizedBox(height: 75.0),
          Container(
            height: 175.0,
            width: 200.0,
            child: Stack(
              children: [
                heading1('Urban', 0.0, 0.0),
                heading1('Hunt', 25.0, 75.0),
                iconLock(246.0, 65.0),
              ],
            ),
          ),
          SizedBox(height: 25.0),
          emailField((value) {
            if (value != null) {
              _email = value;
            }
          }),
          passwordField((value) {
            if (value != null) {
              _password = value;
            }
          }),
          SizedBox(height: 5.0),
          Container(
            alignment: Alignment(1.0, 0.0),
            padding: EdgeInsets.only(top: 15.0, left: 20.0),
            child: link(
              'Forgot Password?',
              () {
                pushNewScreen<void>(context, screen: ResetPasswordPage());

                // Navigator.of(context).push<MaterialPageRoute>(MaterialPageRoute(
                //     builder: (context) => ResetPasswordPage()));
              },
            ),
          ),
          SizedBox(height: 50.0),
          _buildLoginButton(context),
          SizedBox(height: 20.0),
          _buildLoginFacebookButton(context),
          SizedBox(height: 20.0),
          _buildLoginGoogleButton(context),
          SizedBox(height: 38.0),
          lineLink(
            'Dont have an account?',
            'Sign up now',
            () {
              pushNewScreen<void>(context, screen: SignupPage());

              // Navigator.of(context).push<MaterialPageRoute>(
              //   MaterialPageRoute(builder: (context) => SignupPage()),
              // );
            },
          ),
        ],
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  final String title = 'Signup';

  @override
  State<StatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldMessengerKey2,
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: _buildSignupForm(context),
            ),
          ),
        ));
  }

  Widget _buildSignupButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (validateForm(_formKey)) {
          signupAndLoginEmailPassword(_email, _password).then((ok) {
            if (ok) {
              pushNewScreen<void>(
                context,
                screen: Navbar(
                  menuScreenContext: context,
                ),
              );

              // Navigator.of(context, rootNavigator: true).pushReplacement(
              //     MaterialPageRoute<void>(
              //         builder: (context) => BottomNavContainer()));
            }
          });
        }
      },
      child: Container(
        height: 50.0,
        child: buttonify('SIGN UP'),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: ListView(
        children: [
          SizedBox(height: 75.0),
          Container(
            height: 110.0,
            width: 200.0,
            child: Stack(
              children: [
                heading1('Sign up', 0.0, 0.0),
                iconLock(180.0, 65.0),
              ],
            ),
          ),
          SizedBox(height: 25.0),
          emailField((value) {
            if (value != null) {
              _email = value;
            }
          }),
          passwordField((value) {
            if (value != null) {
              _password = value;
            }
          }),
          SizedBox(height: 50.0),
          _buildSignupButton(context),
          SizedBox(height: 38.0),
          lineLink('Already registered?', 'Login now', () {
            Navigator.of(context).pop();
          }),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  final String title = 'Reset';

  @override
  State<StatefulWidget> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: _scaffoldMessengerKey3,
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: _buildResetPasswordForm(context),
            ),
          ),
        ));
  }

  Widget _buildResetPasswordButton(BuildContext context) {
    var _firstPress = true;
    return GestureDetector(
      onTap: () {
        if (_firstPress) {
          if (validateForm(_formKey)) {
            _firstPress = false;
            FirebaseAuth.instance
                .sendPasswordResetEmail(email: _email)
                .then((_) {
              _showInSnackBar(
                  'An email to reset your password has been sent to you. Check your email box.',
                  _scaffoldMessengerKey3);
            }).catchError((Object error) {
              if (error is FirebaseAuthException) {
                switch (error.code) {
                  case 'invalid-email':
                    _showInSnackBar('Invalid email', _scaffoldMessengerKey3);
                    break;
                  case 'user-not-found':
                    _showInSnackBar('This email is not associated to any user',
                        _scaffoldMessengerKey3);
                    break;
                }
              }
            });
          }
        }
      },
      child: Container(
        height: 50.0,
        child: buttonify('SEND EMAIL'),
      ),
    );
  }

  Widget _buildResetPasswordForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: ListView(
        children: [
          SizedBox(height: 75.0),
          Container(
            height: 180.0,
            width: 200.0,
            child: Stack(
              children: [
                heading2('Password', 0.0, 0.0),
                heading2('Reset', 25.0, 75.0),
                iconLock(220.0, 120.0),
              ],
            ),
          ),
          SizedBox(height: 25.0),
          emailField((value) {
            if (value != null) {
              _email = value;
            }
          }),
          SizedBox(height: 50.0),
          _buildResetPasswordButton(context),
          SizedBox(height: 38.0),
          Center(
              child: link('Go Back', () {
            Navigator.of(context).pop();
          })),
        ],
      ),
    );
  }
}
