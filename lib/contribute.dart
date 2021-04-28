import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'api_key.dart';

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
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  @override
  AddPlaceFormState createState() => AddPlaceFormState();
}

class AddPlaceFormState extends State<AddPlaceForm> {
  final data = PlaceData();
  File? _image;
  final picker = ImagePicker();

  late FocusNode _name, _lockedDescr, _unlockedDescr;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = FocusNode();
    _lockedDescr = FocusNode();
    _unlockedDescr = FocusNode();
  }

  @override
  void dispose() {
    _name.dispose();
    _lockedDescr.dispose();
    _unlockedDescr.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateMode =
          AutovalidateMode.always; // Start validating on every change.
      showInSnackBar('Error in form');
      form.save();
      print(data.categories.toString());
    } else {
      form.save();
      addPlace(data);
      print(data.name + data.lockedDescr + data.unlockedDescr);
      showInSnackBar('Added Place');
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
    /*final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters';
    }*/
    if (value.length > 150) {
      return 'Locked description is too long, use at most 150 characters';
    }
    return null;
  }

  String? _validateUnlockedDescr(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unlocked description is required';
    }
    /*final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters';
    }*/
    if (value.length > 500) {
      return 'Unlocked description is too long, use at most 500 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    return Form(
      key: _formKey,
      autovalidateMode: _autoValidateMode,
      child: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            SizedBox(height: 70.0),
            Text('Add A Place',
                style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
            SizedBox(height: 44),
            TextFormField(
              focusNode: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                filled: true,
                icon: const Icon(Icons.place_outlined),
                hintText: 'Mysterious Fountain',
                helperText: 'Name of the new place',
                labelText: 'Name',
              ),
              onSaved: (value) {
                data.name = value!;
                print('value of name: ' + data.name);
              },
              validator: _validateName,
            ),
            sizedBoxSpace,
            MultiSelectChip(
              ['Culture', 'Art', 'Nature', 'Food'],
              onSelectionChanged: (selectedList) {
                setState(() {
                  data.categories = selectedList;
                });
              },
            ),

            /*
            FormBuilderCheckboxGroup(
              name: 'category_selector',
              //alignment: WrapAlignment.spaceEvenly,
              //crossAxisAlignment: WrapCrossAlignment.center,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 100), // add padding to adjust icon
                  child: Icon(Icons.category_outlined),
                ),
                //icon: Icon(Icons.category_outlined),
                labelStyle: TextStyle(),
                border: InputBorder.none,
                labelText: 'Select categories',
              ),
              options: [
                FormBuilderFieldOption(
                    value: 'Culture', child: Text('Culture')),
                FormBuilderFieldOption(value: 'Nature', child: Text('Nature')),
                FormBuilderFieldOption(value: 'Art', child: Text('Art')),
                FormBuilderFieldOption(value: 'Sport', child: Text('Sport')),
              ],
              onSaved: (value) {
                data.categories = value as List<String>;
                //print('value of categories: ' + value.toString() + value.runtimeType.toString());
              },
            ),*/
            sizedBoxSpace,
            TextFormField(
              focusNode: _lockedDescr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                filled: true,
                icon: const Icon(Icons.lock_outline),
                hintText: 'Might help out when thirsty of adventures',
                helperText: 'Short description shown when place is locked',
                labelText: 'Locked description',
              ),
              maxLines: 1,
              onSaved: (value) {
                data.lockedDescr = value!;
              },
              validator: _validateLockedDescr,
            ),
            sizedBoxSpace,
            TextFormField(
              focusNode: _unlockedDescr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                filled: true,
                icon: const Icon(Icons.lock_open_outlined),
                hintText: 'This fountain was built in 1891 by bla bla bla...',
                helperText: 'Full description of the place',
                labelText: 'Unlocked description',
              ),
              maxLines: 3,
              onSaved: (value) {
                data.unlockedDescr = value!;
              },
              validator: _validateUnlockedDescr,
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
            ElevatedButton.icon(
              onPressed: getImage,
              label: Text('Choose a picture'),
              icon: Icon(Icons.add_a_photo),
            ),
            sizedBoxSpace,
            ElevatedButton.icon(
              label: Text('Select place location'),
              icon: Icon(Icons.pin_drop),
              onPressed: () => openLocationPicker(context),
            ),
            sizedBoxSpace,
            data.selectedLocation == null
                ? Container()
                : Text(data.selectedLocation!.formattedAddress ?? ''),
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
    );
  }

  void openLocationPicker(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
            body: PlacePicker(
              apiKey: googleMapsApiKey,
              initialPosition: AddPlaceForm.kInitialPosition,
              useCurrentLocation: true,
              selectInitialPosition: true,

              //usePlaceDetailSearch: true,
              onPlacePicked: (result) {
                data.selectedLocation = result;
                data.location = GeoPoint(result.geometry!.location.lat, result.geometry!.location.lng);
                Navigator.of(context).pop();
                print('print location: ');
                print(data.selectedLocation!.geometry!.location);
                //setState(() {});
              },
              //forceSearchOnZoomChanged: true,
              //automaticallyImplyAppBarLeading: false,
              //autocompleteLanguage: "ko",
              //region: 'au',
              //selectInitialPosition: true,
              // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
              //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
              //   return isSearchBarFocused
              //       ? Container()
              //       : FloatingCard(
              //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
              //           leftPosition: 0.0,
              //           rightPosition: 0.0,
              //           width: 500,
              //           borderRadius: BorderRadius.circular(12.0),
              //           child: state == SearchingState.Searching
              //               ? Center(child: CircularProgressIndicator())
              //               : RaisedButton(
              //                   child: Text("Pick Here"),
              //                   onPressed: () {
              //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
              //                     //            this will override default 'Select here' Button.
              //                     print("do something with [selectedPlace] data");
              //                     Navigator.of(context).pop();
              //                   },
              //                 ),
              //         );
              // },
              // pinBuilder: (context, state) {
              //   if (state == PinState.Idle) {
              //     return Icon(Icons.favorite_border);
              //   } else {
              //     return Icon(Icons.favorite);
              //   }
              // },
            ),
          );
        },
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> addPlace(PlaceData placeData) async {
    var places = FirebaseFirestore.instance.collection('places');
    var imageURL = await uploadFile(_image!); // should put this somewhere else and assign placeData.imgpath

    int zip = 20100;

    var city = 'Milan',
        state = 'Italy',
        street = 'Piazza Duca d\'Aosta, 1';

    var data = <String, dynamic>{
      'address': {'zip': zip, 'city': city, 'state': state, 'street': street},
      'categories': placeData.categories,
      'imgpath': imageURL,
      'lockedDescr': placeData.lockedDescr,
      'unlockedDescr': placeData.unlockedDescr,
      'name': placeData.name,
      'dislikes': 0,
      'location': placeData.location,
      'likes': 0
    };

    await places.add(data);
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
}

class PlaceData {
  late PickResult? selectedLocation = null;
  late int zip;
  late double latitude, longitude;
  late String city, state, street, imgpath, lockedDescr, unlockedDescr, name;
  late GeoPoint location;
  late List<String> categories = [];
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
  List<String> selectedChoices = [];

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

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
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
}
