import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turno_admin/classes/app_settings.dart';


  Widget leadingIconBack(BuildContext context){  
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: AppSettings.PRIMARY,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
 appBar(String _titulo, Widget _leading, Widget _actions )  {
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
                    color: AppSettings.PRIMARY,
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
  
   imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );
    print(image);
   return image;
  }
   imgFromCamera() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.camera, imageQuality: 50
    );
   return image;
  }