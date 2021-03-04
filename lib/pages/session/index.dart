import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/session/details.dart';
import 'package:turno_admin/pages/user/details.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';
import 'package:turno_admin/widgets/home_drawer.dart';
import 'package:turno_admin/widgets/navigation_home.dart';

class Sessions extends StatefulWidget {
  @override
  _SessionsState createState() => _SessionsState();
}


class _SessionsState extends State<Sessions> {

  List _sessions = List();
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
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new Session(null, NavigationHome(DrawerIndex.Sessions, Sessions()))));
      },
    );
  }
  Future<List> getData() async {
    String url =  AppSettings.API_URL+'/api/sessions?establishment_id='+_estabId;
    _sessions = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token:_authtoken);
    print(_sessions);
    setState(() {
      _sessions = _sessions;
      if(_sessions.length>0){
        _future =asignFuture(_sessions);
      }else{
        _future = asignFuture(null);
      }
    });
    return _sessions;
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
                            child:Center(child: Text('Usted no tiene sesiones registradas'))
                        )
                      ],

                     
                    )
                  ),
                ),
                toolBar(context,'Sessiones', actionButtons(context), null),
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
                      itemCount: _sessions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return  buildList(context, index);
                      }
                    ),
                  ),
                ),
                toolBar(context, 'Sesiones', actionButtons(context),null),
              
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
        child: Dismissible (
          key: Key('item ${_sessions[index]}'),
          direction: DismissDirection.endToStart,
          background: Container(),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(20),
              color: AppSettings.DANGER,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.delete, color: Colors.white),
                  Text('Eliminar', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          // ignore: missing_return
          confirmDismiss: (DismissDirection direction) async {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomAlertDialog(
                    type: AlertDialogType.QUESTION,
                    title: "Confirmación", 
                    content: 'Está seguro de eliminar el elemento',
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
                    AppSettings.API_URL+'/api/sessions/'+_sessions[index]['id'].toString(), 
                    token:_authtoken
                  );
                  if(res!=null){
                      await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomAlertDialog(
                          type: AlertDialogType.SUCCESS,
                          title: "Correcto", 
                          content: 'Elemento eliminado correctamente',
                        );
                      },
                    ).then((value){
                      getData();
                    });
                  }
                }
              });
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: (_sessions[index]['enabled'] )?AppSettings.white:AppSettings.light_grey,
              borderRadius: new BorderRadius.circular(20)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title:Text(_sessions[index]['name']) ,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Costo: \$'+_sessions[index]['cost'].toString()),
                    Text('Duración: '+_sessions[index]['duration']),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward, color: AppSettings.PRIMARY),
                onTap:()=> Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new Session(_sessions[index], NavigationHome(DrawerIndex.Sessions, Sessions())))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}