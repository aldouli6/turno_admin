
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  List equipos =List();
  bool _valueCheck = false;
  String equipoId;
  TextEditingController controllerName = new TextEditingController();
  TextEditingController controllerLastname= new TextEditingController();
  TextEditingController controllerUsername= new TextEditingController();
  TextEditingController controllerRefcode= new TextEditingController();
  TextEditingController controllerEmail= new TextEditingController();
  TextEditingController controllerPhone= new TextEditingController();
  TextEditingController controllerPass= new TextEditingController();
  TextEditingController controllerConfirmPass= new TextEditingController();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  HttpService http = new HttpService();
  Future<String> _future;
  bool _mapa = true;

  void _signUp(GlobalKey<FormBuilderState> _formKey) async {
     _formKey.currentState.save();
    Map<String,dynamic> data = Map<String,dynamic>.from(_formKey.currentState.value);
    data['role']='preadmin';
    print(jsonEncode( data));
    Map<String, dynamic> response  = await http.apiCall(
      context, 
      _scaffoldKey, 
      HttpServiceType.POST, 
      AppSettings.API_URL+'/api/register',
      json: jsonEncode(data)
    );
    if(response['data']!=null)
      _customAlertDialog(context, AlertDialogType.SUCCESS , response['user']['email']);
    
  }
  _customAlertDialog(BuildContext context, AlertDialogType type, String response) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          type: type,
          title: "Registro Correcto",
          content: "Su usario ha sido registrado correctamente, favor de verificar su correo $response.",
        );
      },
    ).then((value){
          Navigator.pop(context);//
    });
  }
  Future<String> getData() async {
      await Future<dynamic>.delayed(const Duration(milliseconds: 2));
      // _cameraPosition=CameraPosition(target: _markerLocation, zoom: 20.0);
      // await getCurrentLocation();
      return 'algo';
    }
  
   void initState() {
    super.initState();
    _future = getData();
  }
  Widget _leadingIcon(){  
    return IconButton(
      icon: const Icon(Icons.clear),
      color: AppSettings.PRIMARY,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  String validateEmail(String value) {
    String value = controllerEmail.text;
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Ingresa un correo valido';
    else
      return null;
  }
  String validateMobile(String value) {
     value = controllerPhone.text;
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
  String validateConfirm(String value) {
     value = controllerConfirmPass.text;
    if (value.length == 0) {
          return 'Ingresa la contraseña de confirmación';
    }
    else if (value != controllerPass.text) {
          return 'La contraseña no coincide';
    }
    return null;
  } 
  // void onCheckChanged(bool val){
  //   va
  // }
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return  Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder<String>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return  Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBar('Registro',_leadingIcon(),null, AppSettings.PRIMARY),
                  Expanded(
                    child: ListView(
                       padding: const EdgeInsets.all(8),
                      children: [
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              FormBuilderTextField(
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                    context,
                                    errorText:'Este campo no puede ser vacío',
                                  ),
                                ]),
                                name: 'name',
                                controller: controllerName,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: 'Nombre',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.short_text)
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'lastname',
                                controller: controllerLastname,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Apellido(s)',
                                  hintText: 'Apellido(s)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.short_text_sharp)
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                    context,
                                    errorText:'Este campo no puede ser vacío',
                                  ),
                                ]),
                                name: 'user_name',
                                controller: controllerUsername,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Username',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(FontAwesomeIcons.userAlt)
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                validator: validateEmail,
                                name: 'email',
                                controller: controllerEmail,
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
                                controller: controllerPhone,
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
                              FormBuilderTextField(
                                name: 'password',
                                obscureText: true,
                                controller: controllerPass,
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                    context,
                                    errorText:'Este campo no puede ser vacío',
                                  ),
                                  FormBuilderValidators.minLength(
                                    context, 
                                    8,
                                    errorText:'El campo debe tener igual o más de 8 carácteres',
                                    )
                                ]),
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  hintText: 'Contraseña',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.vpn_key)
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'password_confirmation',
                                obscureText: true,
                                controller: controllerConfirmPass,
                                validator: validateConfirm,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Confirmar Contraseña',
                                  hintText: 'Confirmar Contraseña',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.vpn_key)
                                ),
                              ),
                              Divider(),
                              FormBuilderCheckbox(
                                name: 'terms',
                                initialValue: false,
                                onChanged: (value){
                                  setState(() {
                                    _valueCheck = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Estoy de acuerdo con los ',
                                        style: TextStyle(color: AppSettings.nearlyBlack),
                                      ),
                                      TextSpan(
                                        text: 'Términos y condiciones',
                                        style: TextStyle(color: AppSettings.PRIMARY),
                                        // recognizer: TapGestureRecognizer()
                                        //   ..onTap = () {
                                        //     print('launch url');
                                        //   },
                                      ),
                                    ],
                                  ),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                    context,
                                    errorText:
                                        'You must accept terms and conditions to continue',
                                  ),
                                ],),
                              ),

                              Divider(),
                              FormBuilderTextField(
                                name: 'ref_code',
                                controller: controllerRefcode,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.unfocus(),
                                decoration: InputDecoration(
                                  labelText: 'Código de Referencia',
                                  hintText: 'Código de Referencia',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(FontAwesomeIcons.userFriends)

                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),   
                  ),
                  FlatButton(
                    textColor: AppSettings.white,
                    height: AppBar().preferredSize.height ,
                    color: AppSettings.PRIMARY,
                    disabledTextColor: AppSettings.DARK,
                    disabledColor: AppSettings.LIGTH,
                    onPressed: (_valueCheck)
                    ?() {
                      if (_formKey.currentState.validate()) {
                        _signUp(_formKey);
                      }
                    }
                    :null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle_outline_sharp, color: (_valueCheck)?AppSettings.white:AppSettings.DARK),
                        ),
                        Text('R E G I S T R A R M E', )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }
      )
    );
  }
}
