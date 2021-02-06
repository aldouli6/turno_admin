import 'package:flutter/material.dart';
import 'package:turno_admin/classes/app_settings.dart';

// Widget elAppbar(GlobalKey<ScaffoldState> _globalKey, double _width, Widget _leadingIcon, Widget _actions ){
//   return AppBar(
//               backgroundColor:Variables.TRANSPARENTE,
//               leading: _leadingIcon,
//               elevation: 0,
//               actions: <Widget>[
//                 _actions,
//                   ]
//           );
// }
Widget appBar(String _titulo, Widget _leading, Widget _actions ) {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          (_leading!=null)?_leading:
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _titulo,
                  style: TextStyle(
                    fontSize: 22,
                    color: AppSettings.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Container(
              width: AppBar().preferredSize.height ,
              height: AppBar().preferredSize.height - 8,
              color: Colors.white,
              child: Material(
                color: Colors.transparent,
                child: _actions,
              ),
            ),
          ),
        ],
      ),
    );
  }