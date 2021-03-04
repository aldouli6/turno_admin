import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/pages/establishment.dart';
import 'package:turno_admin/pages/home_screen.dart';
import 'package:turno_admin/widgets/home_drawer.dart';
import 'package:turno_admin/widgets/navigation_home.dart';
import 'package:turno_admin/pages/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


import 'classes/login_state.dart';

void main() {
  runApp(TurnoAdmin());
}

class TurnoAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //      statusBarBrightness: Brightness.dark,
    // ));
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);/
    return ChangeNotifierProvider<LoginState>(
      create: (BuildContext context) => LoginState(),
      child :MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          // TODO: uncomment the line below after codegen
          // AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', ''), // English, no country code
        ],
        title: 'TurnoAdmin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppSettings.PRIMARY,
          primarySwatch: Colors.blue,
          textTheme: AppSettings.textTheme,
          scaffoldBackgroundColor: AppSettings.LIGTH,
          hintColor: AppSettings.deactivatedText,
          
        ),
        // home: NavigationHome(),
        routes: {
          '/': (BuildContext context){
            var state = Provider.of<LoginState>(context, listen: true).isLoggedIn();
            var role = Provider.of<LoginState>(context, listen: true).getRole();
            
            if(state){
              if(role=='preadmin')
                return NavigationHome(DrawerIndex.Establish, Establishment(null));
              else
                return NavigationHome(DrawerIndex.HOME, Home());
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