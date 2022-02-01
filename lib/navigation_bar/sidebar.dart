import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/explore/explore.dart';
import 'package:hunt_app/leaderboard/leaderboard.dart';
import 'package:hunt_app/navigation_bar/persistent_side_nav_bar.dart';
import 'package:hunt_app/profile/profile.dart';
import 'package:hunt_app/utils/misc.dart';

class SideNavBar extends StatefulWidget {
  final BuildContext? menuScreenContext;
  SideNavBar({Key? key, this.menuScreenContext}) : super(key: key);

  @override
  _SideNavBarState createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  final PageController _pageController = PageController();
  final User loggedUser = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<SideNavItem> _navBarsItems() {
    return [
      SideNavItem(
          name: 'Explore',
          iconData: Icons.explore,
          page: Explore(loggedUser, db)
      ),
      SideNavItem(
          name: 'Contribute',
          iconData: Icons.add_circle,
          page: Contribute(loggedUser)
      ),
      SideNavItem(
          name: 'Leaderboard',
          iconData: Icons.leaderboard,
          page: LeaderBoard(loggedUser, db)
      ),
      SideNavItem(
          name: 'Profile',
          iconData: Icons.person,
          page: Profile(loggedUser, db)
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SideBar(
        backgroundColor: Colors.indigo[50]!,
        items: _navBarsItems(),
        selectedColor: Colors.indigo,
        pageController: _pageController,
        sideBarWidth: 180,
      )
    );
  }
}

