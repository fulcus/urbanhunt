import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/explore/explore.dart';
import 'package:hunt_app/profile/profile.dart';
import 'package:hunt_app/leaderboard.dart';

class Nav extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NavState();
}

class NavState extends State<Nav> {
  String _currentPage = 'Explore';
  List<String> pageKeys = ['Explore', 'Contribute', 'Leaderboard', 'Profile'];
  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    'Explore': GlobalKey<NavigatorState>(),
    'Contribute': GlobalKey<NavigatorState>(),
    'Leaderboard': GlobalKey<NavigatorState>(),
    'Profile': GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != 'Explore') {
            _selectTab('Explore', 1);

            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: <Widget>[
          _buildOffstageNavigator('Explore'),
          _buildOffstageNavigator('Contribute'),
          _buildOffstageNavigator('Leaderboard'),
          _buildOffstageNavigator('Profile'),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blueAccent,
          onTap: (int index) {
            _selectTab(pageKeys[index], index);
          },
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Contribute',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}

class TabNavigator extends StatelessWidget {
  TabNavigator({required this.navigatorKey, required this.tabItem});

  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {
    Widget child = Explore();
    if (tabItem == 'Explore') {
      child = Explore();
    } else if (tabItem == 'Contribute') {
      child = Contribute();
    } else if (tabItem == 'Leaderboard') {
      child = LeaderBoard();
    } else if (tabItem == 'Profile') {
      child = Profile();
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute<void>(builder: (context) => child);
      },
    );
  }
}

/////////////////////////////////////////////////////////////////////////////
/// CUPERTINO SOLUTION
////////////////////////////////////////////////////////////////////////////
/*
class CupertinoStoreHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Products'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text('Cart'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Map(),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Contribute(),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Leaderboard(),
              );
            });
          default:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Map(),
              );
            });
        }
      },
    );
  }
}*/
