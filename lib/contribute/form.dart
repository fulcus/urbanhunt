import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hunt_app/contribute/place_data.dart';
import 'package:hunt_app/utils/image_helper.dart';
import 'package:hunt_app/utils/validation_helper.dart';
import 'package:image_picker/image_picker.dart';
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
        appBar: AppBar(title: Text('Add new place')),
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
  final ValidationHelper validationHelper = ValidationHelper();
  File? _image;
  final picker = ImagePicker();
  late MultiSelectChip _multiChoice;

  late FocusNode _name, _lockedDescription, _unlockedDescription;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final form = _formKey.currentState!;

    if (form.validate() && _validateImage() && _validateAddress()) {
      form.save();
      data.addPlace();

      print(data.name + data.lockedDescription + data.unlockedDescription);
      //showInSnackBar('Added Place');

      _reset();
      Navigator.of(_formKey.currentState!.context)
          .push(MaterialPageRoute<void>(builder: (_) => ContributeThankYou()));
    } else {
      // Start validating on every change.
      _autoValidateMode = AutovalidateMode.always;
      //_showInSnackBar('Error in form');
      form.save(); // ?
      // only for debugging
      // _reset();
      // Navigator.of(_formKey.currentState!.context)
      //     .push(MaterialPageRoute<void>(builder: (_) => ContributeThankYou()));
    }
  }

  void _reset() {
    Navigator.pushReplacement<void, void>(
      _formKey.currentState!.context,
      MaterialPageRoute<void>(
        builder: (context) => AddPlaceForm(),
      ),
    );
  }

  void _unfocus(BuildContext context) {
    var currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  bool _validateImage() {
    if (_image == null) {
      _showInSnackBar('Please select an image');
    }
    return _image != null;
  }

  bool _validateAddress() {
    if (data.pickedLocation == null) {
      _showInSnackBar('Please select the location');
    }
    return data.pickedLocation != null;
  }

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
    _multiChoice = MultiSelectChip(['Culture', 'Art', 'Nature', 'Food'],
        onSelectionChanged: (selectedList) {
      setState(() {
        data.categories = selectedList;
        _unfocus(context);
      });
    });
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
                  data.name = value!;
                  print('value of name: ' + data.name);
                },
                validator: validationHelper.validatePlaceName,
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
                validator: validationHelper.validateLockedDescr,
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
                validator: validationHelper.validateUnlockedDescr,
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
                onPressed: () => getImage(data),
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
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(color: Colors.blue)))),
              ),
              sizedBoxSpace,
              // todo make address prettier
              data.pickedLocation == null
                  ? Container()
                  : Text(
                      data.pickedLocation!.formattedAddress ?? 'No location'),
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
                  child: const Text('Submit'),
                  onPressed: _handleSubmitted,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  //todo use built in validators https://pub.dev/packages/flutter_form_builder

  Future<void> openLocationPicker(BuildContext context) async {
    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
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
      data.imageURL = await ImageHelper().uploadFile(_image!);
    }
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<String> reportList;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.reportList, {required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  final List<String> _selectedChoices = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
          // prefixIcon: Padding(
          //   padding: EdgeInsets.only(bottom: 10), // add padding to adjust icon
          //   child: Icon(Icons.category_outlined),
          // ),
          icon: const Icon(Icons.category_outlined),
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
    var choices = <Widget>[];

    widget.reportList.forEach((item) {
      choices.add(Container(
        child: ChoiceChip(
          label: Text(item),
          selected: _selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              _selectedChoices.contains(item)
                  ? _selectedChoices.remove(item)
                  : _selectedChoices.add(item);
              widget.onSelectionChanged(_selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }
}
