import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/login_state.dart';

 enum HttpServiceType {
  POST,
  GET,
  PUT,
  DELETE,
  IMAGE
}
class HttpService {
  Response res;
  Dio dio = new Dio();  

  Future<dynamic> apiCall(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey, HttpServiceType type, String url, {String json, FormData formData, String token=''}) async {
    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    String message;
      if(token!='')
        dio.options.headers["Authorization"] = "Bearer $token";
    
    // await pr.hide();
     await pr.show();
    try {
      switch (type) {
        case HttpServiceType.POST:
          res = await dio.post(url,
            data:json,
            onSendProgress: (int sent, int total) {
              pr.update(
                message: url,
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
                message: url, 
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
                message: 'Enviando Info',
                progress: sent.toDouble(),
                maxProgress: total.toDouble()
              );
              log("$sent $total");
            },
          );
          break;
        case HttpServiceType.IMAGE:
          res = await dio.post(url, 
            data: formData,
            onSendProgress: (int sent, int total) {
              pr.update(
                progress: sent.toDouble(),
                maxProgress: total.toDouble()
              );
              log("$sent $total");
            },
          );
          break;
        case HttpServiceType.DELETE:
          res = await dio.delete(url);
          break;
    }
     await pr.hide();
      print(res.data['data']);
    if (res.data['success']) {
      return res.data['data'];
    }else{
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content:Text(res.data['message']
          ),
          backgroundColor: AppSettings.DANGER,
        )
      ).closed.then((SnackBarClosedReason reason) {
        if(res.data['error']!=null && res.data['error']=='unauthenticated'){

          Provider.of<LoginState>(context, listen: false).logout();
        }
      });
    await pr.hide();
      return null;
    }
    } on SocketException catch(e){
        print(e);
      message = "Sin conexíon a internet o al servidor 😑";
    } on HttpException catch(e){
        print(e);
      message="No se encontró el documento 😱";
    } on FormatException catch(e){
        print(e);
      message="Respuesta en mal formato 👎";
    }on DioError catch (e) { 
      if(e.response.toString().length>100)
        message = e.message.toString() + e.response.toString().substring(100,500);
      else
        message = e.message.toString() + e.response.toString();
    }on Exception {
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

}