import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/establishment.dart';
import 'package:turno_admin/pages/user/details.dart';
import 'package:turno_admin/widgets/navigation_home.dart';
import 'package:turno_admin/widgets/network_image.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _imageVersion=Random().nextInt(100).toString();
  String _userId;
  String _authToken;
  String _estabId;
  String _role;
  String _direccion='';
  // ignore: unused_field
  File _image;
  Map<String,File> _images =  Map<String,File>();
  Future<Map<String, dynamic>> _future;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<String, dynamic>  _user = Map<String, dynamic>();
  Map<String, dynamic>  _estab = Map<String, dynamic>(); 

  HttpService http = new HttpService();
  final ScrollController _scrollController = ScrollController();

  Future<Map<String, dynamic>> getData() async {
    _user = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET,  AppSettings.API_URL+'/api/users/'+_userId, token: _authToken) ;
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    _estab = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, AppSettings.API_URL+'/api/establishments/'+_estabId, token: _authToken);
    if(_estab!=null){
      var numint  =_estab['num_int']??'';
          _direccion=_estab['street']+' '+_estab['num_ext'].toString()+' '+numint+' '+_estab['zone']+' '+_estab['city']+' '+_estab['state'];
    }
     return _estab;
  }
  _uploadImage(File file, String name, String id, String field) async {
    FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename:'some-file-name.png',contentType: MediaType('image','png')),
        "name":name,
        "id":id
    });
    String res = await http.apiCall(context, _scaffoldKey, HttpServiceType.IMAGE, AppSettings.API_URL+"/api/subirimagedata", formData: formData, token: _authToken);
    Map<String, String> js = {
      field:res
    };
    var result = await http.apiCall(context, _scaffoldKey, HttpServiceType.PUT, AppSettings.API_URL+"/api/"+name+"s/"+id, json: jsonEncode(js) , token: _authToken);
    print(result);
  }
    _imgFromCamera(String key) async {
      // ignore: deprecated_member_use
      File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 20
      );
      setState(() {
        _images[key] = image;
      });
    }

    _imgFromGallery(String key) async {
      // ignore: deprecated_member_use
      File image = await  ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 20
      );

      setState(() {
        _images[key] = image;
      });
    }
  showPicker(context, String name, String ruta, String id ) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galeria'),
                      onTap: () async {
                        await _imgFromGallery(name);
                        await _uploadImage(_images[name], ruta,  id, name);
                        Navigator.of(context).pop();
                        setState(() {
                          _imageVersion = Random().nextInt(100).toString();
                        });
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camara'),
                    onTap: () async {
                      await _imgFromCamera(name);
                      await _uploadImage(_images[name], ruta, id, name);
                      Navigator.of(context).pop();
                      setState(() {
                        _imageVersion = Random().nextInt(100).toString();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }
      );
  }
  

  @override
  void initState() {
    _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    _authToken = Provider.of<LoginState>(context, listen: false).getAuthToken();
    _estabId = Provider.of<LoginState>(context, listen: false).getEstablishment();
    _role = Provider.of<LoginState>(context, listen: false).getRole();
    _future = getData();
    print(_role);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double _heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppSettings.LIGTH,
      key: _scaffoldKey,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return  SingleChildScrollView(
              child: Container(
                height: _heigth +  _heigth * 0.12,
                color: AppSettings.notWhite,
                child: Stack(
                  children: <Widget>[
                      InkWell(
                        child: SizedBox(
                          height: _heigth * 0.36,
                          width: double.infinity,
                          child: PNetworkImage(
                            AppSettings.API_URL+'/storage/'+_estab['logo']+'?v='+_imageVersion,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () {
                          if(_role=='admin')
                            showPicker(context, 'logo', 'establishment', _estab['id'].toString());
                        },
                      ),
                     Container(
                      margin: EdgeInsets.fromLTRB(16.0,_heigth * 0.24, 16.0, 16.0),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(16.0),
                                margin: EdgeInsets.only(top: 16.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 96.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _user['name']+' '+_user['lastname'],
                                            // ignore: deprecated_member_use
                                            style: Theme.of(context).textTheme.title,
                                          ),
                                          ListTile(
                                            contentPadding: EdgeInsets.all(0),
                                            title: Text(_user['email']),
                                            subtitle: Text(_user['phone']),
                                            trailing: IconButton(
                                            icon: Icon(Icons.edit), 
                                              onPressed: () {  
                                                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new User(_user, NavigationHome(null, Profile()))));
                                              },),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  // color: AppSettings.white,
                                  child: PNetworkImage(
                                    AppSettings.API_URL+'/storage/'+_user['imagen'].toString()+'?v='+_imageVersion,
                                    fit: BoxFit.cover,
                                    ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      
                                      ),
                                  margin: EdgeInsets.only(left: 16.0),
                                ),
                                onTap: () {
                                  showPicker(context, 'imagen', 'user', _userId);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: Scrollbar(
                              isAlwaysShown: false,
                              controller: _scrollController,
                              child: ListView(
                                controller: _scrollController,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text("Información de Establecimiento"),
                                          trailing: (_role!='user')?
                                          IconButton(
                                            icon: Icon(Icons.edit), 
                                            onPressed: () {  
                                              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new Establishment(_estab)));
                                            },)
                                          :null,
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text("Nombre"),
                                          subtitle: Text(_estab['name']),
                                          leading: Icon(Icons.short_text),
                                        ),
                                        ListTile(
                                          title: Text("Email"),
                                          subtitle: Text(_estab['email']),
                                          leading: Icon(Icons.email),
                                        ),
                                        ListTile(
                                          title: Text("Phone"),
                                          subtitle: Text(_estab['phone']),
                                          leading: Icon(Icons.phone),
                                        ),
                                        ListTile(
                                          title: Text("Direccion"),
                                          subtitle: Text(_direccion),
                                          leading: Icon(Icons.map)
                                        ),
                                        ListTile(
                                          title: Text("Categoria"),
                                          subtitle: Text(_estab['category_name']),
                                          leading: Icon(Icons.category),
                                        ),
                                        ListTile(
                                          title: Text("SubCategoria"),
                                          subtitle: Text(_estab['subcategory_name']),
                                          leading: Icon(Icons.category_outlined),
                                        ),
                                        ListTile(
                                          title: Text("Fecha de ingreso"),
                                          subtitle: Text(_estab['created_at']),
                                          leading: Icon(Icons.calendar_today),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // AppBar(
                    //   backgroundColor: Colors.transparent,
                    //   elevation: 0,
                    // )
                  ]
                ),
              )
            );
          }
        }
      )
    );
  }

  
}