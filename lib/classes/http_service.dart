import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http_parser/http_parser.dart';
import 'package:turno_admin/classes/app_settings.dart';

 enum HttpServiceType {
  POST,
  GET,
  PUT,
}
class HttpService {
  Response res;
  Dio dio = new Dio();  

  Future<Map<String, dynamic>> apiCall(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey, HttpServiceType type, String url, {String json, String token=''}) async {
    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: false, showLogs: false);
    String message;
    dio.options.headers['Content-Type'] = 'application/json';
      if(token!='')
        dio.options.headers["Authorization"] = "Bearer $token";
    await pr.show();
    try {
      switch (type) {
      case HttpServiceType.POST:
        res = await dio.post(url,
          data:json,
          onSendProgress: (int sent, int total) {
            pr.update(
              progress: sent.toDouble(),
              maxProgress: total.toDouble()
            );
            log("$sent $total");
          },
        );
        break;
        case HttpServiceType.GET:
          res = await dio.get(url,
            onReceiveProgress: (int sent, int total) {
              pr.update(
                progress: sent.toDouble(),
                maxProgress: total.toDouble()
              );
              log("$sent $total");
            },
          );
          break;
        case HttpServiceType.PUT:
          res = await dio.put(url,
            data:json,
            onSendProgress: (int sent, int total) {
              pr.update(
                progress: sent.toDouble(),
                maxProgress: total.toDouble()
              );
              log("$sent $total");
            },
          );
          break;
    }
    await pr.hide();
    return res.data;
    } on SocketException catch(e){
        print(e);
      message = "Sin conexíon a internet o al servidor 😑";
    } on HttpException catch(e){
        print(e);
      message="No se encontró el documento 😱";
    } on FormatException catch(e){
        print(e);
      message="Respuesta en mal formato 👎";
    } on Exception catch(e){
        print(e);
      message="Otro tipo de Excepción 👎";
    }
    await pr.hide();
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content:Text(message.toString()
        ),
        backgroundColor: AppSettings.DANGER,
      )
    );
    return null;
  }

  Future<Map<String, dynamic>> post(BuildContext context, String url, String json, [String token=''] ) async {
     ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    
    String result;
    try {
      dio.options.headers['Content-Type'] = 'application/json';
      if(token!='')
        dio.options.headers["Authorization"] = "Bearer $token";
      await pr.show();
   
      res = await dio.post(url,
      data:json,
      onSendProgress: (int sent, int total) {
        pr.update(
          progress: sent.toDouble(),
          maxProgress: total.toDouble()
        );
        log("$sent $total");
      },
      );
      await pr.hide();
      
      return res.data;
    } on SocketException catch(e){
        print(e);
      result = "Sin conexíon a internet o al servidor 😑";
    } on HttpException catch(e){
        print(e);
      result="No se encontró el documento 😱";
    } on FormatException catch(e){
        print(e);
      result="Respuesta en mal formato 👎";
    } on Exception catch(e){
        print(e);
      result="Otro tipo de Excepción 👎";
    }
    return jsonDecode('{"ex":"'+result+'"}');
  }
  Future<Map<String, dynamic>> put(BuildContext context,String url, String json, [String token=''] ) async {

    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    String result;

    try {
      dio.options.headers['Content-Type'] = 'application/json';
      if(token!='')
        dio.options.headers["Authorization"] = "Bearer $token";
      await pr.show();
      res = await dio.put(url,
      data:json,
      onSendProgress: (int sent, int total) {
        pr.update(
          progress: sent.toDouble(),
          maxProgress: total.toDouble()
        );
        log("$sent $total");
      },
      );
      await pr.hide();
      return res.data;
    } on SocketException catch(e){
        print(e);
      result = "Sin conexíon a internet o al servidor 😑";
    } on HttpException catch(e){
        print(e);
      result="No se encontró el documento 😱";
    } on FormatException catch(e){
        print(e);
      result="Respuesta en mal formato 👎";
    } on Exception catch(e){
        print(e);
      result="Otro tipo de Excepción 👎";
    }
    await pr.hide();
    return jsonDecode('{"ex":"'+result+'"}');
  }
  Future<Map<String, dynamic>> get(BuildContext context, String url, [String token='']) async {
    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    String result;
    try {
      dio.options.headers['Content-Type'] = 'application/json';
      if(token!='')
        dio.options.headers["Authorization"] = "Bearer $token";
      await pr.show();
      res = await dio.get(url,
        onReceiveProgress: (int sent, int total) {
          pr.update(
            progress: sent.toDouble(),
            maxProgress: total.toDouble()
          );
          log("$sent $total");
        },
      );
      await pr.hide();
      return res.data;
      } on SocketException catch(e){
        print(e);
      result = "Sin conexíon a internet o al servidor 😑";
    } on HttpException  catch(e){
        print(e);
      result="No se encontró el documento 😱";
    } on FormatException  catch(e){
        print(e);
      print(url);
      result="Respuesta en mal formato 👎";
    } on Exception  catch(e){
        print(e);
      result="Otro tipo de Excepción 👎";
    }
    await pr.hide();
    return jsonDecode('{"ex":"'+result+'"}');
  }
 
 Future<dynamic> uploadImage(  {File file, String token, String id})async{ 

    
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(file.path, filename:'some-file-name.png',contentType: MediaType('image','png')),
        "name":"prospect_"+id,
    });
      var response = await dio.post(AppSettings.API_URL+"/api/subirimagedata", 
    
    data: formData,
    onSendProgress: (int sent, int total) {
          log("$sent $total");
        },
    );
      print(response);
    
    return response;
  }
  Future<dynamic> uploadImage2( { BuildContext context, String url, File file, String name,String token,})async{ 

  Dio dio2 = new Dio();  
    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    String result;
    try {
      FormData formData = FormData.fromMap({
          "image": await MultipartFile.fromFile(file.path, filename:'some-file-name.png',contentType: MediaType('image','png')),
          "name":name,
      });
      // dio2.options.headers['Content-Type'] = 'multipart/form-data';
      // if(token!='')
      //   dio2.options.headers["Authorization"] = "Bearer $token";

      await pr.show();
      var response = await dio2.post(url, 
        data: formData,
        onSendProgress: (int sent, int total) {
          pr.update(
            progress: sent.toDouble(),
            maxProgress: total.toDouble()
          );
          log("$sent $total");
        },
      );
      await pr.hide();
    
      return response;
    } on SocketException catch(e){
        print(e);
      result = "Sin conexíon a internet o al servidor 😑";
    } on HttpException  catch(e){
        print(e);
      result="No se encontró el documento 😱";
    } on FormatException  catch(e){
        print(e);
      print(url);
      result="Respuesta en mal formato 👎";
    } on Exception  catch(e){
        print(e);
      result="Otro tipo de Excepción 👎";
    }
    await pr.hide();
    return jsonDecode('{"ex":"'+result+'"}');
  }
}