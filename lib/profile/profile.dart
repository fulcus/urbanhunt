
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hunt_app/login_page.dart';
import 'package:one_context/one_context.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/profile/unlocked_list.dart';
import 'package:image_picker/image_picker.dart';

final db = FirebaseFirestore.instance;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  bool _status = true;
  bool _enabled = true;
  bool _isNameButton = true;
  final FocusNode myFocusNode = FocusNode();
  String _newName = '';
  String _newPassword = '';
  String _oldPassword = '';
  File? _image;
  final picker = ImagePicker();
  late User _myUser;
  late Stream<QuerySnapshot> _myUserData;

  @override
  void initState() {
    super.initState();
    _myUser = FirebaseAuth.instance.currentUser!;

    _myUserData = db
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: _myUser.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: _myUserData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var url = snapshot.data!.docs[0].get('imageURL').toString();
                var username =
                    snapshot.data!.docs[0].get('username').toString();
                var countryName =
                    snapshot.data!.docs[0].get('country').toString();

                return Container(
                  color: Colors.white,
                  child: ListView(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            height: 250.0,
                            color: Colors.white,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 20.0, top: 20.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text('PROFILE',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  fontFamily: 'sans-serif-light',
                                                  color: Colors.black)),
                                        )
                                      ],
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                  child: Stack(
                                      fit: StackFit.loose,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                width: 140.0,
                                                height: 140.0,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: showImage(url),
                                                      fit: BoxFit.cover,
                                                    )))
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: 90.0, right: 100.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                FloatingActionButton(
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.blueAccent,
                                                    radius: 25.0,
                                                    child: Icon(
                                                      Icons.camera_alt,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  heroTag: 'btn1',
                                                  onPressed: () async => {
                                                    await getImage(),
                                                    await uploadImage(_image!)
                                                  },
                                                )
                                              ],
                                            )),
                                      ]),
                                )
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 25.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Personal Information',
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),

                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Name',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              _status
                                                  ? _getEditIcon()
                                                  : Container(),
                                            ],
                                          )
                                        ],
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 2.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                              child: TextField(
                                                controller: TextEditingController()..text = username,
                                                decoration: const InputDecoration(
                                                  hintText: 'Enter Your Name',
                                               ),
                                                enabled: !_status,
                                                autofocus: !_status,
                                                onChanged: (name) => _newName = name,
                                            )),
                                        ],
                                      )),
                                  !_status ? _getActionButtons() : Container(),

                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Email',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 2.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: TextField(
                                              controller:
                                                  TextEditingController()..text = _myUser.email.toString(),
                                              //email cannot be changed
                                              enabled: false,
                                            ),
                                          ),
                                        ],
                                      )),

                                  //if the user is logged with fb, the password is not shown
                                  if(FacebookAuth.i.accessToken == null)
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Password',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              _enabled
                                                  ? _getEditIcon2()
                                                  : Container(),
                                            ],
                                          )
                                        ],
                                      )),
                                  if(FacebookAuth.i.accessToken == null)
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 2.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: TextField(
                                              controller: TextEditingController()..text = '**********',
                                              obscureText: true,
                                              enabled: !_enabled,
                                              autofocus: !_enabled,
                                              onChanged: (password) => _newPassword = password,
                                            ),
                                          ),
                                        ],
                                      )),
                                  !_enabled ? _getActionButtons() : Container(),

                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Country',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 2.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: TextField(
                                              controller:
                                                  TextEditingController()..text = countryName,
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      'Enter your Country'),
                                              enabled: false,
                                              autofocus: !_status,
                                            ),
                                          ),
                                          GestureDetector(
                                            child: CircleAvatar(
                                              backgroundColor:
                                              Colors.transparent,
                                              radius: 14.0,
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.black87,
                                                size: 30.0,
                                              ),
                                            ),
                                            onTap: () => showCountryPicker(
                                                context: context,
                                                showPhoneCode: false,
                                                onSelect: (country) {
                                                  countryName = country.name;
                                                  _updateCountry(countryName);
                                                }),
                                          ),
                                        ],
                                      )),

                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'My Unlocked Places',
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              FloatingActionButton(
                                                heroTag: 'btn2',
                                                onPressed: () => Navigator.push(context,
                                                    MaterialPageRoute<void>(builder: (context) => UnlockedList())),
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.blueAccent,
                                                  radius: 25.0,
                                                  child: Icon(
                                                    Icons.lock_open,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      )
                                  ),

                                  //LOGOUT button
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          GestureDetector(
                                              child: Container(
                                                width: 100.0,
                                                decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.black87),
                                                    borderRadius: BorderRadius.all(Radius.circular(20))),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(width: 6.0),
                                                    Icon(Icons.exit_to_app, color: Colors.black87),
                                                    SizedBox(width: 4.0),
                                                    Text(
                                                      'Logout',
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.of(context, rootNavigator: true)
                                                    .pushReplacement(MaterialPageRoute<void>
                                                  (builder: (context) => LoginPage()));
                                              }
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('No image selected.');
    } else {
      setState(() {
        _image = File(pickedFile.path);
        print('file picked');
      });
    }
  }

  Future<void> uploadImage(File image) async {
    try {
      var path = '${_myUser.uid}${extension(image.path)}';
      print('path ' + path);
      var storageRef =
          FirebaseStorage.instance.ref().child('images/profile/$path');
      await storageRef.putFile(image);
      print('File Uploaded');

      var returnURL = '';
      await storageRef.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
        print('returnURL $returnURL');
      });
      await db
          .collection('users')
          .doc(_myUser.uid)
          .update({'imageURL': returnURL});
      print('URL stored');
    } on FirebaseException catch (e) {
      //printErrorMessage(e.message!); //TODO handle error
      print(e.stackTrace);
    }
  }

  ImageProvider showImage(String url) {
    ImageProvider imageProvider = AssetImage('assets/images/as.png');
    if (url != '') {
      imageProvider = NetworkImage(url);
    }
    return imageProvider;
  }

  Future<void> _updateCountry(String country) async {
    var data = <String, dynamic>{'country': country};

    return await db
        .collection('users')
        .doc(_myUser.uid)
        .update(data);
  }

  Future<void> _updateUsername(String username) async {
    //TODO input validation: unique, if '' or newName = currName don't update db, too short (3 chars)
    var data = <String, dynamic>{'username': username};

    return await db
        .collection('users')
        .doc(_myUser.uid)
        .update(data);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    /*final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters';
    }*/
    if (value.length > 50) {
      return 'Name is too long, use at most 50 characters';
    }
    return null;
  }

  //TODO if the user is logged with fb or google, the password cannot be changed
  Future<void> _changePassword(String password) async {

    await _myUser.updatePassword(password).then((_) {
      print('Successfully changed password');
    }).catchError((Object error){
        if(error is FirebaseAuthException) {
          if(error.code == 'requires-recent-login') {

            _retrieveOldPassword();

            var credential = EmailAuthProvider.credential(email: _myUser.email!, password: _oldPassword);
            _myUser.reauthenticateWithCredential(credential);
          }
          else if(error.code == 'weak-password') {
            _errorPopup('The password is too weak.\n Please insert another one.');
          }
          else {
            _errorPopup('Please try again.' + error.toString());
          }
      }
      else {
        _errorPopup("Password can't be changed" + error.toString());
      }
      //This might happen, when the wrong password is in, the user isn't found,
      //or if the user hasn't logged in recently.
    });
  }

  void _retrieveOldPassword() {
    var controller = TextEditingController();

    OneContext().showDialog<void>(
        builder: (_) =>  AlertDialog(
          title: Text('You have to re-authenticate to change the password'),
          content: TextFormField(
            decoration: const InputDecoration(
                hintText: 'Enter your password'),
            controller: controller,
            obscureText: true,
            enabled: true,
          ),
          actions: [
            ElevatedButton(
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () => _oldPassword = controller.value.text,
            )
          ],
        ),
    );
  }

  void _errorPopup (String content) {
    OneContext().showDialog<void>(
        builder: (_) => AlertDialog(
          title: Text('Alert:'),
          content: Text(content),
          actions: [
            ElevatedButton(
              child: Text('Ok'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () => OneContext().popDialog(),
            )
          ],
        ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: ElevatedButton(
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      textStyle: TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                    onPressed: () {
                      _isNameButton ? _updateUsername(_newName) : _changePassword(_newPassword);
                      setState(() {
                        _isNameButton ? _status = true : _enabled = true;
                        //FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: ElevatedButton(
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      textStyle: TextStyle(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                    onPressed: () {
                      setState(() {
                        _isNameButton ? _status = true : _enabled = true;
                        //FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _isNameButton = true;
          _status = false;
          _enabled = true;
        });
      },
    );
  }


  Widget _getEditIcon2() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _isNameButton = false;
          _status = true;
          _enabled = false;
        });
      },
    );
  }
}
