
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/profile.dart';
import 'package:turno_admin/widgets/navigation_home.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key key, this.screenIndex, this.iconAnimationController, this.callBackIndex}) : super(key: key);

  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList> drawerList;
  String _role;
  String _userId;
  String _authToken;
  HttpService http = new HttpService();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
 
  Map<String, dynamic> _user = Map<String, dynamic>();
  Map<String, dynamic> _estab = Map<String, dynamic>();

  Future<void> getUserInfo() async {
    _user =  await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, AppSettings.API_URL+'/api/users/'+_userId, token: _authToken);
     if(_user!=null){
      _estab = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, AppSettings.API_URL+'/api/establishments/'+_user['establishment_id'].toString(), token: _authToken);
     }
  }

  @override
  void initState() {
    setDrawerListArray();
    _role = Provider.of<LoginState>(context, listen: false).getRole();
    _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    _authToken = Provider.of<LoginState>(context, listen: false).getAuthToken();
    getUserInfo();
    super.initState();
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Home',
        icon: Icon(Icons.home),
        roles: ['admin','super_admin']
      ),
      DrawerList(
        index: DrawerIndex.Users,
        labelName: 'Usuarios',
        icon: Icon(Icons.people_alt),
        roles:['admin','super_admin']
      ),
      DrawerList(
        index: DrawerIndex.Sessions,
        labelName: 'Sesiones',
        icon: Icon(Icons.flag),
        roles:['admin']
      ),
      DrawerList(
        index: DrawerIndex.Resources,
        labelName: 'Resources',
        icon: Icon(FontAwesomeIcons.cubes),
        roles:['admin']
      ),
      DrawerList(
        index: DrawerIndex.Establish,
        labelName: 'Establecimiento',
        icon: Icon(Icons.store),
        roles: ['preadmin']
      ),
      DrawerList(
        index: DrawerIndex.Propspects,
        labelName: 'Prospectos',
        icon: Icon(Icons.verified_user),
        roles: ['super_admin']
      ),
      DrawerList(
        index: DrawerIndex.FeedBack,
        labelName: 'FeedBack',
        icon: Icon(Icons.help),
        roles: ['admin','super_admin']
      ),
      DrawerList(
        index: DrawerIndex.Invite,
        labelName: 'Invite Friend',
        icon: Icon(Icons.group),
        roles: ['admin','super_admin']
      ),
      DrawerList(
        index: DrawerIndex.Share,
        labelName: 'Rate the app',
        icon: Icon(Icons.share),
        roles: ['admin','super_admin']
      ),
      DrawerList(
        index: DrawerIndex.About,
        labelName: 'About Us',
        icon: Icon(Icons.info),
        roles: ['admin','super_admin']
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppSettings.notWhite.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Container(
              padding:  EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top ,16,16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(1.0 - (widget.iconAnimationController.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(begin: 0.0, end: 24.0)
                                  .animate(CurvedAnimation(parent: widget.iconAnimationController, curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (_estab['name']!=null)?_estab['name']:'',
                                    style: TextStyle(
                                      color: AppSettings.PRIMARY,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  (_role!='user')?IconButton(icon: Icon(Icons.settings), onPressed: null):Container(),
                                ],
                              ),
                          
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(color: AppSettings.grey.withOpacity(0.6), offset: const Offset(2.0, 4.0), blurRadius: 8),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                                  child: (_user['imagen']!=null)?
                                  Image.network(AppSettings.API_URL+'/storage/'+_user['imagen'], fit: BoxFit.cover,):
                                  (_user['name']!=null && _user['lastname']!=null)?
                                  CircleAvatar(
                                    backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                    child: Text(_user['name'].substring(0,1).toString().toUpperCase() + _user['lastname'].substring(0,1).toString().toUpperCase(),
                                    style: TextStyle(fontSize: 50),
                                    ),
                                  ):null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: (_user['name']!=null)?_user['name']+' ':'',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppSettings.grey, 
                                  fontSize: 18),
                                children: <TextSpan>[
                                  TextSpan(text: (_user['lastname']!=null)?_user['lastname']:'',
                                      style: TextStyle(
                                          color: AppSettings.grey,
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w300,
                                      ),
                                  )
                                ]
                                ),
                            ),
                            Text(
                              (_user['email']!=null)?_user['email']:'',
                              style: TextStyle(
                                color: AppSettings.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        (_role!='user')
                        ?IconButton(
                          icon: Icon(Icons.arrow_forward, color: AppSettings.PRIMARY,),
                          onPressed: () =>  Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavigationHome(null, Profile())
                            ),
                          ),
                        ):Container()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: AppSettings.grey.withOpacity(0.6),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList.length,
              itemBuilder: (BuildContext context, int index) {
                if (drawerList[index].roles.contains(_role)) {
                  return  inkwell(drawerList[index]) ;
                }else{
                  return Container();
                }
              },
            ),
          ),
          Divider(
            height: 1,
            color: AppSettings.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontFamily: AppSettings.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppSettings.darkText,
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () {
                   Provider.of<LoginState>(context, listen: false).logout();
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                    decoration: BoxDecoration(
                      color: widget.screenIndex == listData.index
                          ? AppSettings.PRIMARY
                          : Colors.transparent,
                      borderRadius: new BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName, color: widget.screenIndex == listData.index ? AppSettings.PRIMARY : AppSettings.nearlyBlack),
                        )
                      : Icon(listData.icon.icon, color: widget.screenIndex == listData.index ? AppSettings.PRIMARY : AppSettings.nearlyBlack),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index ? AppSettings.PRIMARY : AppSettings.nearlyBlack,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index 
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) * (1.0 - widget.iconAnimationController.value - 1.0), 0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppSettings.PRIMARY.withOpacity(0.2),
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

enum DrawerIndex {
  HOME,
  FeedBack,
  Propspects,
  Users,
  Sessions,
  Resources,
  Establish,
  Help,
  Share,
  About,
  Invite,
  Testing,
}

class DrawerList {


  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
    this.roles,
    this.colorMenu=AppSettings.PRIMARY,
  });

  String labelName;
  Icon icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;
  List<String> roles;
  Color colorMenu;
}
