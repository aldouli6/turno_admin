
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/pages/home_screen.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';
import 'package:turno_admin/widgets/home_drawer.dart';
import 'package:turno_admin/widgets/navigation_home.dart';


class Establishment extends StatefulWidget {
  static final String path = "lib/src/pages/hotel/hhome.dart";

  @override
  _EstablishmentState createState() => _EstablishmentState();
}

class _EstablishmentState extends State<Establishment> {
  CameraPosition _cameraPosition;
  GoogleMapController _mapController ;
  LatLng _markerLocation = LatLng(20.587954, -100.3880030) ;
  LatLng _latlong;
  final Set<Marker> _markers = {};
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<String> _future;
  HttpService http = new HttpService();
  List _categories =List();
  List _subcategories =List();
  String _authtoken='';
  String _userId='';
  int category_id;
  int subcategery_id;
  int stepping;
  TextEditingController cntrlStreet = new TextEditingController();
  TextEditingController cntrlName = new TextEditingController();
  TextEditingController cntrlNumExt = new TextEditingController();
  TextEditingController cntrlCP = new TextEditingController();
  TextEditingController cntrlState = new TextEditingController();
  TextEditingController cntrlCity = new TextEditingController();
  TextEditingController cntrlZone = new TextEditingController();
  TextEditingController cntrlCountry = new TextEditingController();
  TextEditingController cntrlLat = new TextEditingController();
  TextEditingController cntrlLng = new TextEditingController();
  TextEditingController cntrlEmail= new TextEditingController();
  TextEditingController cntrlPhone= new TextEditingController();
  String validateEmail(String value) {
    String value = cntrlEmail.text;
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Ingresa un correo valido';
    else
      return null;
  }
  
  Widget actionButton(){
    return InkWell(
      onTap:()=> getCurrentLocation(),
    );
  }
  String validateMobile(String value) {
     value = cntrlPhone.text;
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
          return 'Ingresa un número telefónico';
    }
    else if (!regExp.hasMatch(value)) {
          return 'Ingresa un teléfono válido';
    }
    return null;
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
  getCurrentAddress(_latlong) async{
    print(_latlong);
    var address;
    String name ="";
    String street="";
    String subLocality ="";
    String locality ="";
    String administrativeArea ="";
    String subadministrativeArea ="";
    String postalCode ="";
    String country ="";
    try {
    List<Placemark> placemarks = await placemarkFromCoordinates(_latlong.latitude, _latlong.longitude);     
    // Placemark placeMark  = placemarks[0]; 
    for (Placemark placeMark in placemarks) {
      name =(name!="")?name: placeMark.name;
      street = (street!="")? street: placeMark.thoroughfare.toString();
      subLocality = (subLocality!="")?subLocality:placeMark.subLocality;
      locality = (locality!="")?locality: placeMark.locality;
      administrativeArea =(administrativeArea!="")?administrativeArea: placeMark.administrativeArea;
      subadministrativeArea =(subadministrativeArea!="")?subadministrativeArea: placeMark.subAdministrativeArea;
      postalCode = (postalCode!="")?postalCode: placeMark.postalCode;
      country = (country!="")?country: placeMark.country;
    }
    locality = (locality!="")?locality:subadministrativeArea;
     address = "$street $name, $subLocality, $locality, $administrativeArea $postalCode, $country";
     log(address);
    }  on PlatformException catch (err) {
      address = 'Dirección no encontrada '+err.message;
    }catch (error) {
      address = 'Not found';
    }
    setState(() {
        cntrlStreet.text = street;
        cntrlNumExt.text = name;
        cntrlZone.text = subLocality;
        cntrlCity.text = locality;
        cntrlState.text = administrativeArea;
        cntrlCP.text = postalCode;
        cntrlCountry.text = country;
        cntrlLat.text = _latlong.latitude.toString();
        cntrlLng.text = _latlong.longitude.toString();
    });
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
      // controllerLat.text = lat.toString() ;
      // controllerLng.text = lng.toString();
    });
  }
  Future<void> _onCameraIdle() async {
      await getCurrentAddress(_markerLocation);
  }
  Future<void> _onMapCreated(GoogleMapController controller) async {
      _mapController=(controller);
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(_cameraPosition)
      );                       
  }
  Future<String>  getCategories(String sub) async {
    String url =  AppSettings.API_URL+'/api/categories?parentCategory='+sub;
    Map<String, dynamic> data = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token: _authtoken);
    //  print();
    if(data['data'].length>0){
      setState(() {
        if(sub=="%00")
          _categories = data['data'];
        else
          _subcategories = data['data'];
      });
      return data['data'].length.toString();
    }else{
      setState(() {
        _subcategories = data['data'];
      });
      return null;
    }
  }
  Future<String> getData() async {
     _cameraPosition=CameraPosition(target: _markerLocation, zoom: 20.0);
      await getCurrentLocation();
      String ret = await getCategories("%00");
      print(ret);
      return ret;
  }
  Future<String> _enviarInfo(Map<String, dynamic>  data) async {
      String url = AppSettings.API_URL+'/api/establishments';
      data['name']=cntrlName.text;
      data['email']=cntrlEmail.text;
      data['phone']=cntrlPhone.text;
      data['num_ext']=cntrlNumExt.text;
      data['cp']=cntrlCP.text;
      data['city']=cntrlCity.text;
      data['zone']=cntrlZone.text;
      data['country']=cntrlCountry.text;
      data['latitude']=cntrlLat.text;
      data['longitude']=cntrlLng.text;
      data['categery_id']=category_id;
      data['subcategery_id']=subcategery_id;
      data['stepping']=stepping;

      print(jsonEncode(data));

      Map<String, dynamic> res = await http.apiCall(context, _scaffoldKey, HttpServiceType.POST, url, json: jsonEncode(data), token: _authtoken);
      if(res['data']!=null){
        var datos={
          "establishment_id":res['data']['id'],
          "role":"admin"
        };
        print(datos);
        String url = AppSettings.API_URL+'/api/users/'+_userId;
        Map<String, dynamic> result = await http.apiCall(context,
         _scaffoldKey, 
         HttpServiceType.PUT, 
         url,
         json: jsonEncode(datos),
         token: _authtoken
        );
        if (result['data']!=null) {
          Provider.of<LoginState>(context, listen: false).changeRole('admin');
          _customAlertDialog(context, AlertDialogType.SUCCESS);
        }
      }


      return null;
  }

  _customAlertDialog(BuildContext context, AlertDialogType type) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          type: type,
          title: "Establecimiento Registrado",
          content: "A continuación encontrará el resto de configuraciones en el menú de la derecha.",
        );
      },
    ).then((value){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationHome(DrawerIndex.HOME, Home())
              ),
            );
    });
  }
  Future<Map<String, dynamic> > guardarImagen(GlobalKey<FormBuilderState> _formKey) async {
    _formKey.currentState.save();
    
    File file;
    final data = Map<String,dynamic>.from(_formKey.currentState.value);
    if(data['logo']!=null){
      var imagePath = data['logo'][0];
      file = imagePath as File;
    }
    FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename:'some-file-name.png',contentType: MediaType('image','png')),
        "name":"establishment",
    });
    print(formData);
    Map<String, dynamic> res = await http.apiCall(context, _scaffoldKey, HttpServiceType.IMAGE, AppSettings.API_URL+"/api/subirimagedata", formData: formData, token: _authtoken);
    
    if(res['data']!=null){
      final data = Map<String,dynamic>.from(_formKey.currentState.value);
      data['logo']=res['data'];
      return data;
    }else{
      return null;
    }   
  }

  Widget iconTooltip(String _name, IconData _icon, String _msg){
    return Tooltip(
      message: _msg,
      child: Icon(
          _icon,
        ),
    );
  }
  @override
  void initState() {
    _future = getData();
    _authtoken = Provider.of<LoginState>(context, listen: false).getAuthToken();
    _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    final node = FocusScope.of(context);
    return Scaffold(
      key: _scaffoldKey,
      body:
      FutureBuilder<String>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: CircularProgressIndicator()),
                        SizedBox(height: 15,),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Text('Por el momento no está disponible, vuelva más tarde.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        ),
                      ],
                    )
                  ),
                ],
              ),
            );
          } else {
            return  Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Material(
                        elevation: 5,
                          child: Container(
                          height: MediaQuery.of(context).size.height/3.5,
                          child: GoogleMap(
                            myLocationEnabled: true,
                            zoomGesturesEnabled: true,
                            initialCameraPosition: _cameraPosition,
                            onCameraMove: ((_position){
                              if(true)
                                _updatePosition(_position);
                              }
                            ),
                            onMapCreated: _onMapCreated,
                            markers:_markers ,
                            onCameraIdle: ((){
                              _onCameraIdle();
                              }),
                          ),
                        ),
                      ),
                      appBar('INFORMACIÓN',null,actionButton()),
                    ],
                  ),
                  Expanded(
                    child:FormBuilder(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: [
                          FormBuilderTextField(
                            validator: FormBuilderValidators.required(
                                context,
                                errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'name',
                            controller: cntrlName,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              hintText: 'Nombre',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                              prefixIcon: Icon(Icons.short_text),
                              suffixIcon: iconTooltip('name', Icons.help, 'Este es el nombre de su establecimiento'),
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            validator: validateEmail,
                            name: 'email',
                            controller: cntrlEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'E-mail',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48),
                              prefixIcon: Icon(Icons.email)
                            ),
                          ), 
                          Divider(),
                           FormBuilderPhoneField(
                                name: 'phone',
                                controller: cntrlPhone,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: const InputDecoration(
                                  hintText: 'Teléfono',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.phone)
                                ),
                                priorityListByIsoCode: ['MX'],
                                defaultSelectedCountryIsoCode: 'MX',
                                countryFilterByIsoCode: ['MX'],
                                isSearchable: false,
                                validator: validateMobile
                              ),
                          Divider(),
                          FormBuilderDropdown(
                            name: 'category_id',
                            decoration: InputDecoration(
                              labelText: 'Categoria',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                              prefixIcon: Icon(Icons.category),
                            ),
                            allowClear: true,
                            onChanged: (value) {
                              getCategories(value.toString());
                              setState(() {
                                category_id=value;
                              });
                            },
                            hint: Text('Selecciona una categoria'),
                            validator: FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            items: _categories
                                .map((cat) => DropdownMenuItem(
                                      value: cat['id'],
                                      child: Text(cat["name"]),
                                    ))
                                .toList(),
                          ),
                          Divider(),
                          (_subcategories.length>0)?FormBuilderDropdown(
                            name: 'subcategory_id',
                            decoration: InputDecoration(
                              labelText: 'Subcategoria',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            allowClear: true,
                            onChanged: (value) {
                              setState(() {
                                subcategery_id=value;
                              });
                            },
                            hint: Text('Selecciona una subcategoria'),
                            validator: FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            items: _subcategories
                                .map((cat) => DropdownMenuItem(
                                      value: cat['id'],
                                      child: Text(cat["name"]),
                                    ))
                                .toList(),
                          ):Container(),
                          (_subcategories.length>0)?Divider():Container(),
                          FormBuilderDropdown(
                            name: 'stepping',
                            decoration: InputDecoration(
                              labelText: 'Intervalo',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48),
                              prefixIcon: Icon(Icons.timer),
                              suffixIcon: iconTooltip('stepping', Icons.help, 'Es el intervalo de tiempo que tendrán las sesiones de su establecimiento.'),
                            ), 
                            allowClear: false,
                            onChanged: (value) {
                              setState(() {
                                stepping = value;
                              });
                            },
                            hint: Text('Selecciona una intervalo'),
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            items: [5,10,15,30,60]
                                .map((step) => DropdownMenuItem(
                                      value: step,
                                      child: Text(step.toString()+' min'),
                                    ))
                                .toList(),
                          ),
                          Divider(),
                           FormBuilderImagePicker( 
                            validator:
                             FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'logo',
                            decoration: const InputDecoration(
                              labelText: 'Imágen',
                              helperText: 'Esta será la imagen como tus clientes te identificarán, se recomiendq su logo.',
                              helperMaxLines: 2,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48),
                            ),
                            maxImages: 1,
                          ),
                          Divider(),
                          FormBuilderTextField(
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'street',
                            controller: cntrlStreet,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Calle',
                              hintText: 'Calle',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                              prefixIcon: Icon(FontAwesomeIcons.road)
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'num_ext',
                            controller: cntrlNumExt,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Número Exterior',
                              hintText: 'Número Exterior',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                              prefixIcon: Icon(FontAwesomeIcons.hashtag)
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            name: 'num_int',
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Número Interior',
                              hintText: 'Número Interior',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                              prefixIcon: Icon(FontAwesomeIcons.hashtag, size: 15,)
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'postal_code',
                            keyboardType: TextInputType.number,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            controller: cntrlCP,
                            decoration: InputDecoration(
                              labelText: 'Código Postal',
                              hintText: 'Código Postal',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            name: 'zone',
                            textInputAction:  TextInputAction.next,
                            controller: cntrlZone,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Colonia',
                              hintText: 'Colonia',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'state',
                            readOnly: true,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            controller: cntrlState,
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              hintText: 'Estado',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'city',
                            readOnly: true,
                            controller: cntrlCity,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Ciudad',
                              hintText: 'Ciudad',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                          
                          FormBuilderTextField(
                            name: 'country',
                            readOnly: true,
                            textInputAction:  TextInputAction.next,
                            controller: cntrlCountry,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'País',
                              hintText: 'Páis',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            name: 'latitude',
                            readOnly: true,
                            controller: cntrlLat,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Latitud',
                              hintText: 'Latitud',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                          FormBuilderTextField(
                            name: 'longitude',
                            readOnly: true,
                            controller: cntrlLng,
                            textInputAction:  TextInputAction.next,
                            onEditingComplete: () => node.nextFocus(),
                            decoration: InputDecoration(
                              labelText: 'Longitud',
                              hintText: 'Longitud',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left:48, right: 48),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    )
                  ),
                  FlatButton(
                    textColor: AppSettings.white,
                    height:  AppBar().preferredSize.height ,
                    color: AppSettings.PRIMARY,
                    disabledTextColor: AppSettings.DARK,
                    disabledColor: AppSettings.LIGTH,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState.validate()) {
                        Map<String, dynamic>  data = await guardarImagen(_formKey);
                        // String image = 'await guardarImagen(_formKey)';
                        if(data!=null){
                          // print('El nuevo Id va a ser:'+image);/
                          await _enviarInfo(data);
                        }
                      }else{
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content:Text('Hay algunos campos que no están completos.'
                            ),
                            backgroundColor: AppSettings.DANGER,
                          )
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.send_outlined)
                        ),
                        Text(' E N V I A R      I N F O R M A C I Ó N', )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }  
      ),
    );
  }
}