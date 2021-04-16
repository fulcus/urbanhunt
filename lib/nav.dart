import 'package:flutter/material.dart';
import 'package:hunt_app/add_place.dart';
import 'package:hunt_app/home.dart';


class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  
  // Placeholder pages
  final List<Widget> _pages = [
    HomePage(title: 'Hunt App'), // Map
    Container(color: Colors.white),  // Social
    AddPlace(),  // Contribute
    Container(color: Colors.blue),   // Settings
  ];

  int _curPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    /// ** BottomNavBarState ** contains the frontend for the navbar as well as
    /// the minimal bits of logic required to navigate to the pages on icon tap.
    /// 
    /// * Navigation *
    /// In order for the (forward-only) navigation to happen (i.e. the pushed
    /// page has to handle pop() on its own), pages builder must be available
    /// (in the class or even in the module namespace) and are used as part of
    /// the Navigation.push(context, MaterialPageRoute(builder: page-builder)).
    ///
    /// * Usage *
    /// Included as a bottomNavigationBar: BottomNavBar() in a scaffold
    /// (whose body is the actual page which wants to have a BottomNavBar).
    ///
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Map',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Social'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Contribute',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _curPageIndex,
      onTap: (iconIndex) {
        setState(() {
          _curPageIndex = iconIndex;
          // TODO avoid that same route is pushed twice (e.g. by clicking twice on map)
          Navigator.push(context, MaterialPageRoute<void>(builder: (context) => _pages[_curPageIndex]));
        });
      },
    );
  }

}
