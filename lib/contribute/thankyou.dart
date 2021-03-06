import 'package:flutter/material.dart';

class ContributeThankYou extends StatelessWidget {
  const ContributeThankYou({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
        child: Column(
          children: [
            Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/locks-pattern-cropped.jpg'),
                  SizedBox(height: 12),
                  ListTile(
                    //leading: Icon(Icons.arrow_drop_down_circle),
                    title: const Text('Thank you for contributing to UrbanHunt!',
                        style: TextStyle(fontSize: 26),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 13),
                  Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '+ 5 ',
                            style: TextStyle(fontSize: 21),
                          ),
                          Icon(Icons.vpn_key, color: Colors.amber)
                        ]),
                  ),
                  SizedBox(height: 26),
                ],
              ),
            ),
            SizedBox(height: 28),
            ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.add),
                label: Text('Add more'),
                style: ButtonStyle(
                  //elevation: MaterialStateProperty.all<double>(10),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 20)),
                    overlayColor: MaterialStateProperty.resolveWith(
                          (states) {
                        return states.contains(MaterialState.pressed)
                            ? Colors.blue[50]
                            : null;
                      },
                    ),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.indigo),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          //side: BorderSide(color: Colors.blue)
                        )))),
          ],
        ),
      ),
    );
  }
}
