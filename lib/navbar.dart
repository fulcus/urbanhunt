import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/leaderboard.dart';
import 'package:hunt_app/profile/profile.dart';
import 'package:hunt_app/explore/explore.dart';


BuildContext? testContext;

class ProvidedStylesExample extends StatefulWidget {
  final BuildContext? menuScreenContext;
  ProvidedStylesExample({Key? key, this.menuScreenContext}) : super(key: key);

  @override
  _ProvidedStylesExampleState createState() => _ProvidedStylesExampleState();
}

class _ProvidedStylesExampleState extends State<ProvidedStylesExample> {
  late PersistentTabController _controller;
  late bool _hideNavBar;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  List<Widget> _buildScreens() {
    return [
      Explore(),
      Contribute(),
      LeaderBoard(),
      Profile(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.explore),
        title: 'Explore',
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add_circle),
        title: ('Contribute'),
        activeColorPrimary: Colors.teal,
        inactiveColorPrimary: Colors.grey,
        // routeAndNavigatorSettings: RouteAndNavigatorSettings(
        //   initialRoute: '/',
        //   routes: {
        //     '/first': (context) => Contribute(),
        //     '/second': (context) => LeaderBoard(),
        //   },
        // ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.leaderboard),
        title: ('Leaderboard'),
        activeColorPrimary: Colors.blueAccent,

        activeColorSecondary: Colors.deepOrange,
        inactiveColorPrimary: Colors.grey,
        // routeAndNavigatorSettings: RouteAndNavigatorSettings(
        //   initialRoute: '/',
        //   routes: {
        //     '/first': (context) => Contribute(),
        //     '/second': (context) => LeaderBoard(),
        //   },
        // ),
        // onPressed: (context) {
        //   pushDynamicScreen<void>(context!,
        //       screen: SampleModalScreen(), withNavBar: true);
        // }
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: ('Profile'),
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey,
        // routeAndNavigatorSettings: RouteAndNavigatorSettings(
        //   initialRoute: '/',
        //   routes: {
        //     '/first': (context) => Contribute(),
        //     '/second': (context) => LeaderBoard(),
        //   },
        // ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Navigation Bar Demo')),
      // drawer: Drawer(
      //   child: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         const Text('This is the Drawer'),
      //       ],
      //     ),
      //   ),
      // ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        hideNavigationBarWhenKeyboardShows: true,
        margin: EdgeInsets.all(0.0),
        popActionScreens: PopActionScreensType.all,
        bottomScreenMargin: 0.0,
        onWillPop: (context) async {
          await showDialog<void>(
            context: context!,
            useSafeArea: true,
            builder: (context) => Container(
              height: 50.0,
              width: 50.0,
              color: Colors.white,
              child: ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
          return false;
        },
        selectedTabScreenContext: (context) {
          testContext = context;
        },
        hideNavigationBar: _hideNavBar,
        decoration: NavBarDecoration(
            colorBehindNavBar: Colors.indigo,
            borderRadius: BorderRadius.circular(20.0)),
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
        NavBarStyle.style1, // Choose the nav bar style with this property
      ),
    );
  }
}
