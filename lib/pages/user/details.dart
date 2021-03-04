import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';

class User extends StatefulWidget {
  final  Map<String, dynamic>  user;
  final  regreso;
  User( this.user, this.regreso);
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  HttpService http = new HttpService();
  Future<String> _future;
  String _title='Nuevo';
  String _authtoken='';
  // ignore: unused_field
  String _userId='';
  String _estabId='';
  TextEditingController cntrlname= new TextEditingController();
  TextEditingController cntrllastname= new TextEditingController();
  TextEditingController cntrlusername= new TextEditingController();
  TextEditingController cntrlemail= new TextEditingController();
  TextEditingController cntrlphone= new TextEditingController();
  TextEditingController cntrlpassword= new TextEditingController();
  TextEditingController cntrlpasswordconfirmation= new TextEditingController();
  bool _enabled = true;

  Future<String> getData() async {
    if(widget.user!=null){
      cntrlname.text = widget.user['name'];
      cntrlemail.text = widget.user['email'];
      cntrlphone.text = (widget.user['phone'].length == 13)?widget.user['phone'].toString().substring(3):widget.user['phone'];
      cntrlusername.text = widget.user['user_name'];
      cntrllastname.text = widget.user['lastname'];
      _enabled = (widget.user['enabled']==1)?true:false;
      _title = 'Editar Usuario';
    }
        
      return 'Algo';
  }
  String validateEmail(String value) {
    String value = cntrlemail.text;
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Ingresa un correo valido';
    else
      return null;
  }
  String validateMobile(String value) {
     value = cntrlphone.text;
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
     value = cntrlpassword.text;
    if (value.length == 0) {
          return 'Ingresa la contraseña de confirmación';
    }
    else if (value != cntrlpasswordconfirmation.text) {
          return 'La contraseña no coincide';
    }
    return null;
  } 
  Future<String> _guardar() async {
      final data = Map<String,dynamic>.from(_formKey.currentState.value);
      String url = '';
      if(widget.user!=null){
        url = AppSettings.API_URL+'/api/users/'+widget.user['id'].toString();
        data['name']=cntrlname.text;
        data['enabled']=_enabled;
        data['lastname']=cntrllastname.text;
      }else{
        url = AppSettings.API_URL+'/api/register';
        data['name']=cntrlname.text;
        data['enabled']=_enabled;
        data['lastname']=cntrllastname.text;
        data['email']=cntrlemail.text;
        data['phone']=cntrlphone.text;
        data['user_name']=cntrlusername.text;
        data['password']=cntrlpassword.text;
        data['password_confirmation']=cntrlpasswordconfirmation.text;
        data['establishment_id']=_estabId;
        data['terms']=true;
        data['role']='user';
        data['imagen']='users/user.png';
      }
      
      Map<String, dynamic> res = await http.apiCall(context, _scaffoldKey,(widget.user!=null)?HttpServiceType.PUT: HttpServiceType.POST, url, json: jsonEncode(data), token: _authtoken);
      if (res!=null) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: AlertDialogType.SUCCESS,
              title: "Correcto", content: 'Usuario guardado correctamente.',
            );
          },
        ).then((value){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.regreso
            ),
          );
        });
      }


      return null;
  }
  @override
  void initState() {
    _authtoken = Provider.of<LoginState>(context, listen: false).getAuthToken();
    _userId = Provider.of<LoginState>(context, listen: false).getUserId();
    _estabId = Provider.of<LoginState>(context, listen: false).getEstablishment();
    _future = getData();
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return  Scaffold(
      key: _scaffoldKey,
      body: 
      FutureBuilder<String>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBarAzul(context,_title,leadingIconBack(context, AppSettings.white),null),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            children:[
                              FormBuilderSwitch(
                                  title: Text((_enabled)?'Habilitado':'Deshabilitado',
                                    style: TextStyle(
                                      color: AppSettings.deactivatedText,
                                      fontSize: 16
                                    ),
                                  ),
                                  name: "enabled",
                                  initialValue: _enabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _enabled =value;
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(),
                                    
                                  ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                validator: FormBuilderValidators.required(
                                    context,
                                    errorText:'Este campo no puede ser vacío',
                                  ),
                                name: 'name',
                                controller: cntrlname,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: 'Nombre',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48, right: 48),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.short_text),
                                  ),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                validator: FormBuilderValidators.required(
                                    context,
                                    errorText:'Este campo no puede ser vacío',
                                  ),
                                name: 'lastname',
                                controller: cntrllastname,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Apellido(s)',
                                  hintText: 'Apellido(s)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48, right: 48),
                                  prefixIcon: Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.short_text_rounded),
                                  ),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                validator: FormBuilderValidators.required(
                                    context,
                                    errorText:'Este campo no puede ser vacío',
                                  ),
                                name: 'user_name',
                                controller: cntrlusername,
                                enabled: (widget.user==null),
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Username',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48, right: 48),
                                  prefixIcon: Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.person),
                                  ),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                validator: validateEmail,
                                name: 'email',
                                controller: cntrlemail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction:  TextInputAction.next,
                                enabled: (widget.user==null),
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  hintText: 'E-mail',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.email),
                                  )
                                ),
                              ), 
                              Divider(),
                              FormBuilderPhoneField(
                                name: 'phone',
                                controller: cntrlphone,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: const InputDecoration(
                                  hintText: 'Teléfono',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.phone),
                                  )
                                ),
                                priorityListByIsoCode: ['MX'],
                                defaultSelectedCountryIsoCode: 'MX',
                                countryFilterByIsoCode: ['MX'],
                                isSearchable: false,
                                validator: validateMobile,
                                enabled: (widget.user==null),
                              ),
                              (widget.user!=null)?Container():Divider(),
                              (widget.user!=null)?Container():FormBuilderTextField(
                                name: 'password',
                                obscureText: true,
                                controller: cntrlpassword,
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
                                  prefixIcon: Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.vpn_key),

                                  )
                                ),
                              ),
                              (widget.user!=null)?Container():Divider(),
                              (widget.user!=null)?Container():FormBuilderTextField(
                                name: 'password_confirmation',
                                obscureText: true,
                                controller: cntrlpasswordconfirmation,
                                validator: validateConfirm,
                                textInputAction:  TextInputAction.next,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Confirmar Contraseña',
                                  hintText: 'Confirmar Contraseña',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Padding(
                                    padding:  const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.vpn_key),
                                  )
                                ),
                              ),
                            ]
                          )
                        )
                      ]
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
                        
                          await _guardar();
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
                          child: Icon(Icons.save)
                        ),
                        Text(' G U A R D A R ')
                      ],
                    ),
                  ),
                ]
              );
          }
        }
      )
      
    );
  }
}