import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/prospect/index.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart' ;
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:turno_admin/widgets/home_drawer.dart';
import 'package:turno_admin/widgets/navigation_home.dart';
import 'package:turno_admin/widgets/network_image.dart';

class Prospect extends StatefulWidget {
  final int prospectId;
  Prospect( this.prospectId );
  @override
  _ProspectState createState() => _ProspectState();
}


class _ProspectState extends State<Prospect> {

  TextEditingController controllerName= new TextEditingController();
  TextEditingController controllerOwner = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();
  TextEditingController controllerLat = new TextEditingController();
  TextEditingController controllerLng= new TextEditingController();
  TextEditingController controllerAddress = new TextEditingController();
  TextEditingController controllerNotes = new TextEditingController();
  var dio = Dio();
  final _formKey = GlobalKey<FormBuilderState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  HttpService http = new HttpService();
  String _title='Nuevo';
  String _authtoken='';
  Future<String> _future;
  String _userId='';
  LatLng _latlong=null;
  String _image=null;
  CameraPosition _cameraPosition;
  GoogleMapController _mapController ;
  LatLng _markerLocation = LatLng(20.587954, -100.3880030) ;

  final Set<Marker> _markers = {};
  List<Address> results = [];
  String _direccion = '';
  getCurrentAddress(_latlong) async{
    print(_latlong);
    var address;
    try {
    List<Placemark> placemarks = await placemarkFromCoordinates(_latlong.latitude, _latlong.longitude);     
    Placemark placeMark  = placemarks[0]; 
    String name = placeMark.name;
    String street = placeMark.thoroughfare;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
     address = "$street $name, $subLocality, $locality, $administrativeArea $postalCode, $country";
    }  on PlatformException catch (err) {
      address = 'Dirección no encontrada '+err.message;
    }catch (error) {
      address = 'Not found';
    }
    setState(() {
        controllerAddress.text= _direccion =  address;
      });
  }
  Future getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != PermissionStatus.granted) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != PermissionStatus.granted)
        getLocation();
      return;
    }
    getLocation();
  }

  getLocation() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.latitude);
    setState(() {
      _markerLocation = _latlong=new LatLng(position.latitude, position.longitude);
      _cameraPosition=CameraPosition(target:_latlong,zoom: 16.0 );
      if(_mapController!=null)
        _mapController.animateCamera(
            CameraUpdate.newCameraPosition(_cameraPosition));
      // _markers.add(Marker(markerId: MarkerId("a"),draggable:true,position: _latlong));
      getCurrentAddress(_latlong);
    });
  }
  Future<void> _onCameraIdle() async {
      await getCurrentAddress(_markerLocation);
  } 
  Future<void>  _updatePosition(CameraPosition _position) async{
    Marker marker = _markers.firstWhere(
        (p) => p.markerId == MarkerId('firstPoint'),
        orElse: () => null);
    double lat = double.parse((_position.target.latitude).toStringAsFixed(7));
    double lng = double.parse((_position.target.longitude).toStringAsFixed(6));
    //  _hasAdress = false;
      // _direccion = 'Dirección no encontrada';
  
    _markers.remove(marker);
    _markers.add(
      Marker(
        markerId: MarkerId('firstPoint'),
        position: LatLng(lat, lng),
        draggable: true,
      ),
    );
    setState(() {

      _markerLocation = LatLng(lat, lng);
      controllerLat.text = lat.toString() ;
      controllerLng.text = lng.toString();
    });
  }
  Future<String> getData() async {
      // await Future<dynamic>.delayed(const Duration(milliseconds: 2));
        if(widget.prospectId!=0){
          await getProspectInfo(widget.prospectId);
           return widget.prospectId.toString();
        }else{
          _cameraPosition=CameraPosition(target: LatLng(0, 0),zoom: 20.0);
          await getCurrentLocation();
        }
      return widget.prospectId.toString();
    }
  Widget actionButtons( ){
    return IconButton(
      icon: const Icon(Icons.save),
      color: AppSettings.PRIMARY,
      onPressed: () async {
        bool validated = _formKey.currentState.validate();
        if(validated){
          File file =null;
          _formKey.currentState.save();
          final data = Map<String,dynamic>.from(_formKey.currentState.value);
          data['latitude']=controllerLat.text;
          data['longitude']=controllerLng.text;
          data['phone']=controllerPhone.text;
          if(data['image']!=null){
            var imagePath = data['image'][0];
            file = imagePath as File;
          }
          data['image']="prospects/prospect_";
          int elid=0;
          Map<String, dynamic>  res= Map<String, dynamic>();
          elid =await saveProspect(data, widget.prospectId); 
          if(file!=null){
            FormData formData = FormData.fromMap({
                "image": await MultipartFile.fromFile(file.path, filename:'some-file-name.png',contentType: MediaType('image','png')),
                "name":"propects/prospect_"+elid.toString(),
            });
             res = await http.apiCall(context, _scaffoldKey, HttpServiceType.IMAGE, AppSettings.API_URL+"/api/subirimagedata", formData: formData, token: _authtoken);
            //res = await uploadImage2(context:context, url:AppSettings.API_URL+"/api/subirimagedata", file:file , name: "propects/prospect_"+elid.toString(), token:_authtoken );
           }
           if(res!=null){
          print('object');
          await Future<dynamic>.delayed(const Duration(seconds: 2));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationHome(DrawerIndex.Propspects, Prospects())
              ),
            );
           }
        
        }
      },
    );
  }
  Future<dynamic> uploadImage2( { BuildContext context, String url, File file, String name,String token,})async{ 

    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    String result;
    try {
      FormData formData = FormData.fromMap({
          "image": await MultipartFile.fromFile(file.path, filename:'some-file-name.png',contentType: MediaType('image','png')),
          "name":name,
      });
      // if(token!='')
      //   dio.options.headers["Authorization"] = "Bearer $token";

      await pr.show();
      var response = await dio.post(url, 
        data: formData,
        onSendProgress: (int sent, int total) {
          pr.update(
            progress: sent.toDouble(),
            maxProgress: total.toDouble()
          );
          log("$sent $total");
        },
      );
      await pr.hide();
      
      return response.toString();
    } on SocketException catch(e){
        print(e);
      result = "Sin conexíon a internet o al servidor 😑";
    } on HttpException  catch(e){
        print(e);
      result="No se encontró el documento 😱";
    } on FormatException  catch(e){
        print(e);
      print(url);
      result="Respuesta en mal formato 👎";
    } on Exception  catch(e){
        print(e);
      result="Otro tipo de Excepción 👎";
    }
    await pr.hide();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content:Text(result.toString()
        ),
        backgroundColor: AppSettings.DANGER,
      )
    );
    return null;
  }
  
  Future<int> saveProspect(Map<String,dynamic> data, int prospectId)  async {
    String xtraurl='';
    HttpServiceType type=HttpServiceType.POST;
    if (prospectId != 0) {
        type=HttpServiceType.PUT;
        xtraurl = '/'+prospectId.toString();
    }
    String url = AppSettings.API_URL+'/api/prospects'+xtraurl;
    String json = jsonEncode(data);
    Map<String, dynamic> response  = await http.apiCall(context, _scaffoldKey, type, url, json: json, token: _authtoken);
    return response['data']['id'];
  }
  
  Widget _leadingIcon(){  
    return IconButton(
      icon: const Icon(Icons.clear),
      color: AppSettings.PRIMARY,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  Future<String> getProspectInfo(int id) async {
    String url =  AppSettings.API_URL+'/api/prospects/'+id.toString();
    Map<String, dynamic> response = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token: _authtoken);
    _cameraPosition=CameraPosition(target: LatLng(double.parse(response['data']['latitude']), double.parse(response['data']['longitude'])),zoom: 17.0);
    await _updatePosition(_cameraPosition);
    setState(() {
      controllerAddress.text =  response['data']['address'];
      controllerName.text =  response['data']['name'];
      controllerOwner.text =  response['data']['owner'];
      controllerPhone.text =  response['data']['phone'];
      controllerNotes.text=  response['data']['notes'];
      _image =   response['data']['image'];
      _title= response['data']['name'];   
    });
    return response['data'].toString();
  }
  String validateMobile(String value) {
    value = controllerPhone.text;
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
          return 'Please enter mobile number';
    }
    else if (!regExp.hasMatch(value)) {
          return 'Please enter valid mobile number';
    }
    return null;
  }  
  @override
  void initState() {
    super.initState();

    _future = getData();
    setState(() {
      _authtoken = Provider.of<LoginState>(context, listen: false).getAuthToken();
      _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    });
  }
      
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            key: _scaffoldKey,
            body: 
            FutureBuilder<String>(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return
                   Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appBar(_title,_leadingIcon(),actionButtons()),
                        Container(
                          height: 200,
                          child: Center(
                            child: (_cameraPosition!=null)?GoogleMap(
                              myLocationEnabled: true,
                              initialCameraPosition: _cameraPosition,
                              onCameraMove: ((_position){
                                if(true)
                                  _updatePosition(_position);
                                }
                                  ),
                              onMapCreated: (GoogleMapController controller){
                                _mapController=(controller);
                                _mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(_cameraPosition)
                                );
                              },
                              markers:_markers ,
                              onCameraIdle: ((){
                                _onCameraIdle();
                                }),
                            ):Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              FormBuilder(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    FormBuilderTextField(
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(context),
                                      ]),
                                      name: 'name',
                                      controller: controllerName,
                                      decoration: InputDecoration(
                                        labelText: 'Nombre',
                                        hintText: 'Nombre',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48),
                                      ),
                                    ),
                                    Divider(),
                                    FormBuilderTextField(
                                      name: 'owner',
                                      controller: controllerOwner,
                                      decoration: InputDecoration(
                                        labelText: 'Dueño',
                                        hintText: 'Dueño',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48),
                                      ),
                                    ),
                                    Divider(),
                                    FormBuilderPhoneField(
                                      name: 'phone',
                                      controller: controllerPhone,
                                      decoration: const InputDecoration(
                                        labelText: 'Teléfono',
                                        hintText: 'Teléfono',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48),
                                      ),
                                      priorityListByIsoCode: ['MX'],
                                      defaultSelectedCountryIsoCode: 'MX',
                                      validator: validateMobile,
                                    ),
                                    Divider(),
                                    Stack(
                                        children:[
                                    Container(
                                      width: 130,
                                      height: 130,
                                      margin: const EdgeInsets.only(left:48, top: 15),
                                      child:(widget.prospectId!=0)?PNetworkImage(
                                        AppSettings.API_URL+'/storage/'+_image
                                      ):Container(),
                                    ),
                                      FormBuilderImagePicker(
                                        name: 'image',
                                        decoration: const InputDecoration(
                                          labelText: 'Foto',
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.only(left:48),
                                        ),
                                        maxImages: 1,
                                      ),
                                      ] 
                                    ),
                                    Divider(),
                                    FormBuilderTextField(
                                      name: 'address',
                                      controller: controllerAddress,
                                      maxLines: 5,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Dirección',
                                        labelText: 'Dirección',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48),
                                        prefixIcon: Icon(Icons.short_text)
                                      ),
                                    ),
                                    Divider(),
                                    FormBuilderTextField(
                                      name: 'notes',
                                      controller: controllerNotes,
                                      maxLines: 5,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Notas',
                                        labelText: 'Notas',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48),
                                        prefixIcon: Icon(Icons.short_text)
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                )
                              )
                            ],
                          ),
                        )
      
                      ],
                    ),
                  ) ;
                }
              }
            )
          );
        }
      
        
}