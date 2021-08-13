import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:place_picker/place_picker.dart';
import 'package:hunt_app/api_key.dart';
import 'package:hunt_app/contribute/thankyou.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class Contribute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: const AddPlaceForm(),
      ),
    );
  }
}

class AddPlaceForm extends StatefulWidget {
  const AddPlaceForm({Key? key}) : super(key: key);

  @override
  AddPlaceFormState createState() => AddPlaceFormState();
}

class AddPlaceFormState extends State<AddPlaceForm> {
  final data = PlaceData();
  File? _image;
  final picker = ImagePicker();

  late FocusNode _name, _lockedDescription, _unlockedDescription;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = FocusNode();
    _lockedDescription = FocusNode();
    _unlockedDescription = FocusNode();
  }

  @override
  void dispose() {
    _name.dispose();
    _lockedDescription.dispose();
    _unlockedDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return GestureDetector(
      onTap: () {
        _unfocus(context);
      },
      child: Form(
        key: _formKey,
        autovalidateMode: _autoValidateMode,
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(height: 70.0),
              Text('Add new place',
                  style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
              SizedBox(height: 44),
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
                  data.name = value!;
                  print('value of name: ' + data.name);
                },
                validator: _validateName,
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
                  data.lockedDescription = value!;
                },
                validator: _validateLockedDescr,
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
                  data.unlockedDescription = value!;
                },
                validator: _validateUnlockedDescr,
              ),
              sizedBoxSpace,
              MultiSelectChip(
                ['Culture', 'Art', 'Nature', 'Food'],
                onSelectionChanged: (selectedList) {
                  setState(() {
                    data.categories = selectedList;
                    _unfocus(context);
                  });
                },
              ),
              sizedBoxSpace,
              Center(
                child: _image == null
                    ? Text('No image selected.')
                    : InkWell(
                  onTap: () {
                    setState(() {
                      _image = null;
                    });
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              sizedBoxSpace,
              TextButton.icon(
                onPressed: () => getImage(data),
                label: Text('Choose a picture'),
                icon: Icon(Icons.add_a_photo),
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
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.blue)))),
              ),
              sizedBoxSpace,
              data.pickedLocation == null
                  ? Container()
                  : Text(
                  data.pickedLocation!.formattedAddress ?? 'No location'),
              sizedBoxSpace,
              TextButton.icon(
                label: Text('Select place location'),
                icon: Icon(Icons.pin_drop),
                onPressed: () => openLocationPicker(context),
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
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.blue)))),
              ),
              sizedBoxSpace,
              Center(
                child: ElevatedButton(
                  child: Text('Submit'),
                  onPressed: _handleSubmitted,
                ),
              ),
              sizedBoxSpace,
            ],
          ),
        ),
      ),
    );
  }

  void _unfocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateMode =
          AutovalidateMode.always; // Start validating on every change.
      showInSnackBar('Error in form');
      form.save(); // ?
      // debugging
      Navigator.of(_formKey.currentState!.context)
          .push(MaterialPageRoute<void>(builder: (_) => ContributeThankYou()));
    } else {
      form.save();
      data.addPlace();
      print(data.name + data.lockedDescription + data.unlockedDescription);
      Navigator.of(_formKey.currentState!.context)
          .push(MaterialPageRoute<void>(builder: (_) => ContributeThankYou()));
      //showInSnackBar('Added Place');
      // todo clear form or something to present brand new form
      form.reset();
      _image = null;
      //todo clear multichoice
    }
  }

  void showInSnackBar(String value) {
    _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  //todo use built in validators https://pub.dev/packages/flutter_form_builder

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

  String? _validateLockedDescr(String? value) {
    if (value == null || value.isEmpty) {
      return 'Locked description is required';
    }
    if (value.length > 150) {
      return 'Locked description is too long, use at most 150 characters';
    }
    return null;
  }

  String? _validateUnlockedDescr(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unlocked description is required';
    }
    if (value.length > 500) {
      return 'Unlocked description is too long, use at most 500 characters';
    }
    return null;
  }

  Future<void> openLocationPicker(BuildContext context) async {
    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            Scaffold(
                primary: true,
                appBar: AppBar(),
                body: PlacePicker(
                  googleMapsApiKey,
                ))));
    setState(() {
      try {
        data.pickedLocation = result!;
        data.location =
            GeoPoint(result.latLng!.latitude, result.latLng!.longitude);
        data.street = result.name!;
        print('formattedAddress: ' + result.formattedAddress!);

        //is street, city, country necessary?

        data.city = result.city!.name!;
        data.country = result.country!.name!;
      } on Exception catch (exception) {
        print(exception);
      }
    });
  }

  Future<void> getImage(PlaceData data) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('No image selected.');
    } else {
      setState(() {
        _image = File(pickedFile.path);
      });
      data.imageURL= await uploadFile(_image!);
    }
  }
}

Future<String> uploadFile(File _image) async {
  var storageReference =
  FirebaseStorage.instance.ref().child('images/${basename(_image.path)}');
  await storageReference.putFile(_image);
  print('File Uploaded');
  var returnURL = '';
  await storageReference.getDownloadURL().then((fileURL) {
    returnURL = fileURL;
  });
  return returnURL;
}

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.reportList, {required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  // String selectedChoice = "";
  //late FocusNode focusNode;
  List<String> selectedChoices = [];

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        /*prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 10), // add padding to adjust icon
            child: Icon(Icons.category_outlined),
          ),*/
          icon: Icon(Icons.category_outlined),
          labelStyle: TextStyle(fontSize: 18, height: 0),
          labelText: 'Select a category',
          border: InputBorder.none),
      child: Wrap(
        children: _buildChoiceList(),
        alignment: WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.spaceEvenly,
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> _buildChoiceList() {
    List<Widget> choices = [];

    widget.reportList.forEach((item) {
      choices.add(Container(
        child: ChoiceChip(
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });

    return choices;
  }
  
  void clearChoices() {
    setState(() {
      selectedChoices.clear();
    });
  }

}
