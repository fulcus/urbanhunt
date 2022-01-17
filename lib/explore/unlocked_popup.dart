import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UnlockedPopup extends StatefulWidget {
  @override
  _UnlockedPopupState createState() => _UnlockedPopupState();
}

class _UnlockedPopupState extends State<UnlockedPopup> {
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15),
          Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Text('You unlocked a new place:'),
          SizedBox(height: 15),
          Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '+ 1 ',
                    style: TextStyle(fontSize: 21),
                  ),
                  Icon(Icons.vpn_key, color: Colors.amber)
                ]),
          ),
          SizedBox(height: 15),
          Container(
            height: 100,
            child: OverflowBox(
              minHeight: 100,
              maxHeight: 100,
              child: Lottie.asset(
                'assets/lottiefiles/unlocked.json',
                repeat: false,
              ),
            )
          ),
          SizedBox(height: 20),
          Divider(
            height: 1,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: InkWell(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
              highlightColor: Colors.grey[200],
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  "Keep Exploring",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}