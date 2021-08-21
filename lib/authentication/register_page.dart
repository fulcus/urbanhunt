import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'network.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;

/// Entrypoint example for registering via Email/Password.
class RegisterPage extends StatefulWidget {
  /// The page title.
  final String title = 'Registration';

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final picker = ImagePicker();

  String _errorMessage = 'Registration failed';
  bool? _success;
  User? user;
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      if (value.contains(' ')) {
                        return 'No spaces allowed in username';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: _image == null
                        ? const Text('No image selected.')
                        : Stack(
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: 200,
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      setState(() {
                                        _image = null;
                                      });
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => getImage(),
                    label: const Text('Choose a picture'),
                    icon: const Icon(Icons.add_a_photo),
                    style: ButtonStyle(
                        //elevation: MaterialStateProperty.all<double>(10),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        overlayColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.pressed)
                                ? Colors.blue[50]
                                : null;
                          },
                        ),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue[800]!),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    side: BorderSide(color: Colors.blue)))),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: SignInButtonBuilder(
                      icon: Icons.person_add,
                      backgroundColor: Colors.blueGrey,
                      onPressed: () async {
                        var isUnique =
                            await _isUsernameUnique(_usernameController.text);
                        if (!isUnique) {
                          printErrorMessage('Username already exists');
                        } else {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await _register().then((_) =>
                                  _addUserToDB(_usernameController.text));
                              await uploadFile(_image!);
                            } on FirebaseAuthException catch (e) {
                              printErrorMessage(e.message!);
                              print('Failed with error code: ${e.code}');
                              print(e.message);
                            }
                          }
                        }
                      },
                      text: 'Register',
                    ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(_success == null
                          ? ''
                          : (_success!
                              ? 'Successfully registered'
                              : _errorMessage)))
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> uploadFile(File image) async {
    try {
      var path = '${user!.uid}${extension(image.path)}';
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
          .doc(user!.uid)
          .update({'imageURL': returnURL});
      print('URL stored');
    } on FirebaseException catch (e) {
      printErrorMessage(e.message!);
      print(e.stackTrace);
    }
  }

  // todo server side check of uniqueness
  Future<bool> _isUsernameUnique(String username) async {
    final username = await db
        .collection('users')
        .where('username', isEqualTo: _usernameController.text)
        .get();
    return username.docs.isEmpty;
  }

  Future<void> _register() async {
    user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
  }

  Future<void> _addUserToDB(String username) async {
    try {
      var myCountry = await getCountry();
      await db.collection("users").doc(user!.uid).set(<String, dynamic>{
        'imageURL': '',
        'score': 0,
        'username': username,
        'country' : myCountry
      }).then((_) {
        setState(() {
          _success = true;
        });
      });
    } on Exception catch (e) {
      printErrorMessage(e.toString());
      print(e);
    }
  }

  void printErrorMessage(String message) {
    setState(() {
      _success = false;
      _errorMessage = message;
    });
  }
}
