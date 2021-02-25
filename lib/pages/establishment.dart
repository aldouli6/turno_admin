
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
import 'package:turno_admin/pages/profile.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';
import 'package:turno_admin/widgets/home_drawer.dart';
import 'package:turno_admin/widgets/navigation_home.dart';


class Establishment extends StatefulWidget {
  final  Map<String, dynamic>  estab;
  Establishment( this.estab );

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
  int subcategory_id;
  int stepping;
  TextEditingController cntrl_street = new TextEditingController();
  TextEditingController cntrl_name = new TextEditingController();
  TextEditingController cntrl_num_ext = new TextEditingController();
  TextEditingController cntrl_num_int = new TextEditingController();
  TextEditingController cntrl_postal_code = new TextEditingController();
  TextEditingController cntrl_state = new TextEditingController();
  TextEditingController cntrl_city = new TextEditingController();
  TextEditingController cntrl_zone = new TextEditingController();
  TextEditingController cntrl_country = new TextEditingController();
  TextEditingController cntrl_latitude = new TextEditingController();
  TextEditingController cntrl_longitude = new TextEditingController();
  TextEditingController cntrl_email= new TextEditingController();
  TextEditingController cntrl_phone= new TextEditingController();
  String validateEmail(String value) {
    String value = cntrl_email.text;
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
     value = cntrl_phone.text;
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
        cntrl_street.text = street;
        cntrl_num_ext.text = name;
        cntrl_zone.text = subLocality;
        cntrl_city.text = locality;
        cntrl_state.text = administrativeArea;
        cntrl_postal_code.text = postalCode;
        cntrl_country.text = country;
        cntrl_latitude.text = _latlong.latitude.toString();
        cntrl_longitude.text = _latlong.longitude.toString();
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
    var data = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token: _authtoken);
    if(data.length>0){
      setState(() {
        if(sub=="%00")
          _categories = data;
        else
          _subcategories = data;
      });
      return data.length.toString();
    }else{
      setState(() {
        _subcategories = data;
      });
      return null;
    }
  }
  Future<String> getData() async {
    log(widget.estab.toString());
    String ret = await getCategories("%00"); 
    if(widget.estab==null){
      await getCurrentLocation();
    _cameraPosition=CameraPosition(target: _markerLocation, zoom: 20.0);
    }else{
      _cameraPosition=CameraPosition(target: LatLng(double.parse( widget.estab['latitude']), double.parse(widget.estab['longitude'])), zoom: 16.0);
      await _updatePosition(_cameraPosition);

      // await getCurrentAddress(_markerLocation);
      cntrl_name.text = widget.estab['name'];
      cntrl_email.text = widget.estab['email'];
      cntrl_phone.text = widget.estab['phone'];
      cntrl_num_ext.text = widget.estab['num_ext'];
      cntrl_num_int.text = widget.estab['num_int'];
      cntrl_street.text = widget.estab['street'];
      cntrl_postal_code.text = widget.estab['postal_code'];
      cntrl_city.text = widget.estab['city'];
      cntrl_zone.text = widget.estab['zone'];
      cntrl_country.text = widget.estab['country'];
    }

    return ret;
  }
  Future<String> _enviarInfo(Map<String, dynamic>  data) async {
      String url = AppSettings.API_URL+'/api/establishments';
      data['name']=cntrl_name.text;
      data['email']=cntrl_email.text;
      data['phone']=cntrl_phone.text;
      data['num_ext']=cntrl_num_ext.text;
      data['street']=cntrl_street.text;
      data['num_int']=cntrl_num_int.text;
      data['postal_code']=cntrl_postal_code.text;
      data['city']=cntrl_city.text;
      data['zone']=cntrl_zone.text;
      data['country']=cntrl_country.text;
      data['latitude']=cntrl_latitude.text;
      data['longitude']=cntrl_longitude.text;
      data['category_id']=category_id;
      data['subcategory_id']=subcategory_id;
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
  Future<String> _guardarEstab() async {
      final data = Map<String,dynamic>.from(_formKey.currentState.value);
      String url = AppSettings.API_URL+'/api/establishments/'+widget.estab['id'].toString();
      data['name']=cntrl_name.text;
      data['email']=cntrl_email.text;
      data['phone']=cntrl_phone.text;
      data['num_ext']=cntrl_num_ext.text;
      data['street']=cntrl_street.text;
      data['num_int']=cntrl_num_int.text;
      data['postal_code']=cntrl_postal_code.text;
      data['city']=cntrl_city.text;
      data['zone']=cntrl_zone.text;
      data['country']=cntrl_country.text;
      data['state']=cntrl_state.text;
      data['latitude']=cntrl_latitude.text;
      data['longitude']=cntrl_longitude.text;
      data['category_id']=widget.estab['category_id'];
      data['stepping']=widget.estab['stepping'];
      data['subcategory_id']=widget.estab['subcategory_id'];
      data['logo']=widget.estab['logo'];

      print(jsonEncode(data));

      Map<String, dynamic> res = await http.apiCall(context, _scaffoldKey, HttpServiceType.PUT, url, json: jsonEncode(data), token: _authtoken);
      
      if (res!=null) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: AlertDialogType.SUCCESS,
              title: "Correcto", content: 'Establecimiento guardado correctamente.',
            );
          },
        ).then((value){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NavigationHome(null, Profile())
            ),
          );
        });
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
    _authtoken = Provider.of<LoginState>(context, listen: false).getAuthToken();
    _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    _future = getData();
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
                      appBar('INFORMACIÓN',(widget.estab==null)?null:leadingIconBack(context),actionButton()),
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
                            controller: cntrl_name,
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
                            controller: cntrl_email,
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
                                controller: cntrl_phone,
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
                          (widget.estab!=null)?Container():FormBuilderDropdown(
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
                          (widget.estab!=null)?Container():Divider(),
                          (widget.estab!=null)?Container():(_subcategories.length>0)?FormBuilderDropdown(
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
                                subcategory_id=value;
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
                          (widget.estab!=null)?Container():FormBuilderDropdown(
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
                          (widget.estab!=null)?Container():Divider(),
                          (widget.estab!=null)?Container():FormBuilderImagePicker( 
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
                         (widget.estab!=null)?Container(): Divider(),
                          FormBuilderTextField(
                            validator:  FormBuilderValidators.required(
                              context,
                              errorText:'Este campo no puede ser vacío',
                              ),
                            name: 'street',
                            controller: cntrl_street,
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
                            controller: cntrl_num_ext,
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
                            controller: cntrl_num_int,
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
                            controller: cntrl_postal_code,
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
                            controller: cntrl_zone,
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
                            controller: cntrl_state,
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
                            controller: cntrl_city,
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
                            controller: cntrl_country,
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
                            controller: cntrl_latitude,
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
                            controller: cntrl_longitude,
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
                        if(widget.estab==null){
                          Map<String, dynamic>  data = await guardarImagen(_formKey);
                          // String image = 'await guardarImagen(_formKey)';
                          if(data!=null){
                            // print('El nuevo Id va a ser:'+image);/
                            await _enviarInfo(data);
                          }
                        }else{
                          await _guardarEstab();
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
                          child: Icon((widget.estab!=null)?Icons.save:Icons.send_outlined)
                        ),
                        (widget.estab!=null)?Text(' G U A R D A R '):Text(' E N V I A R      I N F O R M A C I Ó N', )
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