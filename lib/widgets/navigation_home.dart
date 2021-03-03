import 'package:flutter/material.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/pages/establishment.dart';
import 'package:turno_admin/pages/home_screen.dart';
import 'package:turno_admin/pages/prospect/index.dart';
import 'package:turno_admin/pages/user/index.dart';
import 'package:turno_admin/widgets/drawer_user_controller.dart';
import 'package:turno_admin/widgets/home_drawer.dart';

class NavigationHome extends StatefulWidget {
   Widget screenView;
  DrawerIndex drawerIndex;
  NavigationHome(this.drawerIndex,this.screenView);
  @override
  _NavigationHomeState createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome> {
  Widget screenView;
  DrawerIndex drawerIndex;

  @override
  void initState() {
    drawerIndex =widget.drawerIndex;
    screenView = widget.screenView;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppSettings.nearlyWhite,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppSettings.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;

      switch (drawerIndex) {
        case DrawerIndex.Establish:
            screenView =  Establishment(null);
          break;
        case DrawerIndex.Propspects:
            screenView = Prospects();
          break;
        case DrawerIndex.Users:
            screenView = Users();
          break;
        case DrawerIndex.Help:
        case DrawerIndex.FeedBack:
        case DrawerIndex.Invite:
        case DrawerIndex.Share:
        case DrawerIndex.About:
        case DrawerIndex.Testing:
        case DrawerIndex.HOME:
          screenView = const Home();
          break;
      }
      setState(() {
        screenView =screenView;
      });
    }
  }
}
