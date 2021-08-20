import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late Stream<QuerySnapshot> _bestUsers;
  late User _myUser;
  Color _rowColor = Colors.transparent;
  int _position = 0;
  bool _myUserInTop = false; //todo if false add me as last

  @override
  void initState() {
    super.initState();

    // get 10 best players
    _bestUsers = db
        .collection('users')
        .orderBy('score', descending: true)
        .limit(5)
        .snapshots();
    _myUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
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
                        text: 'Leader',
                        style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                        children: [
                      TextSpan(
                          text: 'Board',
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
                      stream: _bestUsers,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _position = 0;
                          return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var currListUser = snapshot.data!.docs[index];
                                QueryDocumentSnapshot prevListUser;
                                print(index);
                                // highlight my user
                                if (currListUser.id == _myUser.uid) {
                                  _rowColor = Colors.orangeAccent;
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
                                    currListUser.get('imageURL').toString(),
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

// Row of leaderboard that contains pic, text, medal, button
class LeaderBoardRow extends StatelessWidget {
  final String username, imageURL, score;
  final int position;
  final Color rowColor;
  
// currListUser.get('username').toString(),
// currListUser.get('imageURL').toString(),
// currListUser.get('score').toString(),
// _position,
// _rowColor);
  LeaderBoardRow(
      this.username, this.imageURL, this.score, this.position, this.rowColor,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: rowColor,
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
              borderRadius: BorderRadius.circular(50.0)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  position == 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 7, right: 4),
                          child:
                              Text('🥇', style: const TextStyle(fontSize: 34)),
                        )
                      : position == 1
                          ? Padding(
                              padding: const EdgeInsets.only(left: 7, right: 4),
                              child: Text('🥈',
                                  style: const TextStyle(fontSize: 34)),
                            )
                          : position == 2
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, right: 4),
                                  child: Text('🥉',
                                      style: const TextStyle(fontSize: 34)),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Text((position + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 1
                                          ..color = Colors.blue[700]!,
                                      ))),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: getImage(imageURL),
                                        fit: BoxFit.fill)))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
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
                              maxLines: 2,
                            ))
                      ],
                    ),
                  ),
                  Flexible(child: Container()),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          score,
                          style: TextStyle(fontSize: 21),
                        ),
                      ),
                      Icon(Icons.vpn_key, color: Colors.amber)
                    ]),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider getImage(String url) {
    ImageProvider imageProvider = AssetImage('assets/images/profile.png');
    if (url != '') {
      imageProvider = NetworkImage(url);
    }
    return imageProvider;
  }
}
