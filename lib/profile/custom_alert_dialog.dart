import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      insetPadding: (isMobile || MediaQuery.of(context).orientation == Orientation.portrait) ?
          EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0) :
          EdgeInsets.symmetric(horizontal: 400),
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
                _myUser.delete().catchError((Object error) async {
                  if(error is FirebaseAuthException && error.code == 'requires-recent-login') {
                    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_myUser.email!);
                    _myUser.reauthenticateWithCredential(
                        AuthCredential(
                            providerId: _myUser.providerData[0].providerId,
                            signInMethod: signInMethods[0]
                        )
                    );
                  }
                });
                Navigator.of(context, rootNavigator: true)
                    .pushAndRemoveUntil(MaterialPageRoute<void>(
                    builder: (context) => LoginPage()),
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
