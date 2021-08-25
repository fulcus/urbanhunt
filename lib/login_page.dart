import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hunt_app/explore/explore.dart';

// Backend utils

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
        return BottomNavContainer();
      } else {
        return LoginPage();
      }
    },
  );
}

Future<bool> loginFacebook() async {
  // todo catch errors
  return await FacebookAuth.instance
      .login(permissions: ['public_profile', 'email']).then((value) {
    FacebookAuth.instance.getUserData().then((userData) {
      // var name = userData['name'] as String;
      // var email = userData['email'] as String;
      // var picture = userData['picture']['data']['url'] as String;  // use in NetworkImage

      print('Facebook login success!');
    });
    return true;
  }).catchError((Object error) {
    // todo display exception
    print(error);
    return false;
  });

}

Future<bool> loginEmailPassword(String email, String password) async {
  return await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password).then((value) {
    return true;
  }).catchError((Object error) {
    // todo display exception
    print(error);
    return false;
  });
}

Future<bool> signupAndLoginEmailPassword(String email, String password) async {
  await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);

  return loginEmailPassword(email, password);
}

bool validateForm(GlobalKey<FormState> formKey) {
  final form = formKey.currentState;
  if (form!.validate()) {
    form.save();
    return true;
  }
  return false;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  } else {
    var re = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!re.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  } else {
    return null;
  }
}

// Frontend utils
Color mainColor = Colors.greenAccent[400]!;
Color mainColorContrast = Colors.green[400]!;

TextStyle styleHeading1 = TextStyle(
    fontFamily: 'Truneo', fontSize: 92.0, fontWeight: FontWeight.bold);
TextStyle styleHeading2 = TextStyle(
    fontFamily: 'Truneo', fontSize: 72.0, fontWeight: FontWeight.bold);
TextStyle styleNormal =
    TextStyle(fontFamily: 'Truneo', fontSize: 18.0, color: Colors.black87);
TextStyle styleBold = TextStyle(
    fontFamily: 'Trueno',
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: Colors.black);
TextStyle styleHint = TextStyle(
    fontFamily: 'Truneo', fontSize: 14.0, color: Colors.grey.withOpacity(0.75));
TextStyle styleLink = TextStyle(
    fontFamily: 'Trueno',
    fontSize: 18.0,
    color: mainColor,
    decoration: TextDecoration.underline);
TextStyle styleButtonified = TextStyle(
    fontFamily: 'Trueno',
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
    validator: validateEmail,
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
    validator: validatePassword,
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
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: _buildLoginForm(context),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (validateForm(_formKey)) {
          loginEmailPassword(_email, _password).then((ok) {
            if (ok) {
              Navigator.of(context).push<MaterialPageRoute>(
                MaterialPageRoute(builder: (context) => BottomNavContainer()),
              );
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
            Navigator.of(context).push<MaterialPageRoute>(
              MaterialPageRoute(builder: (context) => BottomNavContainer()),
            );
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
                child: ImageIcon(
                  AssetImage('assets/images/facebook.png'),
                  size: 22.0,
                ),
              ),
              SizedBox(width: 10.0),
              Center(
                child: Text('Login with facebook', style: styleBold),
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
                heading1('City', 0.0, 0.0),
                heading1('Hunt', 25.0, 75.0),
                iconLock(156.0, 65.0),
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
                Navigator.of(context).push<MaterialPageRoute>(MaterialPageRoute(
                    builder: (context) => ResetPasswordPage()));
              },
            ),
          ),
          SizedBox(height: 50.0),
          _buildLoginButton(context),
          SizedBox(height: 20.0),
          _buildLoginFacebookButton(context),
          SizedBox(height: 38.0),
          lineLink(
            'Dont have an account?',
            'Sign up now',
            () {
              Navigator.of(context).push<MaterialPageRoute>(
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
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
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: _buildSignupForm(context),
        ),
      ),
    );
  }

  Widget _buildSignupButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (validateForm(_formKey)) {
          signupAndLoginEmailPassword(_email, _password).then((ok) {
            if (ok) {
              Navigator.of(context).push<MaterialPageRoute>(
                MaterialPageRoute(builder: (context) => BottomNavContainer()),
              );
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
                iconLock(186.0, 65.0),
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
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: _buildResetPasswordForm(context),
        ),
      ),
    );
  }

  Widget _buildResetPasswordButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (validateForm(_formKey)) {
          FirebaseAuth.instance.sendPasswordResetEmail(email: _email).then((_) {
            Navigator.of(context).pop();
          });
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
