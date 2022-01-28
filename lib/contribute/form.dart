import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/api_key.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/utils/image_helper.dart';
import 'package:hunt_app/utils/misc.dart';
import 'package:hunt_app/utils/validation_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:place_picker/place_picker.dart';

import 'multiselect.dart';
import 'thankyou.dart';

class Contribute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new place')),
      body: const AddPlaceForm(),
    );
  }
}

class AddPlaceForm extends StatefulWidget {
  const AddPlaceForm({Key? key}) : super(key: key);

  @override
  AddPlaceFormState createState() => AddPlaceFormState();
}

class AddPlaceFormState extends State<AddPlaceForm> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();
  final _textFieldController1 = TextEditingController();
  final _textFieldController2 = TextEditingController();
  final _textFieldController3 = TextEditingController();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  late FocusNode _name, _lockedDescription, _unlockedDescription;

  final picker = ImagePicker();
  final ValidationHelper validationHelper = ValidationHelper();

  File? _image;
  String? name, lockedDescription, unlockedDescription;
  List<String>? categories;
  LocationResult? pickedLocation;

  final User _myUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _name = FocusNode();
    _lockedDescription = FocusNode();
    _unlockedDescription = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    var _multiChoice = MultiSelectChip(['Culture', 'Art', 'Nature', 'Food'],
        onSelectionChanged: (selectedList) {
      setState(() {
        categories = selectedList;
        _unfocus(context);
      });
    });

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            _unfocus(context);
          },
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: Scrollbar(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  SizedBox(height: 35),
                  TextFormField(
                    focusNode: _name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.place_outlined),
                      hintText: 'Add name',
                      //helperText: 'Name of the new place',
                      labelText: 'Name',
                    ),
                    onSaved: (value) {
                      name = value!;
                    },
                    validator: validationHelper.validatePlaceName,
                    controller: _textFieldController1,
                  ),
                  sizedBoxSpace,
                  TextFormField(
                    focusNode: _lockedDescription,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.lock_outline),
                      hintText: 'Add short description',
                      //helperText: 'Short description shown when place is locked',
                      labelText: 'Locked place description',
                    ),
                    maxLines: 1,
                    onSaved: (value) {
                      lockedDescription = value!;
                    },
                    validator: validationHelper.validateLockedDescr,
                    controller: _textFieldController2,
                  ),
                  sizedBoxSpace,
                  TextFormField(
                    focusNode: _unlockedDescription,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.lock_open_outlined),
                      hintText: 'Add long description',
                      //helperText: 'Full description of the place',
                      labelText: 'Unlocked place description',
                    ),
                    maxLines: 3,
                    onSaved: (value) {
                      unlockedDescription = value!;
                    },
                    validator: validationHelper.validateUnlockedDescr,
                    controller: _textFieldController3,
                  ),
                  sizedBoxSpace,
                  _multiChoice,
                  sizedBoxSpace,
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
                                      _image = null;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    // color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  sizedBoxSpace,
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
                                ? Colors.indigo[50]
                                : null;
                          },
                        ),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.indigo),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side: BorderSide(color: Colors.indigo)))),
                  ),
                  sizedBoxSpace,
                  // TODO make address prettier
                  pickedLocation == null
                      ? Container()
                      : Text(pickedLocation!.formattedAddress ?? 'No location'),
                  sizedBoxSpace,
                  TextButton.icon(
                    label: const Text('Select place location'),
                    icon: const Icon(Icons.pin_drop),
                    onPressed: () => openLocationPicker(context),
                    style: ButtonStyle(
                        //elevation: MaterialStateProperty.all<double>(10),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                        overlayColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.pressed)
                                ? Colors.indigo[50]
                                : null;
                          },
                        ),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.indigo),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side: BorderSide(color: Colors.indigo)))),
                  ),
                  sizedBoxSpace,
                  Center(
                    child: ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _lockedDescription.dispose();
    _unlockedDescription.dispose();
    _textFieldController1.dispose();
    _textFieldController2.dispose();
    _textFieldController3.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitted() async {
    final form = _formKey.currentState!;

    if (isEmailAuthProvider(_myUser) && !_myUser.emailVerified) {
      showInSnackBar('Please verify your email first.', _scaffoldMessengerKey,
          height: 70.0);
    } else {
      if (form.validate() && _validateImage() && _validateLocation()) {
        form.save();

        var imageURL = await ImageHelper().uploadFile(_image!);
        var creatorId = FirebaseAuth.instance.currentUser!.uid;
        var data = PlaceData(name!, lockedDescription!, unlockedDescription!,
            imageURL, creatorId, categories!, pickedLocation!);
        data.upload();

        print('Added place');
        print(
            '$name, $lockedDescription, $unlockedDescription, $pickedLocation, '
            '$categories');

        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => Contribute(),
          ),
        );

        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (context) => ContributeThankYou()));
      } else {
        // Start validating on every change.
        _autoValidateMode = AutovalidateMode.always;
        //_showInSnackBar('Error in form');
        form.save();
      }
    }
  }

  void _unfocus(BuildContext context) {
    var currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  bool _validateImage() {
    if (_image == null) {
      showInSnackBar('Please select an image', _scaffoldMessengerKey,
          height: 70.0);
      return false;
    } else {
      return true;
    }
  }

  bool _validateLocation() {
    if (pickedLocation == null) {
      showInSnackBar('Please select the location', _scaffoldMessengerKey,
          height: 70.0);
    }
    return pickedLocation != null;
  }

  Future<void> openLocationPicker(BuildContext context) async {
    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
            primary: true,
            appBar: AppBar(),
            body: PlacePicker(
              googleMapsApiKey,
            ))));
    setState(() {
      pickedLocation = result!;
    });
  }

  Future<void> getImage() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 20)
        .then((image) async {
      if (image != null) {
        print("image selected");
        setState(() {
          _image = File(image.path);
        });
      } else {
        print("image not selected");
      }
    });
  }
}
