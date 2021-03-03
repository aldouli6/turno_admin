import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/prospect/details.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/network_image.dart';

class Prospects extends StatefulWidget {
  @override
  _ProspectsState createState() => _ProspectsState();
}


class _ProspectsState extends State<Prospects> {

  List< dynamic> _prospectos = List< dynamic>();
  String _authtoken='';
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  HttpService http = new HttpService();
  Future<String> _future;
  
  Widget actionButtons(BuildContext context){
    return InkWell(
      borderRadius:
          BorderRadius.circular(AppBar().preferredSize.height),
      child: Icon(
        FontAwesomeIcons.plusCircle,
        color: AppSettings.PRIMARY,
      ),
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new Prospect(0)));
      },
    );
  }
  Future<String> getProspects() async {
    String url =  AppSettings.API_URL+'/api/prospects';
    Map<String, dynamic> response = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token:_authtoken);
    setState(() {
      _prospectos = response['data'];
    });
    return response['data'].toString();
  }
  @override
  void initState() {
    super.initState();
     _future = getProspects();
    setState(() {
      _authtoken = Provider.of<LoginState>(context, listen: false).getAuthToken();
     
    });
  }
  @override
  Widget build(BuildContext context) {

    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<String>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBar('Prospectos',null, actionButtons(context), AppSettings.PRIMARY),
                  Expanded(child: Center(child: Text('No hay prospectos'))),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBar('Prospectos',null, actionButtons(context), AppSettings.PRIMARY),
                  (_prospectos.isNotEmpty)?Expanded(
                      child: RefreshIndicator(
                        onRefresh: () =>getProspects(),
                        child: ListView.builder(
                        padding: EdgeInsets.all(6),
                        itemCount: _prospectos.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 3,
                            child: Row(
                              children: <Widget>[ 
                                Container(
                                  width: 110,
                                  height: 110,
                                  child:PNetworkImage(
                                    AppSettings.API_URL+'/storage/'+ _prospectos[index]['image'],
                                    fit: BoxFit.fitWidth                                  
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: _width -146,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _prospectos[index]['name'],
                                          style: TextStyle(
                                              color: AppSettings.PRIMARY,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17),
                                        ),
                                        Text(
                                          _prospectos[index]['phone'],
                                          style: TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                        Text(
                                          _prospectos[index]['address'],
                                          style: TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            SizedBox(
                                            height: 20.0,
                                            width: 20.0,
                                              child: IconButton(
                                                iconSize: 20,
                                                padding: EdgeInsets.all(0),
                                                icon: Icon(Icons.edit),
                                                color: AppSettings.SECONDARY,
                                                onPressed: () {
                                                  Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new Prospect(_prospectos[index]['id'])));

                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            SizedBox(
                                              height: 20.0,
                                              width: 20.0,
                                              child: IconButton(
                                                iconSize: 20,
                                                padding: EdgeInsets.all(0),
                                                icon: Icon(FontAwesomeIcons.trash),
                                                color: AppSettings.DANGER,
                                                onPressed: () {},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                    ),
                      ),
                  ):Expanded(child: Center(child:CircularProgressIndicator())),
                ],
              ),
            ) ;
          }
        }
      )
    );
  }
}