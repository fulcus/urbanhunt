import 'package:flutter/material.dart';

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
