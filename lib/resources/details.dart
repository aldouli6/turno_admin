import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';

class Resource extends StatefulWidget {
  final  Map<String, dynamic>  resource;
  final  regreso;
  Resource( this.resource, this.regreso);
  @override
  _ResourceState createState() => _ResourceState();
}

class _ResourceState extends State<Resource> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  HttpService http = new HttpService();
  Future<bool> _future;
  String _title='Nuevo';
  String _authtoken='';
  // ignore: unused_field
  String _userId='';
  String _estabId='';
  int _stepping;
  int _order_alpha=1;
  TextEditingController cntrlname= new TextEditingController();
  List _mapSesiones = List();
  bool _enabled = true;
  bool _selectable = true;
  final format = DateFormat("dd MM yyyy");
  final timeformat = DateFormat("HH:mm");
  // a simple usage

  List<S2Choice<int>> _sesiones = [];
  List<int> _sesionesSeleccionadas=[];
  Future<bool> getData() async {
    String url =  AppSettings.API_URL+'/api/sessions?enabled=1?establishment_id='+_estabId;
    _mapSesiones = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, url, token:_authtoken);
    for (var item in _mapSesiones) {
      _sesiones.add(S2Choice<int>(value:item['id'],title: item['name']));
    }
    if(widget.resource!=null){
      cntrlname.text = widget.resource['name'];
      _enabled = (widget.resource['enabled'])?true:false;
      _selectable = (widget.resource['selectable'])?true:false;
      _order_alpha = (widget.resource['order_alpha'])?1:0;
      for (int item in widget.resource['sesiones']) {
        _sesionesSeleccionadas.add(item);
      }
      _title = 'Editar Sesión';
    }else{
    }
    return (_mapSesiones.length>0);
  }
  Future<String> _guardar() async {
      final data = Map<String,dynamic>.from(_formKey.currentState.value);
      String url =(widget.resource!=null)?AppSettings.API_URL+'/api/resources/'+widget.resource['id'].toString():AppSettings.API_URL+'/api/resources';
      data['name']=cntrlname.text;
      data['enabled']=_enabled;
      data['selectable']=_selectable;
      data['order_alpha']=_order_alpha;
      data['establishment_id']=_estabId;
      data['seleccionados'] = _sesionesSeleccionadas;
      
      print(jsonEncode(data));
      Map<String, dynamic> res = await http.apiCall(context, _scaffoldKey,(widget.resource!=null)?HttpServiceType.PUT: HttpServiceType.POST, url, json: jsonEncode(data), token: _authtoken);
      if (res!=null) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: AlertDialogType.SUCCESS,
              title: "Correcto", content: 'Sesión guardada correctamente.',
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
      FutureBuilder<bool>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Column(
              children: [
                appBarAzul(context,_title,leadingIconBack(context, AppSettings.white),null),
                Expanded(child: Center(child: Text('nada'))),
              ],
            );
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
                                  title: Text((_selectable)?'Habilitado':'Deshabilitado',
                                    style: TextStyle(
                                      color: AppSettings.deactivatedText,
                                      fontSize: 18
                                    ),
                                  ),
                                  name: "enabled",
                                  initialValue: _selectable,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectable =value;
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(),
                                    
                                  ),
                              ),
                              Divider(),
                              FormBuilderSwitch(
                                  title: Text((_enabled)?'Seleccionable':'No Seleccionable',
                                    style: TextStyle(
                                      color: AppSettings.deactivatedText,
                                      fontSize: 18
                                    ),
                                  ),
                                  name: "selectable",
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
                                    suffixIcon: iconTooltip('name', Icons.help, 'El cliente puede elegir este recurso.'),
                                      
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
                              FormBuilderDropdown(
                                name: 'order_alpha',
                                initialValue: _order_alpha,
                                decoration: InputDecoration(
                                  labelText: 'Orden',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.sort_by_alpha),
                                  ),
                                ), 
                                allowClear: false,
                                onChanged: (value) {
                                  setState(() {
                                    _order_alpha = value;
                                  });
                                },
                                hint: Text('Selecciona una opción'),
                                items: {1:'Ascendente (A - Z)',0:'Descendente (Z - A)'}
                                    .map((k,v){
                                      return MapEntry(
                                          k,
                                          DropdownMenuItem(
                                            value: k,
                                            child: Text(v),
                                          ));
                                    })
                                    .values
                                    .toList(),
                              ),
                              Divider(),
                              SmartSelect<int>.multiple(
                                title: 'Asigna sesiones al recurso',
                                value: _sesionesSeleccionadas,
                                onChange: (selected) => setState(() => _sesionesSeleccionadas = selected.value),
                                choiceItems: _sesiones,
                                choiceType: S2ChoiceType.chips,
                                modalType: S2ModalType.bottomSheet,
                                
                                tileBuilder: (context, state) {
                                  return Container(
                                    padding: const EdgeInsets.only(left:5),
                                    child: S2Tile.fromState(
                                      state,
                                      hideValue: true,
                                      enabled:(_mapSesiones.length>0),
                                      title:  Text('Sesiones', 
                                        style: TextStyle(
                                          color: AppSettings.deactivatedText,
                                          fontSize: 18
                                        ),
                                      ),
                                      leading: const Icon(Icons.add_circle_outline),
                                      trailing: null,
                                      body: S2TileChips(
                                        chipLength: state.valueObject.length,
                                        chipLabelBuilder: (context, i) {
                                          return Text(state.valueTitle[i]);
                                        },
                                        chipOnDelete: (i) {
                                          setState(() {
                                            _sesionesSeleccionadas.remove(state.valueObject[i].value);
                                          });
                                        },
                                        chipColor: AppSettings.PRIMARY,
                                        // chipRaised: true,
                                      ),
                                    ),
                                  );
                                },
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