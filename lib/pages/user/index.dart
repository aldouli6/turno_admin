import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/user/details.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';
import 'package:turno_admin/widgets/home_drawer.dart';
import 'package:turno_admin/widgets/navigation_home.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}


class _UsersState extends State<Users> {

  List _users = List();
  String _authtoken='';
  String _estabId='';
  String _userId='';
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  HttpService http = new HttpService();
  Future<List> _future;
  
  Widget actionButtons(BuildContext context){
    return InkWell(
      borderRadius:
          BorderRadius.circular(AppBar().preferredSize.height),
      child: Icon(
        FontAwesomeIcons.plusCircle,
        color: AppSettings.white,
      ),
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new User(null, NavigationHome(DrawerIndex.Users, Users()))));
      },
    );
  }
  Future<List> getData() async {
    String url =  AppSettings.API_URL+'/api/users?establishment_id='+_estabId;
    _users = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token:_authtoken);
    _users.removeWhere((element) => element['id'].toString() == _userId);
    setState(() {
      _users = _users;
      if(_users.length>0){
        _future =asignFuture(_users);
      }else{
        _future = asignFuture(null);
      }
    });
    return _users;
  }
  Future<List> asignFuture(dynamic map) async {
    return map;
  }
  @override
  void initState() {
    _authtoken = Provider.of<LoginState>(context, listen: false).getAuthToken();
    _estabId = Provider.of<LoginState>(context, listen: false).getEstablishment();
    _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    _future = getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<List >(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List > snapshot) {
          if (!snapshot.hasData) {
            return Stack(
              children: [
                Container( 
                  padding: EdgeInsets.only(top: AppBar().preferredSize.height +(MediaQuery.of(context).padding.top*3),),
                  width: double.infinity,
                  child: RefreshIndicator(
                    onRefresh: ()=>  getData(),
                    child: ListView(
                      children: [
                        Container(
                           width: double.infinity,
                          height: MediaQuery.of(context).size.height - (AppBar().preferredSize.height +(MediaQuery.of(context).padding.top*4)),
                            child:Center(child: Text('Usted no tiene usuarios registrados'))
                        )
                      ],

                     
                    )
                  ),
                ),
                toolBar(context,'Usuarios', actionButtons(context), null),
              ],
            );
          } else {
            return Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: AppBar().preferredSize.height +(MediaQuery.of(context).padding.top*3),),
                  width: double.infinity,
                  child:  RefreshIndicator(
                    onRefresh: ()=>  getData(),
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return  buildList(context, index);
                      }
                    ),
                  ),
                ),
                toolBar(context, 'Usuarios', actionButtons(context),null),
              
              ]
            ) ;
          }
        }
      )
    );
  }
  Widget buildList(BuildContext context, int index) {
    return Padding(
      padding:EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Material(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20.0) ),
              child: Container(
          width: double.infinity,
          
          height: 100,
          decoration: BoxDecoration(
            color: (_users[index]['enabled']==1 )?AppSettings.white:AppSettings.light_grey,
            borderRadius: new BorderRadius.circular(20)
          ),
          // margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(width: 3, color: AppSettings.SECONDARY),
                        image: DecorationImage(
                            image: NetworkImage(AppSettings.API_URL+'/storage/'+ _users[index]['imagen'].toString()),
                            fit: BoxFit.cover),
                      )
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text: (_users[index]['name']!=null)?_users[index]['name']+' ':'',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppSettings.PRIMARY, 
                                fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: (_users[index]['lastname']!=null)?_users[index]['lastname']:'',
                                    style: TextStyle(
                                        color: AppSettings.PRIMARY,
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w300,
                                    ),
                                )
                              ]
                              ),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.phone,
                                color: AppSettings.SECONDARY,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(_users[index]['phone'],
                                  style: TextStyle(
                                      color: AppSettings.PRIMARY, fontSize: 13, letterSpacing: .3)),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.email,
                                color: AppSettings.SECONDARY,
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(_users[index]['email'].toString(),
                                  style: TextStyle(
                                      color: AppSettings.PRIMARY, fontSize: 13, letterSpacing: .3)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      width: 40,
                      child: IconButton(
                        icon: Icon(Icons.edit, color: AppSettings.white,size: 18,),
                        onPressed: () { 
                          Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new User(_users[index], NavigationHome(DrawerIndex.Users, Users()))));
                        },
                      ),
                      decoration: new BoxDecoration(
                        color: AppSettings.SECONDARY,
                        borderRadius: new BorderRadius.only(
                          topRight: const Radius.circular(20.0),
                        )
                      ),
                    ),
                    Container(
                      height: 45,
                      width: 40,
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.trash, color: AppSettings.white,size: 18,),
                        onPressed: () async { 
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomAlertDialog(
                                type: AlertDialogType.QUESTION,
                                title: "Confirmación", 
                                content: 'Está seguro de eliminar el usuario',
                                trueButton: ' S í ',
                                falseButton: 'N o',
                              );
                            },
                          ).then((value) async {

                            if(value){
                              var res = await http.apiCall(
                                context, 
                                _scaffoldKey, 
                                HttpServiceType.DELETE, 
                                AppSettings.API_URL+'/api/users/'+_users[index]['id'].toString(), 
                                token:_authtoken
                              );
                              if(res!=null){
                                 await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomAlertDialog(
                                      type: AlertDialogType.SUCCESS,
                                      title: "Correcto", 
                                      content: 'Usuario eliminado correctamente',
                                    );
                                  },
                                ).then((value){
                                  getData();
                                });
                              }
                            }
                          });
                        },
                      ),
                      decoration: new BoxDecoration(
                        color: AppSettings.DANGER,
                        borderRadius: new BorderRadius.only(
                          bottomRight: const Radius.circular(20.0),
                        )
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}