import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/classes/login_state.dart';

 enum HttpServiceType {
  POST,
  GET,
  PUT,
  IMAGE
}
class HttpService {
  Response res;
  Dio dio = new Dio();  

  Future<Map<String, dynamic>> apiCall(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey, HttpServiceType type, String url, {String json, FormData formData, String token=''}) async {
    ProgressDialog pr = ProgressDialog(context);
    pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: false, showLogs: false);
    String message;
    String dioerror="";
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
        ).catchError((error) {
          dioerror=error.response.toString();
        });
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
    }
    await pr.hide();
    print(res);
    
    if (res.data['success']) {
      return res.data;
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
      message += e.message.toString();
    }on Exception catch(e){
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