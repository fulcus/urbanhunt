import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/leaderboard.dart';
import 'package:hunt_app/profile/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'explore/explore.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

BuildContext? testContext;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Bottom Navigation Bar example project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainMenu(),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/first': (context) => Contribute(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => LeaderBoard(),
      },
    );
  }
}

class MainMenu extends StatefulWidget {
  MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return redirectHomeOrLogin();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Sample Project"),
    //   ),
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       /*Center(
    //         child: ElevatedButton(
    //           child: Text("Custom widget example"),
    //           onPressed: () => pushNewScreen<void>(
    //             context,
    //             screen: CustomWidgetExample(
    //               menuScreenContext: context,
    //             ),
    //           )
    //         ),
    //       ),*/
    //       SizedBox(height: 20.0),
    //       Center(
    //         child: ElevatedButton(
    //           child: Text("Built-in styles example"),
    //           onPressed: () => pushNewScreen<void>(
    //             context,
    //             screen: ProvidedStylesExample(
    //               menuScreenContext: context,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

// ----------------------------------------- Provided Style ----------------------------------------- //

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
      Container(color: Colors.blue)
      // MainScreen(
      //   menuScreenContext: widget.menuScreenContext,
      //   hideStatus: _hideNavBar,
      //   onScreenHideButtonPressed: () {
      //     setState(() {
      //       _hideNavBar = !_hideNavBar;
      //     });
      //   },
      // ),
      // MainScreen(
      //   menuScreenContext: widget.menuScreenContext,
      //   hideStatus: _hideNavBar,
      //   onScreenHideButtonPressed: () {
      //     setState(() {
      //       _hideNavBar = !_hideNavBar;
      //     });
      //   },
      // ),
      // MainScreen(
      //   menuScreenContext: widget.menuScreenContext,
      //   hideStatus: _hideNavBar,
      //   onScreenHideButtonPressed: () {
      //     setState(() {
      //       _hideNavBar = !_hideNavBar;
      //     });
      //   },
      // ),
      // MainScreen(
      //   menuScreenContext: widget.menuScreenContext,
      //   hideStatus: _hideNavBar,
      //   onScreenHideButtonPressed: () {
      //     setState(() {
      //       _hideNavBar = !_hideNavBar;
      //     });
      //   },
      // ),
      // MainScreen(
      //   menuScreenContext: widget.menuScreenContext,
      //   hideStatus: _hideNavBar,
      //   onScreenHideButtonPressed: () {
      //     setState(() {
      //       _hideNavBar = !_hideNavBar;
      //     });
      //   },
      // ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: ("Search"),
        activeColorPrimary: Colors.teal,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => Contribute(),
            '/second': (context) => LeaderBoard(),
          },
        ),
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.add),
          title: ("Add"),
          activeColorPrimary: Colors.blueAccent,

          // activeColorSecondary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          routeAndNavigatorSettings: RouteAndNavigatorSettings(
            initialRoute: '/',
            routes: {
              '/first': (context) => Contribute(),
              '/second': (context) => LeaderBoard(),
            },
          ),
          // onPressed: (context) {
          //   pushDynamicScreen<void>(context!,
          //       screen: SampleModalScreen(), withNavBar: true);
          // }
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.message),
        title: ("Messages"),
        activeColorPrimary: Colors.deepOrange,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => Contribute(),
            '/second': (context) => LeaderBoard(),
          },
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Settings"),
        activeColorPrimary: Colors.indigo,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => Contribute(),
            '/second': (context) => LeaderBoard(),
          },
        ),
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
