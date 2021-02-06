 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_colors.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/login_state.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
    static final String path = "lib/src/pages/login/login7.dart";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();
  TextEditingController controllerResetpass = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final focus = FocusNode(); 

void _loguear(String email, String pass) async {
    var respuesta = await Provider.of<LoginState>(context, listen: false).login(email, pass);
    if(respuesta!='1'){
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content:Text(respuesta.toString()
          ),
          backgroundColor: AppSettings.DANGER,
        )
      );
    }else{
      // var mymap = {"notification": {"title": "Aviso", "body": "Se ha iniciado correctamente sesión"}, "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK"}};
      // PushNotificationsManager().showNotification(mymap );
    }
  }
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Ingresa un correo válido';
    else
      return null;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 250,
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: WaveWidget(
                      config: CustomConfig(
                        gradients: [
                          [Colors.white, Colors.white54],
                          [AppSettings.PRIMARY_22, AppSettings.PRIMARY_ACCENT_22],
                          [AppSettings.PRIMARY_44, AppSettings.PRIMARY_ACCENT_44],
                          [AppSettings.PRIMARY, AppSettings.PRIMARY_ACCENT]
                        ],
                        durations: [35000, 19440, 10800, 6000],
                        heightPercentages: [0, 0.01, 0.04, 0.08],
                        blur: MaskFilter.blur(BlurStyle.solid, 10),
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                      waveAmplitude: 0,
                      size: Size(
                        double.infinity,
                        double.infinity,
                      ),
                    ),
                  ),
                 ),
                 Column(
                   children: [
                     SizedBox(
                       height: 25,
                     ),
                     Container(
                      height: 150,
                      decoration:BoxDecoration(
                        image:DecorationImage(
                          image: AssetImage("assets/logos/logo.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: TextFormField(
                  controller: controllerEmail,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  onFieldSubmitted: (v){
                    FocusScope.of(context).requestFocus(focus);
                  },
                  autofocus: false,
                  onChanged: (String value){},
                  cursorColor: AppSettings.PRIMARY_ACCENT,
                  decoration: InputDecoration(
                    hintText: "Correo",
                    prefixIcon: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Icon(
                        Icons.email,
                        color: AppSettings.PRIMARY,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding:EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: TextFormField(
                  controller: controllerPass,
                  obscureText: true,
                  focusNode: focus,
                  cursorColor: AppSettings.PRIMARY_ACCENT,
                  decoration: InputDecoration(
                    hintText: "Contraseña",
                    prefixIcon: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Icon(
                        Icons.lock,
                        color: AppSettings.PRIMARY,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding:EdgeInsets.symmetric(horizontal: 25, vertical: 13)
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  color: AppSettings.PRIMARY
                ),
                child: FlatButton(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _loguear(controllerEmail.text, controllerPass.text);
                    }
                  },
                ),
              )
            ),
            SizedBox(height: 20,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text("o conectate con: "),
                  SizedBox(
                     height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        color: Colors.indigo,
                        icon: Icon(
                          FontAwesomeIcons.facebook,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Facebook",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {},
                       ),
                       RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        color: Colors.red,
                        icon: Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Google",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {},
                       ),
                     ],
                   ),
                 ],
               ),
             ),
            SizedBox(height: 40,),
            Center(
              child: Text("OLVIDASTE TU CONTRASEÑA ?", style: TextStyle(color:AppSettings.PRIMARY,fontSize: 12 ,fontWeight: FontWeight.w700),),
            ),
            SizedBox(height: 40,), 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("No tienes una cuenta? ", style: TextStyle(color:Colors.black,fontSize: 12 ,fontWeight: FontWeight.normal),),
                Text("Registrate ", style: TextStyle(color:AppSettings.PRIMARY, fontWeight: FontWeight.w500,fontSize: 12, decoration: TextDecoration.underline )),
              ],
            ),
           ],
         ),
       ),
    );
  }
}

