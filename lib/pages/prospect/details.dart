import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/widgets/appbar.dart';

class Prospect extends StatefulWidget {
  @override
  _ProspectState createState() => _ProspectState();
}


class _ProspectState extends State<Prospect> {
Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }
Widget actionButtons( ){
  return InkWell(
    borderRadius:
        BorderRadius.circular(AppBar().preferredSize.height),
    child: Icon(
       Icons.save,
      color: AppSettings.PRIMARY,
    ),
    onTap: () {
       print('guardar');
    },
  );
}
Widget _leadingIcon(){
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      color: AppSettings.PRIMARY,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
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
                  appBar('detalle',_leadingIcon(),actionButtons()),
                  ListView(
                    children: [
                      FormBuilder(
                        child: Column(
                          children: [
                            FormBuilderTextField(
                               name: 'Nombre'
                            
                            )
                          ],
                        )
                      )
                    ],
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