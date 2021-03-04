import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:turno_admin/widgets/appbar.dart';
import 'package:turno_admin/widgets/dialogs.dart';

class Session extends StatefulWidget {
  final  Map<String, dynamic>  session;
  final  regreso;
  Session( this.session, this.regreso);
  @override
  _SessionState createState() => _SessionState();
}

class _SessionState extends State<Session> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  HttpService http = new HttpService();
  Future<String> _future;
  String _title='Nuevo';
  String _authtoken='';
  // ignore: unused_field
  String _userId='';
  String _estabId='';
  int _stepping;
  TextEditingController cntrlname= new TextEditingController();
  TextEditingController cntrlduration= new TextEditingController();
  TextEditingController cntrlcost= new TextEditingController();
  TextEditingController cntrlmax_days_schedule= new TextEditingController();
  TextEditingController cntrlmax_hours_schedule= new TextEditingController();
  TextEditingController cntrlmax_minutes_schedule= new TextEditingController();
  TextEditingController cntrlmin_days_schedule= new TextEditingController();
  TextEditingController cntrlmin_hours_schedule= new TextEditingController();
  TextEditingController cntrlmin_minutes_schedule= new TextEditingController();
  TextEditingController cntrlstandby_time= new TextEditingController();
  TextEditingController cntrltime_btwn_session= new TextEditingController();
  TextEditingController cntrlend_date= new TextEditingController();
  bool _enabled = true;
  final format = DateFormat("dd MM yyyy");
  final timeformat = DateFormat("HH:mm");

  Future<String> getData() async {

    if(widget.session!=null){
      cntrlname.text = widget.session['name'];
      _enabled = (widget.session['enabled'])?true:false;
      _title = 'Editar Seesión';
      cntrlmax_days_schedule.text= widget.session['max_days_schedule'].toString();
      cntrlmax_hours_schedule.text=widget.session['max_hours_schedule'].toString();
      cntrlmax_minutes_schedule.text =widget.session['max_minutes_schedule'].toString();
      cntrlmin_days_schedule.text=widget.session['min_days_schedule'].toString();
      cntrlmin_hours_schedule.text=widget.session['min_hours_schedule'].toString();
      cntrlmin_minutes_schedule.text =widget.session['min_minutes_schedule'].toString();
      cntrlduration.text=widget.session['duration'].toString();
      cntrlstandby_time.text=widget.session['standby_time'].toString();
      cntrltime_btwn_session.text=widget.session['time_btwn_session'].toString();
      cntrlcost.text=widget.session['cost'].toString();
    }else{
      cntrlmax_days_schedule.text=0.toString();
      cntrlmax_hours_schedule.text=0.toString();
      cntrlmax_minutes_schedule.text =0.toString();
      cntrlmin_days_schedule.text=0.toString();
      cntrlmin_hours_schedule.text=0.toString();
      cntrlmin_minutes_schedule.text =0.toString();
      cntrlduration.text='00:00';
      cntrlstandby_time.text='00:00';
      cntrltime_btwn_session.text='00:00';
    }
    Map<String,dynamic> estab = await http.apiCall(context, _scaffoldKey, HttpServiceType.GET, AppSettings.API_URL+'/api/establishments/'+_estabId, token: _authtoken);
    setState(() {
      _stepping = estab['stepping'];
    });
    return 'Algo';
  }
  String validateStep( value) {                                        
      int mins = value.minute;
      if (mins%_stepping!=0) {
        return 'Los miinutos tienen que ser divisible entre '+ _stepping.toString();
      }
      return null;
  } 
  Future<String> _guardar() async {
      final data = Map<String,dynamic>.from(_formKey.currentState.value);
      String url =(widget.session!=null)?AppSettings.API_URL+'/api/sessions/'+widget.session['id'].toString():AppSettings.API_URL+'/api/sessions';
      data['name']=cntrlname.text;
      data['enabled']=_enabled;
      data['establishment_id']=_estabId;
      data['cost']=cntrlcost.text;
      data['duration']=cntrlduration.text;
      data['standby_time']=cntrlstandby_time.text;
      data['time_btwn_session']=cntrltime_btwn_session.text;
      data['end_date']=cntrlend_date.text;
      data['max_days_schedule']=cntrlmax_days_schedule.text;
      data['max_hours_schedule']=cntrlmax_hours_schedule.text;
      data['max_minutes_schedule']=cntrlmax_minutes_schedule.text;
      data['min_days_schedule']=cntrlmin_days_schedule.text;
      data['min_hours_schedule']=cntrlmin_hours_schedule.text;
      data['min_minutes_schedule']=cntrlmin_minutes_schedule.text;
      
      print(jsonEncode(data));
      Map<String, dynamic> res = await http.apiCall(context, _scaffoldKey,(widget.session!=null)?HttpServiceType.PUT: HttpServiceType.POST, url, json: jsonEncode(data), token: _authtoken);
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
                                name: 'cost',
                                controller: cntrlcost,
                                textInputAction:  TextInputAction.next,
                                keyboardType: TextInputType.number,
                                onEditingComplete: () => node.nextFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Costo',
                                  hintText: 'Costo',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48, right: 48),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.attach_money),
                                  ),
                                ),
                              ), 
                              Divider(),
                              FormBuilderDateTimePicker(
                                // inputType: InputType.date,
                                name: 'end_date',
                                controller: cntrlend_date,
                                textInputAction:  TextInputAction.next,
                                format: format,
                                decoration: InputDecoration(
                                  labelText: 'Fecha límite ',
                                  hintText: 'Fecha límite ',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48, right: 48),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:25),
                                    child: Icon(Icons.date_range),
                                  ),
                                  suffixIcon: iconTooltip('name', Icons.help, 'Solo colocar fecha límite si está sesión tendrá termino en determinado momento.'),
                                ),
                              ), 
                              Divider(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Datos de la sesión'),
                                )
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 1, color: AppSettings.light_grey),
                                ),
                                child:Column(
                                  children: [
                                    FormBuilderDateTimePicker(
                                      validator: (value) =>validateStep(value),
                                      name: 'duration',
                                      resetIcon: null,
                                      format: timeformat,
                                      initialValue:DateTime.parse((widget.session==null)?"2000-01-01 00:00":"2000-01-01 "+widget.session['duration']),
                                      inputType: InputType.time,
                                      controller: cntrlduration,
                                      textInputAction:  TextInputAction.next,
                                      onEditingComplete: () => node.nextFocus(),
                                      decoration: InputDecoration(
                                        labelText: 'Duración de sesión',
                                        hintText: 'Duración de sesión',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48, right: 48),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:25),
                                          child: Icon(Icons.watch_later_outlined),
                                        ),
                                        suffixIcon: iconTooltip('name', Icons.help, 'Es el tiempo que lleva en realizar el servicio.'),
                                      ),
                                    ), 
                                    Divider(),
                                    FormBuilderDateTimePicker(
                                      validator: (value)=>validateStep(value),
                                      name: 'standby_time',
                                      resetIcon: null,
                                      inputType: InputType.time,
                                      format: timeformat,
                                      controller: cntrlstandby_time,
                                      initialValue:DateTime.parse((widget.session==null)?"2000-01-01 00:00":"2000-01-01 "+widget.session['standby_time']),
                                      textInputAction:  TextInputAction.next,
                                      onEditingComplete: () => node.nextFocus(),
                                      decoration: InputDecoration(
                                        labelText: 'Tiempo de espera',
                                        hintText: 'Tiempo de espera',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48, right: 48),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:25),
                                          child: Icon(Icons.watch_later_outlined),
                                        ),
                                        suffixIcon: iconTooltip('name', Icons.help, 'Es el tiempo de tolerancia que tiene el clientee para llegar'),
                                      ),
                                    ), 
                                    Divider(),
                                    FormBuilderDateTimePicker(
                                      validator: (value)=>validateStep(value),
                                      name: 'time_btwn_session',
                                      resetIcon: null,
                                      inputType: InputType.time,
                                      format: timeformat,
                                      controller: cntrltime_btwn_session,
                                      initialValue:DateTime.parse((widget.session==null)?"2000-01-01 00:00":"2000-01-01 "+widget.session['time_btwn_session']),
                                      textInputAction:  TextInputAction.next,
                                      onEditingComplete: () => node.nextFocus(),
                                      decoration: InputDecoration(
                                        labelText: 'Tiempo entre sesión',
                                        hintText: 'Tiempo entre sesión',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(left:48, right: 48),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:25),
                                          child: Icon(Icons.watch_later_outlined),
                                        ),
                                        suffixIcon: iconTooltip('name', Icons.help, 'Es el tiempo que se necesita para preparar el ambiente de trabajo.'),
                                      ),
                                    ), 
                                  ],
                                )
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8,8,13,8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tiempo máximo para agendar'),
                                      iconTooltip('name', Icons.help, 'Este es el tiempo máximo hacía el futuro.'),
                                    ],
                                  ),
                                )
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 1, color: AppSettings.light_grey),
                                ),
                                child:Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: (MediaQuery.of(context).size.width-50)/5,
                                        child: FormBuilderTextField(
                                          validator: FormBuilderValidators.required(
                                              context,
                                              errorText:'Este campo no puede ser vacío',
                                            ),
                                          name: 'max_days_schedule',
                                          controller: cntrlmax_days_schedule,
                                          keyboardType: TextInputType.number,
                                          textInputAction:  TextInputAction.next,
                                          
                                          onEditingComplete: () => node.nextFocus(),
                                          decoration: InputDecoration(
                                            labelText: 'Días',
                                            hintText: 'Días',
                                            border: InputBorder.none,
                                            
                                          ),
                                        ),
                                      ), 
                                      Container(
                                        width: (MediaQuery.of(context).size.width-50)/5,
                                        child: FormBuilderTextField(
                                          validator: FormBuilderValidators.required(
                                              context,
                                              errorText:'Este campo no puede ser vacío',
                                            ),
                                          name: 'max_hours_schedule',
                                          controller: cntrlmax_hours_schedule,
                                          keyboardType: TextInputType.number,
                                          textInputAction:  TextInputAction.next,
                                          onEditingComplete: () => node.nextFocus(),
                                          decoration: InputDecoration(
                                            labelText: 'Horas',
                                            hintText: 'Horas',
                                            border: InputBorder.none,
                                            
                                          ),
                                        ),
                                      ),  
                                      Container(
                                        width: (MediaQuery.of(context).size.width-50)/5,

                                        child: FormBuilderTextField(
                                          validator: FormBuilderValidators.required(
                                              context,
                                              errorText:'Este campo no puede ser vacío',
                                            ),
                                          name: 'max_minutes_schedule',
                                          controller: cntrlmax_minutes_schedule,
                                          keyboardType: TextInputType.number,
                                          textInputAction:  TextInputAction.next,
                                          onEditingComplete: () => node.nextFocus(),
                                          decoration: InputDecoration(
                                            labelText: 'Minutos',
                                            hintText: 'Minutos',
                                            border: InputBorder.none,
                                            
                                          ),
                                        ),
                                      ),   
                                    ],
                                  ),
                                )
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8,8,13,8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Tiempo límite antes de agendar'),
                                      iconTooltip('name', Icons.help, 'Este es el tiempo limite previo al día de hoy en el que está sesión estará disponible.'),
                                    ],
                                  ),
                                )
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 1, color: AppSettings.light_grey),
                                ),
                                child:Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: (MediaQuery.of(context).size.width-50)/5,
                                        child: FormBuilderTextField(
                                          validator: FormBuilderValidators.required(
                                              context,
                                              errorText:'Este campo no puede ser vacío',
                                            ),
                                          name: 'min_days_schedule',
                                          controller: cntrlmin_days_schedule,
                                          keyboardType: TextInputType.number,
                                          textInputAction:  TextInputAction.next,
                                          onEditingComplete: () => node.nextFocus(),
                                          decoration: InputDecoration(
                                            labelText: 'Días',
                                            hintText: 'Días',
                                            border: InputBorder.none,
                                            
                                          ),
                                        ),
                                      ), 
                                      Container(
                                        width: (MediaQuery.of(context).size.width-50)/5,
                                        child: FormBuilderTextField(
                                          validator: FormBuilderValidators.required(
                                              context,
                                              errorText:'Este campo no puede ser vacío',
                                            ),
                                          name: 'min_hours_schedule',
                                          controller: cntrlmin_hours_schedule,
                                          keyboardType: TextInputType.number,
                                          textInputAction:  TextInputAction.next,
                                          onEditingComplete: () => node.nextFocus(),
                                          decoration: InputDecoration(
                                            labelText: 'Horas',
                                            hintText: 'Horas',
                                            border: InputBorder.none,
                                            
                                          ),
                                        ),
                                      ),  
                                      Container(
                                        width: (MediaQuery.of(context).size.width-50)/5,
                                        child: FormBuilderTextField(
                                          validator: FormBuilderValidators.required(
                                              context,
                                              errorText:'Este campo no puede ser vacío',
                                            ),
                                          name: 'min_minutes_schedule',
                                          controller: cntrlmin_minutes_schedule,
                                          keyboardType: TextInputType.number,
                                          textInputAction:  TextInputAction.next,
                                          onEditingComplete: () => node.nextFocus(),
                                          decoration: InputDecoration(
                                            labelText: 'Minutos',
                                            hintText: 'Minutos',
                                            border: InputBorder.none,
                                            
                                          ),
                                        ),
                                      ),   
                                    ],
                                  ),
                                )
                              )
                            
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