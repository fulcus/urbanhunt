import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//TODO if keyboard is not visible change SnackBar elevation
void showInSnackBar(
    String value, GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey,
    {double height = 0.0}) {
  _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
  _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
    content: Container(child: Text(value), height: height),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(14),
        topLeft: Radius.circular(14),
      ),
    ),
  ));
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
    builder: (_) => AlertDialog(
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
