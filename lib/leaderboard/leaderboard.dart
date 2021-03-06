import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunt_app/auth/login_page.dart';
import 'package:hunt_app/utils/image_helper.dart';
import 'package:hunt_app/utils/keep_alive_builder.dart';


class LeaderBoard extends StatelessWidget {
  final User loggedUser;
  final FirebaseFirestore db;

  LeaderBoard(this.loggedUser, this.db, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.public)),
              Tab(icon: Icon(Icons.near_me_outlined)),
            ],
          ),
          title: const Text('Leaderboard'),
        ),
        body: TabBarView(
          children: [
            GlobalLeaderBoard(loggedUser, db),
            CountryLeaderBoard(loggedUser, db),
          ],
        ),
      ),
    );
  }
}

class CountryLeaderBoard extends StatefulWidget {
  final User loggedUser;
  final FirebaseFirestore db;

  CountryLeaderBoard(this.loggedUser, this.db);

  @override
  _CountryLeaderBoardState createState() => _CountryLeaderBoardState();
}

class _CountryLeaderBoardState extends State<CountryLeaderBoard> {
  Stream<QuerySnapshot>? _bestUsers;
  Color _rowColor = Colors.transparent;
  int _position = 0;
  String? myCountry;
  // bool _myUserInTop = false; //todo if false add me as last

  Future<String> getCountry() async {
    var doc = await widget.db.collection('users').doc(widget.loggedUser.uid).get();
    return doc['country'].toString();
  }

  Future<Stream<QuerySnapshot<Object?>>> getBestUsers() async {
    myCountry = await getCountry();
    var users = widget.db
        .collection('users')
        .where('country', isEqualTo: myCountry)
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots();
    return users;
  }

  @override
  void initState() {
    super.initState();
    (getBestUsers().then((users) => _bestUsers = users)).whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            body: Container(
          margin: EdgeInsets.only(top: 40.0, bottom: 55.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: isMobile ? const EdgeInsets.symmetric(horizontal: 25) : const EdgeInsets.symmetric(horizontal: 75),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Flag.fromString('$myCountry', height: 20, width: 20),
                          )
                        ],
                      ),
                    ),
                    Text(
                      ' $myCountry Rank Board: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )
                  ],
                )
              ),
              Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _bestUsers,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && _bestUsers != null) {
                          _position = 0;
                          return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var currListUser = snapshot.data!.docs[index];
                                QueryDocumentSnapshot prevListUser;
                                // highlight my user
                                if (currListUser.id == widget.loggedUser.uid) {
                                  _rowColor = Colors.indigo[50]!;
                                  // _myUserInTop = true;
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

                                /*var users = snapshot.data!.docs;
                                Iterable<QueryDocumentSnapshot<Object?>> topUsers;
                                if(users.length > 50) {
                                  topUsers = users.getRange(0, 50);
                                }
                                else{
                                  topUsers = users;
                                }
                                List<String> topUsersIds = List.empty(growable: true);
                                for(QueryDocumentSnapshot<Object?> user in topUsers) {
                                  topUsersIds.add(user.id);
                                }
                                if(topUsersIds.contains(myUser.uid)) {
                                  _myUserInTop = true;
                                }*/

                                return KeepAliveBuilder(
                                    child: LeaderBoardRow(
                                        currListUser.get('username').toString(),
                                        currListUser.get('imageURL').toString(),
                                        currListUser.get('score').toString(),
                                        currListUser.get('country').toString(),
                                        _position,
                                        _rowColor,
                                        false)
                                );
                              });
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })),
            ],
          ),
        )),
      ],
    );
  }
}

class GlobalLeaderBoard extends StatefulWidget {
  final User loggedUser;
  final FirebaseFirestore db;

  GlobalLeaderBoard(this.loggedUser, this.db);

  @override
  _GlobalLeaderBoardState createState() => _GlobalLeaderBoardState();
}

class _GlobalLeaderBoardState extends State<GlobalLeaderBoard> {
  late Stream<QuerySnapshot> _bestUsers;
  Color _rowColor = Colors.transparent;
  int _position = 0;
  // bool _myUserInTop = false; //todo if false add me as last

  @override
  void initState() {
    super.initState();

    // get 10 best players
    _bestUsers = widget.db
        .collection('users')
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            body: Container(
              margin: EdgeInsets.only(top: 40.0, bottom: 55.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: isMobile ? EdgeInsets.only(left: 25.0, bottom: 4.0) : EdgeInsets.only(left: 75.0, bottom: 4.0),
                    child: Text(
                      '???? Global Rank Board: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                                    // highlight my user
                                    if (currListUser.id == widget.loggedUser.uid) {
                                      _rowColor = Colors.indigo[50]!;
                                      // _myUserInTop = true;
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
                                    return KeepAliveBuilder(
                                        child: LeaderBoardRow(
                                            currListUser.get('username').toString(),
                                            currListUser.get('imageURL').toString(),
                                            currListUser.get('score').toString(),
                                            currListUser.get('country').toString(),
                                            _position,
                                            _rowColor,
                                            true)
                                    );
                                  });
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          })),
                ],
          ),
        )),
      ],
    );
  }
}

// Row of leaderboard that contains pic, text, medal, button
class LeaderBoardRow extends StatelessWidget {
  final String username, imageURL, score, country;
  final int position;
  final Color rowColor;
  final bool isGlobal;

  LeaderBoardRow(
      this.username, this.imageURL, this.score, this.country, this.position, this.rowColor, this.isGlobal,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobile ? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0) : const EdgeInsets.symmetric(horizontal: 70.0, vertical: 3.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: rowColor,
              border: Border.all(
                  color: position == 0
                      ? Colors.amber
                      : position == 1
                          ? Color.fromARGB(255,192,192,192)
                          : position == 2
                              ? Color.fromARGB(255,176,141,87)
                              : Colors.white,
                  width: 2.0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16.0)),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  position == 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 7, right: 4),
                          child:
                              Text('????', style: const TextStyle(fontSize: 34)),
                        )
                      : position == 1
                          ? Padding(
                              padding: const EdgeInsets.only(left: 7, right: 4),
                              child: Text('????',
                                  style: const TextStyle(fontSize: 34)),
                            )
                          : position == 2
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(left: 7, right: 4),
                                  child: Text('????',
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
                                          ..color = Colors.indigo[700]!,
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
                                        image: ImageHelper().showImage(imageURL, 'assets/images/default-profile.png'),
                                        fit: BoxFit.cover)))),
                      ],
                    ),
                  ),
                  if(isGlobal)
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Flag.fromString(country, height: 20, width: 20),
                        )
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
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                            ))
                      ],
                    ),
                  ),
                  Flexible(child: Container()),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Container(
                            padding: EdgeInsets.only(right: 3.5, left: 3.5, top: 2, bottom: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.amber, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  score+' ',
                                  style: GoogleFonts.supermercadoOne(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange
                                  ),
                                ),
                                Icon(Icons.vpn_key, color: Colors.amber)
                              ],
                            ),
                          ),
                        ),
                    ),
                  ),
            ],),
          ],),
       ),
      )
    );
  }

}
