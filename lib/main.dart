import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/pages/home.dart';
import 'package:turno_admin/pages/login.dart';

import 'classes/login_state.dart';

void main() {
  runApp(TurnoAdmin());
}

class TurnoAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //      statusBarBrightness: Brightness.light,
    // ));
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return ChangeNotifierProvider<LoginState>(
      create: (BuildContext context) => LoginState(),
      child :MaterialApp(
        title: 'TurnoAdmin',
      
        routes: {
          '/': (BuildContext context){
            var state = Provider.of<LoginState>(context, listen: true).isLoggedIn();
            
            if(state){
              return Home();
            }else{
              return Login();
              // /return NetworkSensitive();
            }
          },
        },
      ),
    );
    // return MaterialApp(
    //   title: 'ScoreFan',
    //   home: Login(),
    // );
  }
}