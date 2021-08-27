
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hunt_app/login_page.dart';
import 'package:one_context/one_context.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isUnique = true;
  bool _isEmailAuth = true;
  bool _onChanged = true;

  String _newName = '';
  String _newPassword = '';
  String _oldPassword = '';

  File? _image;

  final FocusNode myFocusNode = FocusNode();
  final ImagePicker picker = ImagePicker();
  final GlobalKey<FormFieldState> _nameFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _pswFormKey = GlobalKey<FormFieldState>();
  final TextEditingController _nameController = TextEditingController();

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

    _isEmailAuthProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
            stream: _myUserData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var url = snapshot.data!.docs[0].get('imageURL').toString();
                var username = snapshot.data!.docs[0].get('username').toString();
                var countryName = snapshot.data!.docs[0].get('country').toString();

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
                                              child: TextFormField(
                                                key: _nameFormKey,
                                                controller: _nameController..text = username,
                                                decoration: const InputDecoration(
                                                  hintText: 'Enter Your Name',
                                                ),
                                                enabled: !_status,
                                                autofocus: !_status,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                onChanged: (name) => {
                                                  if(_nameController.text != username) {
                                                    _isUsernameUnique(_nameController.text),
                                                    _newName = _nameController.text,
                                                    _onChanged = true,
                                                  }
                                                },
                                                validator: _validateName,
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

                                  //if the user is not logged with email and password, the password is not shown
                                  if(_isEmailAuth)
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
                                                    fontWeight: FontWeight.bold
                                                ),
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
                                  if(_isEmailAuth)
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 2.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: TextFormField(
                                              key: _pswFormKey,
                                              controller: TextEditingController()..text = '**********',
                                              obscureText: true,
                                              enabled: !_enabled,
                                              autofocus: !_enabled,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              onChanged: (password) => _newPassword = password,
                                              validator: _validatePsw,
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
                                                    fontWeight: FontWeight.bold
                                                ),
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
                                              controller: TextEditingController()..text = countryName,
                                              decoration: const InputDecoration(
                                                  hintText: 'Enter your Country'),
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
                                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                                ),
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

  void _isEmailAuthProvider() {
    var providerId = _myUser.providerData[0].providerId;

    if(providerId != 'password') {
      _isEmailAuth = false;
    }
  }

  Future<void> _updateCountry(String country) async {
    var data = <String, dynamic>{'country': country};

    return await db
        .collection('users')
        .doc(_myUser.uid)
        .update(data);
  }

  Future<void> _updateUsername(String username) async {
    var data = <String, dynamic>{'username': username};

    return await db
        .collection('users')
        .doc(_myUser.uid)
        .update(data);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }
    if (value.length < 3) {
      return 'Name has to be at least 3 characters long.';
    }
    if (value.length > 50) {
      return 'Name has to be at most 50 characters long.';
    }
    final nameExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphanumeric characters.';
    }
    if(!_isUnique && !_onChanged) {
      return 'This name is already taken. Please choose another one.';
    }
    return null;
  }

  Future<void> _isUsernameUnique(String name) async {
    final username = await db
        .collection('users')
        .where('username', isEqualTo: name)
        .get();

    username.docs.isEmpty ? _isUnique = true : _isUnique = false;
  }


  Future<void> _changePassword(String password) async {
    await _myUser.updatePassword(password).then((_) {
      print('Successfully changed password');
    }).catchError((Object error){
        if(error is FirebaseAuthException) {
          if(error.code == 'requires-recent-login') {
            _retrieveOldPassword();
            var credential = EmailAuthProvider.credential(email: _myUser.email!, password: _oldPassword);

            _myUser.reauthenticateWithCredential(credential)
                .then((_) => print('Re-authenticated'))
                .catchError((Object error) {
                  if(error is FirebaseAuthException) {
                    if (error.code == 'wrong-password') {
                      //TODO show UI
                      print('The password is wrong');
                    }
                  }
            });
          }
          else if(error.code == 'weak-password') {
            print('The password is too weak. Please insert another one.');
          }
          else {
            print('Please try again.' + error.toString());
          }
      }
      else {
        print("Password can't be changed" + error.toString());
      }
    });
  }

  String? _validatePsw(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'The password is too weak. Please insert another one.';
    }
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
                      if(_isNameButton) {
                        _onChanged = false;
                        final form = _nameFormKey.currentState!;

                        if(form.validate() && _isUnique) {
                          if(_newName.isNotEmpty) {
                            _updateUsername(_newName);
                          }
                          setState(() {
                            _status = true;
                          });
                        }
                      }

                      else {
                        final form = _pswFormKey.currentState!;

                        if(form.validate()) {
                          if(_newPassword.isNotEmpty) {
                            _changePassword(_newPassword);
                          }
                          setState(() {
                            _enabled = true;
                          });
                        }
                      }
                        //FocusScope.of(context).requestFocus(FocusNode());
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
