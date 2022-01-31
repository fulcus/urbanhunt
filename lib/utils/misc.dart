import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/auth/login_page.dart';

final db = FirebaseFirestore.instance;

//TODO if keyboard is not visible change SnackBar elevation
void showInSnackBar(String value,
    GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey,
    {double height = 18.0}) {
  _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
  _scaffoldMessengerKey.currentState!.showSnackBar(
      isMobile ? SnackBar(
        content: Container(child: Text(value), height: height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(14),
            topLeft: Radius.circular(14),
          ),
        ),
      ) : SnackBar(
            content: Container(
              child: FittedBox(child: Text(value)),
              height: 15,
            ),
            width: 300,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
         )
  );
}

void showInFlushBar(String message, BuildContext context) {
  if(isMobile) {
    Flushbar<dynamic>(
      message: message,
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 300),
      padding: EdgeInsets.only(left: 26, top: 15, bottom: 65),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(14),
        topLeft: Radius.circular(14),
      ),
    ).show(context);
  } else {
    Flushbar<dynamic>(
      messageText: Center(child: Text(message, style: TextStyle(color: Colors.white))),
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 300),
      borderRadius: BorderRadius.all(Radius.circular(14)),
      maxWidth: 300,
      margin: EdgeInsets.all(65),
    ).show(context);
  }
}

bool isEmailAuthProvider(User user) {
  return user.providerData[0].providerId == 'password';
}

String retrieveOldPassword(BuildContext context) {
  var controller = TextEditingController();
  var oldPassword = '';

  // TODO dialog over dialog does not work, throws exception
  showDialog<void>(
    context: context,
    builder: (_) =>
        AlertDialog(
          title: Text('You have to re-authenticate to change the password'),
          content: TextFormField(
            decoration: const InputDecoration(hintText: 'Enter your password'),
            controller: controller,
            obscureText: true,
            enabled: true,
          ),
          actions: [
            ElevatedButton(
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green[300],
                textStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () => oldPassword = controller.value.text,
            )
          ],
        ),
  );

  return oldPassword;
}

Route createRoute(Widget page) {
  return PageRouteBuilder<Route>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
