import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_app/login_page.dart';
import 'package:hunt_app/profile/custom_alert_dialog.dart';
import 'package:hunt_app/utils/image_helper.dart';
import 'package:hunt_app/utils/validation_helper.dart';
import 'package:one_context/one_context.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final ImageHelper imageHelper = ImageHelper();
  final GlobalKey<FormFieldState> _nameFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _pswFormKey = GlobalKey<FormFieldState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
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
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
          appBar: AppBar(title: Text('Profile')),
          body: StreamBuilder<QuerySnapshot>(
              stream: _myUserData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var url = snapshot.data!.docs[0].get('imageURL').toString();
                  var username =
                  snapshot.data!.docs[0].get('username').toString();
                  var countryCode =
                  snapshot.data!.docs[0].get('country').toString();
                  var countryName = CountryParser.parse(countryCode).name;
                  var score = snapshot.data!.docs[0].get('score').toString();



                  return Container(
                    child: ListView(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 230.0,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 30.0),
                                    child: Stack(
                                        fit: StackFit.loose,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                  width: 140.0,
                                                  height: 140.0,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageHelper.showImage(
                                                            url,
                                                            'assets/images/as.png'),
                                                        fit: BoxFit.cover,
                                                      )))
                                            ],
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: 90.0, right: 100.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: <Widget>[
                                                  FloatingActionButton(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                      Colors.white,
                                                      radius: 25.0,
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.indigo,
                                                        size: 26,
                                                      ),
                                                    ),
                                                    onPressed: () async => {
                                                      await getImage(),
                                                      await imageHelper
                                                          .uploadImage(
                                                          _image!, _myUser)
                                                    },
                                                  )
                                                ],
                                              )),
                                        ]),
                                  )
                                ],
                              ),
                            ),

                            Divider(height: 1),

                            Container(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 25.0, right: 25.0, top: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'Personal Information',
                                                  style: TextStyle(
                                                      color: Colors.indigo,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),

                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 25.0, right: 25.0, top: 25.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'Name',
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
                                                child: TextFormField(
                                                  key: _nameFormKey,
                                                  controller: _nameController
                                                    ..text = username,
                                                  decoration: const InputDecoration(
                                                    filled: true,
                                                    hintText: 'Enter Your Name',
                                                  ),
                                                  style: TextStyle(color: Colors.black54),
                                                  enabled: !_status,
                                                  autofocus: !_status,
                                                  autovalidateMode: AutovalidateMode
                                                      .onUserInteraction,
                                                  onChanged: (name) => {
                                                    if (_nameController.text !=
                                                        username)
                                                      {
                                                        _isUsernameUnique(
                                                            _nameController.text),
                                                        _newName =
                                                            _nameController.text,
                                                        _onChanged = true,
                                                      }
                                                  },
                                                  validator: _validateName,
                                                ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                _status
                                                    ? _getEditIcon()
                                                    : Container(),
                                              ],
                                            )
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
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'Email',
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),

                                    //if the user logged with email and password and the mail is not verified button to send verification
                                    if (_isEmailAuth && !_myUser.emailVerified)
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, top: 2.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Flexible(
                                                child: TextField(
                                                  controller:
                                                  TextEditingController()
                                                    ..text = _myUser.email
                                                        .toString(),
                                                  decoration: const InputDecoration(
                                                    filled: true,
                                                  ),
                                                  style: TextStyle(color: Colors.black54),
                                                  //email cannot be changed
                                                  enabled: false,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => {
                                                  _myUser.sendEmailVerification(ActionCodeSettings(url: 'https://hunt-app-ef3f2.firebaseapp.com/__/auth/action', handleCodeInApp: true)),
                                                  _showInSnackBar('A verification email has been sent to your email box.')
                                                },
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.transparent,
                                                  radius: 14.0,
                                                  child: FaIcon(
                                                    FontAwesomeIcons.exclamationCircle,
                                                    color: Color.fromARGB(255,235,82,105),
                                                    size: 20.0,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    if(_isEmailAuth && _myUser.emailVerified || !_isEmailAuth)
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, top: 2.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Flexible(
                                                child: TextField(
                                                  controller:
                                                  TextEditingController()
                                                    ..text = _myUser.email
                                                        .toString(),
                                                  decoration: const InputDecoration(
                                                    filled: true,
                                                  ),
                                                  style: TextStyle(color: Colors.black54),
                                                  //email cannot be changed
                                                  enabled: false,
                                                ),
                                              ),
                                               CircleAvatar(
                                                  backgroundColor: Colors.transparent,
                                                  radius: 14.0,
                                                  child: Icon(
                                                    Icons.verified,
                                                    color: Colors.green[300],
                                                    size: 20.0,
                                                  ),
                                                ),
                                            ],
                                          )),

                                    //if the user is not logged with email and password, the password is not shown
                                    if (_isEmailAuth)
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, top: 25.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    'Password',
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    if (_isEmailAuth)
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0, top: 2.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Flexible(
                                                child: TextFormField(
                                                  key: _pswFormKey,
                                                  controller:
                                                  TextEditingController()
                                                    ..text = '**********',
                                                  decoration: const InputDecoration(
                                                    filled: true,
                                                  ),
                                                  style: TextStyle(color: Colors.black54),
                                                  obscureText: true,
                                                  enabled: !_enabled,
                                                  autofocus: !_enabled,
                                                  autovalidateMode:
                                                  AutovalidateMode
                                                      .onUserInteraction,
                                                  onChanged: (password) =>
                                                  _newPassword = password,
                                                  validator: ValidationHelper()
                                                      .validatePassword,
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  _enabled
                                                      ? _getEditIcon2()
                                                      : Container(),
                                                ],
                                              )
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
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
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
                                                TextEditingController()
                                                  ..text = countryName,
                                                decoration: const InputDecoration(
                                                  filled: true,
                                                  hintText: 'Enter your Country'),
                                                style: TextStyle(color: Colors.black54),
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
                                                    _updateCountry(country.countryCode);
                                                  }),
                                            ),
                                          ],
                                        )),

                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0, top: 25.0),
                                      child: Container(
                                        child: Row(children: [
                                          Text(
                                            'Total Score: ',
                                            style: TextStyle(fontSize: 16,
                                                fontWeight:FontWeight.bold),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Container(
                                              padding: EdgeInsets.only(right: 3.5, left: 3.5, top: 2, bottom: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(color: Colors.amber, width: 2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    score+' ',
                                                    style: GoogleFonts.patrickHand(
                                                      fontSize: 21,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.orange
                                                    ),
                                                  ),
                                                  Icon(Icons.vpn_key, color: Colors.amber)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),

                                    Divider(height: 40),

                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'My Unlocked Places',
                                                  style: TextStyle(
                                                      color: Colors.indigo,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (context) => UnlockedList())),
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.indigo,
                                                    radius: 18.0,
                                                    child: CircleAvatar(
                                                      backgroundColor: Colors.white,
                                                      radius: 17.0,
                                                      child: FaIcon(
                                                        FontAwesomeIcons.unlockAlt,
                                                        color: Colors.indigo,
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )),

                                    Divider(height: 40),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        //LOGOUT button
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 25.0, right: 25.0, top: 25.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                GestureDetector(
                                                    child: Container(
                                                      width: 120.0,
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.indigo),
                                                          borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(16))),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SizedBox(width: 6.0),
                                                          Icon(Icons.exit_to_app,
                                                              color: Colors.indigo),
                                                          SizedBox(width: 4.0),
                                                          Text(
                                                            'Logout',
                                                            style: TextStyle(
                                                              color: Colors.indigo,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              fontSize: 16.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(context, rootNavigator: true)
                                                          .pushAndRemoveUntil(MaterialPageRoute<void>(
                                                          builder: (context) => LoginPage()),
                                                            (route) => false,
                                                      );
                                                    })
                                              ],
                                            )),

                                        //DELETE ACCOUNT BUTTON
                                        Padding(
                                          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              GestureDetector(
                                                  child: Container(
                                                    width: 120.0,
                                                    height: 60.0,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color: Colors.indigo),
                                                        borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(16))),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        SizedBox(width: 6.0),
                                                        Icon(Icons.delete_outline,
                                                            color: Colors.indigo),
                                                        SizedBox(width: 4.0),
                                                        Text(
                                                          'Delete\nAccount',
                                                          style: TextStyle(
                                                            color: Colors.indigo,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    showDialog<dynamic>(
                                                        barrierColor: Colors.black26,
                                                        context: context,
                                                        builder: (context) {
                                                          return CustomAlertDialog(
                                                            title: "Delete account",
                                                            description: "You will lose all your progress.\n"
                                                                "Are you sure to delete your account?\n",
                                                          );
                                                        });
                                                  })
                                            ],
                                          ),
                                        )
                                      ],)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }))
    );
  }

  Future<void> getImage() async {
    await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 20
    ).then((image) async {
      if(image!=null) {
        print("image selected");
        setState(() {
          _image = File(image.path);
        });
      }
      else {
        print("image not selected");
      }
    });
  }

  void _showInSnackBar(String value) {
    _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Container(
        child: Text(value),
        height: 70.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14),
          topLeft: Radius.circular(14),
        ),
      ),
    ));
  }

  void _isEmailAuthProvider() {
    var providerId = _myUser.providerData[0].providerId;

    if (providerId != 'password') {
      _isEmailAuth = false;
    }
  }

  Future<void> _updateCountry(String country) async {
    var data = <String, dynamic>{'country': country};

    return await db.collection('users').doc(_myUser.uid).update(data);
  }

  Future<void> _updateUsername(String username) async {
    var data = <String, dynamic>{'username': username};

    return await db.collection('users').doc(_myUser.uid).update(data);
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }
    if (value.length < 3) {
      return 'Name has to be at least 3 characters long.';
    }
    if (value.length > 20) {
      return 'Name has to be at most 50 characters long.';
    }
    final nameExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphanumeric characters.';
    }
    if (!_isUnique && !_onChanged) {
      return 'This name is already taken. Please choose another one.';
    }
    return null;
  }

  Future<void> _isUsernameUnique(String name) async {
    final username =
        await db.collection('users').where('username', isEqualTo: name).get();

    username.docs.isEmpty ? _isUnique = true : _isUnique = false;
  }

  Future<void> _changePassword(String password) async {
    await _myUser.updatePassword(password).then((_) {
      print('Successfully changed password');
    }).catchError((Object error) {
      if (error is FirebaseAuthException) {
        if (error.code == 'requires-recent-login') {
          _retrieveOldPassword();
          var credential = EmailAuthProvider.credential(
              email: _myUser.email!, password: _oldPassword);

          _myUser
              .reauthenticateWithCredential(credential)
              .then((_) => print('Re-authenticated'))
              .catchError((Object error) {
            if (error is FirebaseAuthException) {
              _showInSnackBar('Unable to change password. Please try again later.');
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
  }

  void _retrieveOldPassword() {
    var controller = TextEditingController();

    OneContext().showDialog<void>(
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
    _nameController.dispose();
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
                  primary: Colors.green[300],
                  textStyle: TextStyle(color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: () {
                  if (_isNameButton) {
                    _onChanged = false;
                    final form = _nameFormKey.currentState!;

                    if (form.validate() && _isUnique) {
                      if (_newName.isNotEmpty) {
                        _updateUsername(_newName);
                      }
                      setState(() {
                        _status = true;
                      });
                    }
                  } else {
                    final form = _pswFormKey.currentState!;

                    if (form.validate()) {
                      if (_newPassword.isNotEmpty) {
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
                  primary: Color.fromARGB(255,235,82,105),
                  textStyle: TextStyle(color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                onPressed: () {
                  setState(() {
                    _isNameButton ? _status = true : _enabled = true;
                    FocusScope.of(context).requestFocus(FocusNode());
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
      onTap: () {
        setState(() {
          _isNameButton = true;
          _status = false;
          _enabled = true;
        });
      },
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 14.0,
      child: Icon(
          Icons.edit,
          color: Colors.black87,
        size: 20.0,
        ),
      ),
    );
  }

  Widget _getEditIcon2() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isNameButton = false;
          _status = true;
          _enabled = false;
        });
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.black87,
          size: 20.0,
        ),
      ),
    );
  }
}
