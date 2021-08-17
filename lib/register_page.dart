import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/button_builder.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

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

  String _errorMessage = 'Registration failed';
  bool? _success;
  User? user;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          setState(() {
                            _success = false;
                            _errorMessage = 'Username already exists';
                          });
                        } else {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await _register().then((_) =>
                                  _addUserToDB(_usernameController.text));
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                _success = false;
                                _errorMessage =
                                    e.message ?? 'Registration failed';
                              });
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

  // todo server side check of uniqueness
  Future<bool> _isUsernameUnique(String username) async {
    final username = await db
        .collection('users')
        .where('username', isEqualTo: _usernameController.text)
        .get();
    return username.docs.isEmpty;
  }

  // Example code for registration.
  Future<void> _register() async {
    user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
  }

  //save username to firestore User object and db field
  /*
    await user
        ?.updateDisplayName(_usernameController.text)
        .then((value) => db
            .collection('users')
            .doc(user.uid)
            .update({'username': _usernameController.text}))
        .then((_) {
      setState(() {
        _success = true;
        _userEmail = user.email!;
      });
    }).catchError((Error error) {
      _success = false;
      print(error);
    });
    //upload pic to storage
    //await user?.updatePhotoURL(user.uid); // photoURL is uid
  }
*/

  Future<void> _addUserToDB(String username) async {
    // add username to user object
    //await user!.updateDisplayName(_usernameController.text); // useless

    // add username to database
    await db
        .collection("users")
        .doc(user!.uid)
        .set(<String, dynamic>{'score': 0, 'username': username}).then((_) {
      setState(() {
        _success = true;
      });
    }).catchError((Error error) {
      setState(() {
        _success = false;
        _errorMessage = error.toString();
      });
      print(error.stackTrace);
    });
  }
}
