import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/utils/misc.dart';

import '../auth/login_page.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String title, description;

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  late User _myUser;

  @override
  void initState() {
    super.initState();
    _myUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text(widget.description),
          SizedBox(height: 20),
          Divider(
            height: 1,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: InkWell(
              highlightColor: Colors.grey[200],
              onTap: () {
                _myUser.delete().catchError((Object error) {
                  if (error is FirebaseAuthException) {
                    if (error.code == 'requires-recent-login') {
                      var oldPassword = retrieveOldPassword(context);
                      var credential = EmailAuthProvider.credential(
                          email: _myUser.email!, password: oldPassword);

                      _myUser
                          .reauthenticateWithCredential(credential)
                          .then((_) => print('Re-authenticated'))
                          .catchError((Object error) {
                        if (error is FirebaseAuthException) {
                          // showInSnackBar(
                          //     'Unable to change password. Please try again later.', _scaffoldMessengerKey, height: 70.0);
                          print(error.message);
                        } else {
                          print(error.toString());
                        }
                      });
                    } else {
                      print(error.message);
                    }
                  } else {
                    print("Password can't be changed" + error.toString());
                  }
                });

                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              child: Center(
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: InkWell(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
              highlightColor: Colors.grey[200],
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
