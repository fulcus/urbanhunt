import 'package:flutter/material.dart';


Map<String, Color> categoryColors = {};


class PlaceData {
  final int id;
  final String name;
  final List<String> categories;  // tags
  
  final String descriptionUnlocked;
  final String descriptionLocked;
  
  final String imagePathUnlocked;
  final String imagePathLocked;

  final String address;
  final double latitude;
  final double longitude;

  const PlaceData({this.id, this.name, this.categories,
                   this.descriptionLocked, this.descriptionUnlocked,
                   this.imagePathLocked, this.imagePathUnlocked,
                   this.address, this.latitude, this.longitude});
  
  // Proof of Concept:
  // non-const attributes fetch their value every time.
  // As a result, they are always up-to-date (eventually some cache management if costly).
  
  int likes() {
    // return db.query("places", this.id, "numLikes");
    return 4;
  }

  int dislikes() {
    return 1;
  }
  
  double distanceKm() {
    // userId = backend.getCurUserId();
    // var (userLat, userLong) = db.query("users", user.id, "curCoords");
    // return api.distance(userLat, userLong, latitude, longitude);
    return 1.425623;  // to be rounded and string-formatted
  }

}


class PlacePage extends StatefulWidget {

  final PlaceData placeData;

  const PlacePage({
    Key key,
    @required this.placeData,
  }): super(key: key);

  @override
  _PlacePageState createState() => _PlacePageState();
}


class _PlacePageState extends State<PlacePage> {

  bool _isLocked = true;
  bool _isLiked = false;
  bool _isDisliked = false;

  void unlock() {
    setState(() {
      _isLocked = false;
    });
  }

  void like() {
    setState(() {
      _isLiked = !_isLiked;
      _isDisliked = false;
      // backend num likes/dislikes update
      // ...
    });
  }

  void dislike() {
    setState(() {
      _isDisliked = !_isDisliked;
      _isLiked = false;
      // backend num likes/dislikes update
      // ...
    });
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    PlaceData placeData = widget.placeData;

    String imagePath;
    String description;

    if (_isLocked) {
      imagePath = placeData.imagePathLocked;
      description = placeData.descriptionLocked;
    } else {
      imagePath = placeData.imagePathUnlocked;
      description = placeData.descriptionUnlocked;
    }

    Icon likeIcon = Icon(Icons.arrow_drop_up, color: _isLiked ? Colors.green[600] : Colors.grey[400]);
    Icon dislikeIcon = Icon(Icons.arrow_drop_down, color: _isDisliked ? Colors.red[600] : Colors.grey[400]);

    List<Widget> tags = [];

    for (int i = 0; i < placeData.categories.length; i++) {
      tags.add(
        Container(
          margin: EdgeInsets.only(right: 6.0),
          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
          child: Text(placeData.categories[i], style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: Colors.white)),
          decoration: BoxDecoration(
            color: categoryColors[placeData.categories[i]] ?? Colors.blue[300],
            borderRadius: BorderRadius.circular(12.0),
          ),
        )
      );
    }

    // Topbar (arrow back to prev page)
    Widget topbar = Container(
      margin: EdgeInsets.only(top: 32.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      height: 56.0,
      child: Row(
        children: <Widget>[
          IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.pop(context);
          }),
          Spacer(),
          // other icons...
        ],
      ),
    );

    // Content
    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Sep
          SizedBox(height: 8.0),
          // Image
          Center(child: Image.asset(imagePath, width: width)),
          // Sep
          SizedBox(height: 4.0),
          // Below Image: Like/Dislike and Category tags
          Row(
            children: <Widget>[
              // Like Dislike stats
              GestureDetector(onTap: like, child: likeIcon),
              Text((placeData.likes() + (_isLiked ? 1: 0)).toString(), style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.green[600])),
              SizedBox(width: 4.0),
              GestureDetector(onTap: dislike, child: dislikeIcon),
              Text((placeData.dislikes() + (_isDisliked ? 1: 0)).toString(), style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.red[600])),
              // Sep
              Spacer(),
              // Category tags
              Row(children: tags),
            ],
          ),
          // Sep
          SizedBox(height: 4.0),
          // Name
          Text(placeData.name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900)),
          // Sep
          SizedBox(height: 4.0),
          // Address
          Text(placeData.address, style: TextStyle(fontSize: 14.0)),
          // Sep
          SizedBox(height: 4.0),
          // Distance
          Text(placeData.distanceKm().toStringAsFixed(2) + " km", style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w900, color: Colors.black45)),
          // Sep
          SizedBox(height: 8.0),
          // Description
          Text(description, style: TextStyle(fontSize: 12.0)),
          // Sep
          SizedBox(height: 32.0),
        ],
      ),
    );
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            topbar,
            content,
          ],
        ),
      ),
    );
  }

}
