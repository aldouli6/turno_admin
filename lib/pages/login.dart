 import 'package:flutter/material.dart';
import 'package:turno_admin/classes/app_colors.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
    static final String path = "lib/src/pages/login/login7.dart";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
       body: ListView(
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
                             [AppColors.PRIMARY_22, AppColors.PRIMARY_ACCENT_22],
                             [AppColors.PRIMARY_44, AppColors.PRIMARY_ACCENT_44],
                             [AppColors.PRIMARY_, AppColors.PRIMARY_ACCENT]
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
               child: TextField(
                 onChanged: (String value){},
                 cursorColor: Colors.deepOrange,
                 decoration: InputDecoration(
                     hintText: "Correo",
                     prefixIcon: Material(
                       elevation: 0,
                       borderRadius: BorderRadius.all(Radius.circular(30)),
                       child: Icon(
                         Icons.email,
                         color: AppColors.PRIMARY_,
                       ),
                     ),
                     border: InputBorder.none,
                     contentPadding:
                         EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
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
               child: TextField(
                 onChanged: (String value){},
                 cursorColor: Colors.deepOrange,
                 decoration: InputDecoration(
                     hintText: "Contraseña",
                     prefixIcon: Material(
                       elevation: 0,
                       borderRadius: BorderRadius.all(Radius.circular(30)),
                       child: Icon(
                         Icons.lock,
                         color: AppColors.PRIMARY_,
                       ),
                     ),
                     border: InputBorder.none,
                     contentPadding:
                         EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
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
                     color: AppColors.PRIMARY_),
                 child: FlatButton(
                   child: Text(
                     "Login",
                     style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.w700,
                         fontSize: 18),
                   ),
                   onPressed: () {},
                 ),
               )),
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
             child: Text("OLVIDASTE TU CONTRASEÑA ?", style: TextStyle(color:AppColors.PRIMARY_,fontSize: 12 ,fontWeight: FontWeight.w700),),
           ),
            SizedBox(height: 40,), 
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                 Text("No tienes una cuenta? ", style: TextStyle(color:Colors.black,fontSize: 12 ,fontWeight: FontWeight.normal),),
                 Text("Registrate ", style: TextStyle(color:AppColors.PRIMARY_, fontWeight: FontWeight.w500,fontSize: 12, decoration: TextDecoration.underline )),

               ],
             ),
           
         ],
       ),
    //   body: ListView(
    //     children: <Widget>[
    //       Stack(
    //         children: <Widget>[
    //           ClipPath(
    //             clipper: WaveClipper2(),
    //             child: Container(
    //               child: Column(),
    //               width: double.infinity,
    //               height: 300,
    //               decoration: BoxDecoration(
    //                   gradient: LinearGradient(
    //                       colors: [AppColors.PRIMARY_22, AppColors.PRIMARY_ACCENT_22])),
    //             ),
    //           ),
    //           ClipPath(
    //             clipper: WaveClipper3(),
    //             child: Container(
    //               child: Column(),
    //               width: double.infinity,
    //               height: 300,
    //               decoration: BoxDecoration(
    //                   gradient: LinearGradient(
    //                       colors: [AppColors.PRIMARY_44, AppColors.PRIMARY_ACCENT_44])),
    //             ),
    //           ),
    //           ClipPath(
    //             clipper: WaveClipper1(),
    //             child: Container(
    //               child: Column(
    //                 children: <Widget>[
    //                   SizedBox(
    //                     height: 40,
    //                   ),
    //                   Container(
    //                     height: 150,
    //                     decoration:BoxDecoration(
    //                       image:DecorationImage(
    //                         image: AssetImage("assets/logos/logo.png"),
    //                       ),
    //                     ),
    //                   ),
    //                   // Icon(
    //                   //   Icons.fastfood,
    //                   //   color: Colors.white,
    //                   //   size: 60,
    //                   // ),
    //                   // SizedBox(
    //                   //   height: 20,
    //                   // ),
    //                   // Text(
    //                   //   "Taste Me",
    //                   //   style: TextStyle(
    //                   //       color: Colors.white,
    //                   //       fontWeight: FontWeight.w700,
    //                   //       fontSize: 30),
    //                   // ),
    //                 ],
    //               ),
    //               width: double.infinity,
    //               height: 300,
    //               decoration: BoxDecoration(
    //                   gradient: LinearGradient(
    //                     stops: [0.5, 0.9],
    //                       colors: [AppColors.PRIMARY_, AppColors.PRIMARY_ACCENT])),
    //             ),
    //           ),
    //         ],
    //       ),
    //       c
    //       SizedBox(
    //         height: 20,
    //       ),
    //       Padding(
    //         padding: EdgeInsets.symmetric(horizontal: 32),
    //         child: Material(
    //           elevation: 2.0,
    //           borderRadius: BorderRadius.all(Radius.circular(30)),
    //           child: TextField(
    //             onChanged: (String value){},
    //             cursorColor: Colors.deepOrange,
    //             decoration: InputDecoration(
    //                 hintText: "Contraseña",
    //                 prefixIcon: Material(
    //                   elevation: 0,
    //                   borderRadius: BorderRadius.all(Radius.circular(30)),
    //                   child: Icon(
    //                     Icons.lock,
    //                     color: AppColors.PRIMARY_,
    //                   ),
    //                 ),
    //                 border: InputBorder.none,
    //                 contentPadding:
    //                     EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         height: 25,
    //       ),
    //       Padding(
    //           padding: EdgeInsets.symmetric(horizontal: 32),
    //           child: Container(
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.all(Radius.circular(100)),
    //                 color: AppColors.PRIMARY_),
    //             child: FlatButton(
    //               child: Text(
    //                 "Login",
    //                 style: TextStyle(
    //                     color: Colors.white,
    //                     fontWeight: FontWeight.w700,
    //                     fontSize: 18),
    //               ),
    //               onPressed: () {},
    //             ),
    //           )),
    //           SizedBox(height: 20,),
    //       Center(
    //         child: Text("OLVIDASTE TU CONTRASEÑA ?", style: TextStyle(color:AppColors.PRIMARY_,fontSize: 12 ,fontWeight: FontWeight.w700),),
    //       ),
    //       SizedBox(height: 40,),
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           Text("No tienes una cuenta? ", style: TextStyle(color:Colors.black,fontSize: 12 ,fontWeight: FontWeight.normal),),
    //           Text("Registrate ", style: TextStyle(color:AppColors.PRIMARY_, fontWeight: FontWeight.w500,fontSize: 12, decoration: TextDecoration.underline )),

    //         ],
    //       )
    //     ],
    //   ),
    );
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
