import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/pages/prospect/details.dart';
import 'package:turno_admin/widgets/appbar.dart';

class Propspects extends StatefulWidget {
  @override
  _PropspectsState createState() => _PropspectsState();
}

Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }
Widget actionButtons(BuildContext context){
  return InkWell(
    borderRadius:
        BorderRadius.circular(AppBar().preferredSize.height),
    child: Icon(
       FontAwesomeIcons.plusCircle,
      color: AppSettings.PRIMARY,
    ),
    onTap: () {
       Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new Prospect()));
    },
  );
}
class _PropspectsState extends State<Propspects> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Container(child: Text('Sin datos'),);
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBar('Prospectos',null, actionButtons(context)),
                  Expanded(child: Container(child: Text(' datos'))

                  )

                ],
              ),
            ) ;
          }
        }
      )
    );
  }
}