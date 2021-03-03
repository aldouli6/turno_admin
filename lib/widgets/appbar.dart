import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turno_admin/classes/app_settings.dart';


  Widget leadingIconBack(BuildContext context, Color color){  
    return IconButton(
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal:20),
        child: const Icon(Icons.arrow_back_ios),
      ),
      color: color,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
toolBar( context , String _titulo, Widget _leading, Widget _actions)  {
  return Stack(
    children: [
      Container(
      height: AppBar().preferredSize.height +(MediaQuery.of(context).padding.top*3),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppSettings.PRIMARY,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30))),
      
      ),
      Padding( 
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child:     appBar(_titulo,null, _leading, AppSettings.white),
      ),
       Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: AppBar().preferredSize.height +(MediaQuery.of(context).padding.top*2),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: TextField(
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: "Search ",
                      hintStyle: TextStyle(
                          color: Colors.black38, fontSize: 16),
                      prefixIcon: Material(
                        elevation: 0.0,
                        borderRadius:
                            BorderRadius.all(Radius.circular(30)),
                        child: Icon(Icons.search),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ),
            ),
          ],
        ),
      )
    ],
  );
                     
}
appBar(String _titulo, Widget _leading, Widget _actions, Color color )  {
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
                    color: color,
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
appBarAzul(context, String _titulo, Widget _leading, Widget _actions )  {
  return Material(
      elevation: 5,
      child: Container(
        color: AppSettings.PRIMARY,
        height: AppBar().preferredSize.height+ MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                      color: AppSettings.white,
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