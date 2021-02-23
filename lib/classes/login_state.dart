
import 'dart:async';
// import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';
import 'package:turno_admin/classes/http_service.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gardeapp/push_notifications.dart';

class LoginState with ChangeNotifier{
  
  bool _loggedIn = false;
  bool _loading = true;
  String _role='';
  String _userId='';
  String _establishment='';
  String _authtoken='';
  bool isLoggedIn() => _loggedIn;
  bool isLoading() => _loading;
  String getUserId() => _userId;
  String getAuthToken() => _authtoken;
  String getRole() => _role;
  String getEstablishment() => _establishment;
  SharedPreferences _prefs;
  HttpService http = new HttpService();

  LoginState(){
    loginState();
  }
  Future<String> login(BuildContext context,GlobalKey<ScaffoldState> _scaffoldKey,String email, String pass) async {
    String salida='';
    _loading = true;
    notifyListeners();
    final data =  await _handleLogin(context, _scaffoldKey, email, pass);
    _loading = false;
    print(data);
    notifyListeners(); 
      if (data!=null) {
        Map<String, dynamic> obj = data;
         print(obj);
        if(obj['success']){
          _loggedIn = true;
          _role = obj['user']['roles'][0]['name'];
          _userId = obj['user']['id'].toString();
          _establishment = (obj['user']['establishment']!=null)?obj['user']['establishment']:'0';
          _authtoken = obj['access_token'];
          _prefs.setBool('isLoggedIn', true);
          _prefs.setString('role', _role);
          _prefs.setString('userId', _userId);
          _prefs.setString('establishment', _establishment);
          _prefs.setString('authtoken', _authtoken);
          _loggedIn = true;
          print(_prefs);
          notifyListeners();
          salida= '1';
        }else{
          salida= obj['message'];
        }
      }else{
        _loggedIn = false;
        notifyListeners();
      }
   
    return salida;
  }

  void logout(){
    _prefs.clear();
    _loggedIn = false;
    _loading = false;
    notifyListeners();
  }
  void changeRole(String role){
    _role = role;
    _prefs.setString('role', _role);
    notifyListeners();
  }
  void loginState() async {
    // SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    if(_prefs.containsKey('isLoggedIn') ){
      _role=_prefs.getString('role');
      _userId=_prefs.getString('userId');
      _establishment=_prefs.getString('establishment');
      _authtoken=_prefs.getString('authtoken');
      _loggedIn = true;
      _loading = false;
          print(_prefs);
      notifyListeners();
    }else{
     logout();
    }
  } 
  Future<Map<String, dynamic>> _handleLogin(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey,String email, String _pass) async {
    String url = AppSettings.API_URL+'/api/login';
    String json = '{"email": "'+email+'", "password": "'+_pass.toString()+'"}';
    Map<String, dynamic> data = await http.apiCall(context, _scaffoldKey, HttpServiceType.POST, url, json: json);
    // Map<String, dynamic> data = await http.post(context, url, json);
    return data;

  }
}