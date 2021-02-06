import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
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
      icon: const Icon(Icons.clear),
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
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        FormBuilder(
                          child: Column(
                            children: [
                              FormBuilderTextField(
                                name: 'name',
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: 'Nombre',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'owner',
                                decoration: InputDecoration(
                                  labelText: 'Dueño',
                                  hintText: 'Dueño',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'phone',
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  hintText: 'Teléfono',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                ),
                              ),
                              Divider(),
                              FormBuilderImagePicker(
                                name: 'image',
                                decoration: const InputDecoration(
                                  labelText: 'Foto',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                ),
                                maxImages: 1,
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'latitude',
                                decoration: InputDecoration(
                                  hintText: 'Latitud',
                                  labelText: 'Latitud',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'longitud',
                                decoration: InputDecoration(
                                  hintText: 'Longitud',
                                  labelText: 'Longitud',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'address',
                                maxLines: 5,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Dirección',
                                  labelText: 'Dirección',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.short_text)
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                name: 'notes',
                                maxLines: 5,
                                minLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Notas',
                                  labelText: 'Notas',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left:48),
                                  prefixIcon: Icon(Icons.short_text)
                                ),
                              ),
                              Divider(),
                            ],
                          )
                        )
                      ],
                    ),
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