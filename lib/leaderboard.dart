import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseFirestore.instance;

class LeaderBoard extends StatefulWidget {
  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  late Stream<QuerySnapshot> _users;
  late User _myUser;
  Color _rowColor = Colors.transparent;
  int _position = 0;
  bool _myUserInTop = false; //todo if false add me as last

  @override
  void initState() {
    super.initState();

    _users = db
        .collection('users')
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots(); // get 10 best
    _myUser = FirebaseAuth
        .instance.currentUser!; // check if uid can be shared across widgets
  }

  @override
  Widget build(BuildContext context) {
    var r = const TextStyle(color: Colors.purpleAccent, fontSize: 34);
    return Stack(
      children: <Widget>[
        Scaffold(
            body: Container(
          margin: EdgeInsets.only(top: 65.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15.0, top: 10.0),
                child: RichText(
                    text: TextSpan(
                        text: "Leader",
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                        children: [
                      TextSpan(
                          text: "Board",
                          style: TextStyle(
                              color: Colors.pink,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold))
                    ])),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  'Global Rank Board: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _users,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _position = 0;
                          return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                QueryDocumentSnapshot currListUser =
                                    snapshot.data!.docs[index];
                                QueryDocumentSnapshot prevListUser;
                                print(index);
                                // highlight my user
                                if (currListUser.id == _myUser.uid) {
                                  _rowColor = Colors.lightBlue;
                                  _myUserInTop = true;
                                } else {
                                  _rowColor = Colors.transparent;
                                }
                                if (index >= 1) {
                                  prevListUser = snapshot.data!.docs[index - 1];
                                  if (currListUser.get('score') ==
                                      prevListUser.get('score')) {
                                  } else {
                                    _position++;
                                  }
                                }
                                return LeaderBoardRow(
                                    currListUser.get('username').toString(),
                                    currListUser.get('score').toString(),
                                    _position,
                                    _rowColor);
                              });
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }))
            ],
          ),
        )),
      ],
    );
  }
}

// todo | pos | pic? | username | points |

// Row that contains pic, text, medal, button
class LeaderBoardRow extends StatelessWidget {
  final String username, score;
  final int position;
  final Color rowColor;

  LeaderBoardRow(this.username, this.score, this.position, this.rowColor,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: position == 0
                      ? Colors.amber
                      : position == 1
                          ? Colors.grey
                          : position == 2
                              ? Colors.brown
                              : Colors.white,
                  width: 3.0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(5.0)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                color: rowColor,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 15.0),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                              child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: /*NetworkImage(snapshot.data!.docs[index].get('photoUrl') as String)*/
                                              AssetImage(
                                                  'assets/images/profile.png'),
                                          fit: BoxFit.fill)))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                username,
                                style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w500),
                                maxLines: 6,
                              )),
                          Text("Points: " + score),
                        ],
                      ),
                    ),
                    Flexible(child: Container()),
                    position == 0
                        ? Text('🥇', style: const TextStyle(fontSize: 34))
                        : position == 1
                            ? Text(
                                '🥈',
                                style: const TextStyle(fontSize: 34),
                              )
                            : position == 2
                                ? Text(
                                    '🥉',
                                    style: const TextStyle(fontSize: 34),
                                  )
                                : Text(''),
                    // Padding(
                    //   padding:
                    //       EdgeInsets.only(left: 20.0, top: 13.0, right: 20.0),
                    //   child: RaisedButton(
                    //     onPressed: () {},
                    //     child: Text(
                    //       'Challenge',
                    //       style: TextStyle(
                    //           color: Colors.white, fontWeight: FontWeight.bold),
                    //     ),
                    //     color: Colors.deepPurple,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
