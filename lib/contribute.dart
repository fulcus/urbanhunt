import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
 * name: Text
 * lockedDescr: Text
 * unlockedDescr: Text
 * categories: Options
 * address*: Text
 * pick location: Widget
 * load image: Widget
 */
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Contribute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: Padding(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: const AddPlaceForm()),
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
  var data = PlaceData();

  //late FocusNode _name, _lockedDescr, _unlockedDescr;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /*
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
  }*/

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateMode =
          AutovalidateMode.always; // Start validating on every change.
      showInSnackBar('Error in form');
    } else {
      form.save();
      //addPlace(data);
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
            //sizedBoxSpace,
            Text('Add A Place',
                style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
            SizedBox(height: 44),

            //sizedBoxSpace,
            TextFormField(
              //focusNode: _name,
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
              },
              validator: _validateName,
            ),
            sizedBoxSpace,
            FormBuilderChoiceChip(
              name: 'choice_chip',
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Select a category',
              ),
              options: [
                FormBuilderFieldOption(value: 'Culture', child: Text('Culture')),
                FormBuilderFieldOption(value: 'Nature', child: Text('Nature')),
                FormBuilderFieldOption(value: 'Art', child: Text('Art')),
                FormBuilderFieldOption(value: 'Sport', child: Text('Sport')),
              ],
            ),
            sizedBoxSpace,
            TextFormField(
              //focusNode: _lockedDescr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                filled: true,
                icon: const Icon(Icons.lock_outline),
                hintText: 'Might help out when thirsty of adventures',
                helperText: 'Short description shown when place is locked',
                labelText: 'Locked description',
              ),
              onSaved: (value) {
                data.lockedDescr = value!;
              },
              validator: _validateLockedDescr,
              maxLines: 1,
            ),
            sizedBoxSpace,
            TextFormField(
              //focusNode: _unlockedDescr,
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

  Future<void> addPlace(PlaceData placeData) async {
    int zip = 20100, dislikes = 0, likes = 0;
    double latitude = 45.485044, longitude = 9.202816;

    var city = 'Milan',
        state = 'Italy',
        street = 'Piazza Duca d\'Aosta, 1',
        imgpath = 'images/secret_door',
        lockedDescr = 'Some interesting facts',
        unlockedDescr = 'Less interesting facts',
        name = 'Secret Door',
        location = GeoPoint(latitude, longitude);
    var categories = ['culture'];

    var places = FirebaseFirestore.instance.collection('places');
    var data = <String, dynamic>{
      'address': {'zip': zip, 'city': city, 'state': state, 'street': street},
      'categories': categories,
      'imgpath': imgpath,
      'lockedDescr': placeData.lockedDescr,
      'unlockedDescr': placeData.unlockedDescr,
      'name': placeData.name,
      'dislikes': dislikes,
      'location': location,
      'likes': likes
    };

    await places.add(data);
  }
}

class PlaceData {
  late int zip;
  late double latitude, longitude;
  late String city, state, street, imgpath, lockedDescr, unlockedDescr, name;
  late GeoPoint location; // vedere se passare GeoLoc vs long lat
  late List<String> categories = [];
}
