import 'package:flutter/material.dart';

class SideNavItem {
  final String? name;
  final IconData? iconData;
  final Widget? page;

  const SideNavItem({
    this.name,
    this.iconData,
    this.page,
  });
}

class SideBar extends StatefulWidget {
  final Color backgroundColor;
  final double sideBarWidth;
  final double sideBarCollapsedWidth;

  //final Widget currentItem;

  final List<SideNavItem> items;
  final Function? show;

  // final int selectedIndex;
  final Color? selectedColor;
  final bool alwaysOpened;

  final PageController? pageController;

  SideBar({
    this.backgroundColor = Colors.blueGrey,
    required this.items,
    this.sideBarCollapsedWidth = 60,
    this.sideBarWidth = 180,
    this.show,
    this.selectedColor = Colors.transparent,
    this.alwaysOpened = false,
    this.pageController,
  });

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  List<Widget?> pages = [];

  List<int> history = [];

  @override
  void initState() {
    pages = widget.items.map((item) => item.page).toList();

    widget.pageController!.addListener(() {
      // final Widget currentItem =  widget.items[currentItemIndex].page;
      currentIndex = widget.pageController!.page!.toInt();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: EdgeInsets.zero,
      elevation: 4,
      child: Row(children: [
        SideNavMenu(
            alwaysOpen: widget.alwaysOpened,
            items: widget.items,
            sideBarCollapsedWidth: 60,
            sideBarWidth: widget.sideBarWidth,
            backgroundColor: widget.backgroundColor,
            selectedColor: widget.selectedColor,
            pageController: widget.pageController,
            onItemTap: widget.show),
        Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              //child: pages[currentIndex]),
              children: pages.whereType<Widget>().toList(),
              controller: widget.pageController,
            ))
      ]),
    );
  }
}

class SideNavMenu extends StatefulWidget {
  final List<SideNavItem>? items;
  final Color? selectedColor;
  final Function? onItemTap;
  final bool? alwaysOpen;
  final double sideBarWidth;
  final double sideBarCollapsedWidth;
  final Color? backgroundColor;
  final PageController? pageController;

  const SideNavMenu({
    Key? key,
    this.items,
    this.selectedColor,
    this.onItemTap,
    this.alwaysOpen,
    this.sideBarCollapsedWidth = 60,
    this.sideBarWidth = 180,
    this.backgroundColor,
    this.pageController,
  }) : super(key: key);

  @override
  _SideNavMenuState createState() => _SideNavMenuState();
}

class _SideNavMenuState extends State<SideNavMenu>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  bool showText = false;
  bool _first = true;
  int _selectedIndex = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.alwaysOpen!) {
      isCollapsed = false;
    }

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        if (_first) {
          _first = false;
        }

        if (isCollapsed) {
          setState(() {
            showText = true;
          });
        } else {
          setState(() {
            showText = false;
          });
        }
      }
    });

    widget.pageController!.addListener(() {
      if (mounted) {
        setState(() {
          _selectedIndex = widget.pageController!.page!.toInt();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Locale appLocale = Localizations.localeOf(context);

    _animation =
        Tween<double>(begin: isCollapsed ? 0 : 0.5, end: isCollapsed ? 0.5 : 1)
            .animate(_controller);

    return AnimatedContainer(
      duration: _controller.duration!,
      color: widget.backgroundColor,
      width: isCollapsed ? widget.sideBarCollapsedWidth : widget.sideBarWidth,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.items!
                    .asMap()
                    .map((index, item) {
                  final view = NavItemTile(
                      isCollapsed: showText ? true : isCollapsed,
                      // hoverColor: Colors.blue,
                      selectedColor: _selectedIndex != index
                          ? null
                          : widget.selectedColor,
                      title: Text(
                        item.name!,
                        style: TextStyle(
                          color:
                          _selectedIndex == index ? Colors.white : null,
                        ),
                      ),
                      icon: item.iconData == null
                          ? null
                          : Icon(
                        item.iconData,
                        color: _selectedIndex == index
                            ? Colors.white
                            : null,
                      ),
                      onPressed: () => {
                        widget.pageController!.jumpToPage(index),
                      }
                  );
                  return MapEntry<int, Widget>(index, view);
                })
                    .values
                    .toList(),
              ),
            ),
            if (!widget.alwaysOpen!) ...[
              Container(
                margin: EdgeInsetsDirectional.only(end: isCollapsed ? 0 : 12),
                alignment: isCollapsed
                    ? AlignmentDirectional.center
                    : AlignmentDirectional.centerEnd,
                child: RotationTransition(
                  turns: _animation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Container(
                            margin: EdgeInsetsDirectional.only(
                              end: _first
                                  ? 0
                                  : isCollapsed
                                  ? 8
                                  : 8,
                            ),
                            child: Icon(
                                _first
                                    ? Icons.arrow_back_ios
                                    : Icons.arrow_forward_ios,
                                size: 24,
                                textDirection: appLocale.languageCode == "he"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl)),
                        onPressed: () {
                          _controller.forward(
                            from: 0,
                          );
                          setState(() {
                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class NavItemTile extends StatelessWidget {
  final Color? hoverColor;
  final Widget title;
  final Widget? icon;
  final bool isCollapsed;
  final Function? onPressed;
  final Color? selectedColor;

  NavItemTile(
      {required this.isCollapsed,
        required this.title,
        required this.icon,
        this.onPressed,
        this.hoverColor,
        this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        onPressed: onPressed as void Function()?,
        child: ListTile(
          selected: selectedColor != null,
          selectedTileColor: selectedColor,
          leading: icon,
          title: isCollapsed ? null : title,
        ),
      ),
    );
  }
}

class SideBarScaffold extends StatefulWidget {
  final List<SideNavItem> items;
  final Color backgroundColor;
  final Color? selectedColor;
  final double sideBarWidth;
  final bool? alwaysOpened;
  final bool? showSelectedBold;

  // final PreferredSizeWidget appBar;

  const SideBarScaffold({
    Key? key,
    this.backgroundColor = Colors.blueGrey,
    this.sideBarWidth = 190,
    required this.items,
    this.selectedColor,
    this.alwaysOpened,
    this.showSelectedBold,
    // this.appBar,
  }) : super(key: key);

  @override
  _SideBarScaffoldState createState() => _SideBarScaffoldState();
}

class _SideBarScaffoldState extends State<SideBarScaffold>
    with SingleTickerProviderStateMixin {
  PageController? _pageController;

  final List<int> _history = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _history.add(0);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  void show(int index) {
    _pageController!.jumpToPage(index);
    _history.add(index);
    _history.toSet().toList();
  }

  Future<bool> _onBackPressed() async {
    if (_history.length == 1) {
      return false;
    }
    _history.removeLast();
    _pageController!.jumpToPage(_history.last);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        // appBar: widget.appBar,
        child: SideBar(
          pageController: _pageController,
          backgroundColor: widget.backgroundColor,
          sideBarWidth: widget.sideBarWidth,
          items: widget.items,
          selectedColor: widget.selectedColor,
          show: show,
          alwaysOpened: widget.alwaysOpened ?? false,
        ),
      ),
    );
  }
}
