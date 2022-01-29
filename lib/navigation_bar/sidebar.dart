import 'package:flutter/material.dart';
import 'package:hunt_app/contribute/form.dart';
import 'package:hunt_app/explore/explore.dart';
import 'package:hunt_app/leaderboard/leaderboard.dart';
import 'package:hunt_app/navigation_bar/persistent_side_nav_bar.dart';
import 'package:hunt_app/profile/profile.dart';

class SideNavBar extends StatefulWidget {
  final BuildContext? menuScreenContext;
  SideNavBar({Key? key, this.menuScreenContext}) : super(key: key);

  @override
  _SideNavBarState createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  final PageController _pageController = PageController();

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
          page: Explore()
      ),
      SideNavItem(
          name: 'Contribute',
          iconData: Icons.add_circle,
          page: Contribute()
      ),
      SideNavItem(
          name: 'Leaderboard',
          iconData: Icons.leaderboard,
          page: LeaderBoard()
      ),
      SideNavItem(
          name: 'Profile',
          iconData: Icons.person,
          page: Profile()
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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


// class CDM {
//   //complex drawer menu
//   final IconData icon;
//   final String title;
//   final List<String> submenus;
//
//   CDM(this.icon, this.title, this.submenus);
// }
//
//
// class SideBar extends StatefulWidget {
//
//   @override
//   _SideBarState createState() => _SideBarState();
// }
//
// class _SideBarState extends State<SideBar> {
//
//   int selectedIndex = -1;//don't set it to 0
//
//   bool isExpanded = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     return Container(
//       width: width,
//       child: row(),
//       color: Color(0xffe3e9f7),
//     );
//   }
//
//   Widget row(){
//     return Row(
//         children: [
//           isExpanded? blackIconTiles():blackIconMenu(),
//           invisibleSubMenus(),
//         ]
//     );
//   }
//
//   Widget blackIconTiles(){
//     return Container(
//       width: 200,
//       color: Colors.indigo,
//       child: Column(
//         children: [
//           controlTile(),
//           Expanded(child: ListView.builder(
//             itemCount: cdms.length,
//             itemBuilder: (context, index) {
//               //  if(index==0) return controlTile();
//
//
//               CDM cdm = cdms[index];
//               bool selected = selectedIndex == index;
//               return ExpansionTile(
//                   onExpansionChanged:(z){
//                     setState(() {
//                       selectedIndex = z?index:-1;
//                     });
//                   },
//                   leading: Icon(cdm.icon,color: Colors.white),
//                   title: Text(
//                     cdm.title,
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   trailing: cdm.submenus.isEmpty? null :
//
//                   Icon(selected?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,
//                     color: Colors.white,
//                   ),
//                   children: cdm.submenus.map((subMenu){
//                     return sMenuButton(subMenu, false);
//                   }).toList()
//               );
//             },
//           ),
//           ),
//           //accountTile(),
//         ],
//       ),
//     );
//   }
//
//
//   Widget controlTile(){
//     return Padding(
//       padding: EdgeInsets.only(top:20,bottom: 30),
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 40,
//           backgroundImage: AssetImage('assets/images/logo.png'),
//         ),
//         title: Text(
//           "UrbanHunt",
//           style: TextStyle(
//             fontSize: 18,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         onTap: expandOrShrinkDrawer,
//       ),
//     );
//   }
//
//   Widget blackIconMenu(){
//     return AnimatedContainer(
//       duration: Duration(seconds:1),
//       width: 100,
//       color: Colors.indigo,
//       child: Column(
//         children: [
//           controlButton(),
//           Expanded(
//             child: ListView.builder(
//                 itemCount: cdms.length,
//                 itemBuilder: (context, index){
//                   // if(index==0) return controlButton();
//                   return InkWell(
//                     onTap: (){
//                       setState(() {
//                         selectedIndex = index;
//
//                       });
//                     },
//                     child: Container(
//                       height: 45,
//                       alignment: Alignment.center,
//                       child: Icon(cdms[index].icon,color: Colors.white),
//                     ),
//                   );
//                 }
//             ),
//           ),
//           //accountButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget invisibleSubMenus(){
//     // List<CDM> _cmds = cdms..removeAt(0);
//     return AnimatedContainer(
//       duration: Duration(milliseconds:500),
//       width: isExpanded? 0:125,
//       color: Color(0xffe3e9f7),
//       child: Column(
//         children: [
//           Container(height:95),
//           Expanded(
//             child: ListView.builder(
//                 itemCount: cdms.length,
//                 itemBuilder: (context, index){
//                   CDM cmd = cdms[index];
//                   // if(index==0) return Container(height:95);
//                   //controll button has 45 h + 20 top + 30 bottom = 95
//
//                   bool selected = selectedIndex==index;
//                   bool isValidSubMenu = selected && cmd.submenus.isNotEmpty;
//                   return subMenuWidget([cmd.title]..addAll(cmd.submenus) ,isValidSubMenu);
//                 }
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget controlButton(){
//     return Padding(
//       padding: EdgeInsets.only(top:20,bottom: 30),
//       child: InkWell(
//         onTap: expandOrShrinkDrawer,
//         child: Container(
//           height: 45,
//           alignment: Alignment.center,
//           child: CircleAvatar(
//             backgroundImage: AssetImage('assets/images/logo.png'),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget subMenuWidget(List<String> submenus,bool isValidSubMenu){
//     return AnimatedContainer(
//       duration: Duration(milliseconds:500),
//       height: isValidSubMenu? submenus.length.toDouble() *37.5 : 45,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//           color:isValidSubMenu? Colors.blueGrey: Colors.transparent,
//           borderRadius: BorderRadius.only(
//             topRight: Radius.circular(8),
//             bottomRight:  Radius.circular(8),
//           )
//       ),
//       child: ListView.builder(
//           padding: EdgeInsets.all(6),
//           itemCount: isValidSubMenu? submenus.length:0,
//           itemBuilder: (context,index){
//             String subMenu = submenus[index];
//             return sMenuButton(subMenu,index==0);
//           }
//       ),
//     );
//   }
//
//
//   Widget sMenuButton(String subMenu,bool isTitle){
//     return InkWell(
//       onTap: (){
//
//         //handle the function
//         //if index==0? donothing: doyourlogic here
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           subMenu,
//           style: TextStyle(
//             fontSize: isTitle? 17:14,
//             color: isTitle? Colors.white: Colors.grey,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   /*Widget accountButton({bool usePadding = true}){
//     return Padding(
//       padding: EdgeInsets.all(usePadding?8:0),
//       child: AnimatedContainer(
//         duration: Duration(seconds:1),
//         height: 45,
//         width: 45,
//         decoration: BoxDecoration(
//           color: Colors.white70,
//           image: DecorationImage(
//             image: CachedNetworkImage(Urls.avatar2),
//             fit: BoxFit.cover,
//           ),
//           borderRadius: BorderRadius.circular(6),
//         ),
//       ),
//     );
//   }
//
//   Widget accountTile(){
//     return Container(
//       color: Colors.blueGrey,
//       child: ListTile(
//         leading: accountButton(usePadding: false),
//         title: Txt(
//           text:"Prem Shanhi",
//           color: Colors.white,
//         ),
//         subtitle: Txt(
//           text:"Web Designer",
//           color: Colors.white70,
//         ),
//       ),
//     );
//   }*/
//
//
//   static List<CDM> cdms = [
//     // CDM(Icons.grid_view, "Control", []),
//     CDM(Icons.explore, "Explore", []),
//     CDM(Icons.add_circle, "Contribute", []),
//     CDM(Icons.leaderboard, "Leaderboard", []),
//     CDM(Icons.person, "Profile", []),
//   ];
//
//
//   void expandOrShrinkDrawer(){
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }
//
//
//}