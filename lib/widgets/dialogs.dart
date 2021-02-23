import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turno_admin/classes/app_settings.dart';
import 'package:turno_admin/widgets/network_image.dart';

class BeautifulAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 150,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(75),
                  bottomLeft: Radius.circular(75),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Row(
            children: <Widget>[
              SizedBox(width: 20.0),
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade200,
                child: PNetworkImage(
                  'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/img%2Finfo-icon.png?alt=media',
                  width: 60,
                ),
              ),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Alert!",
                      style: Theme.of(context).textTheme.title,
                    ),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(
                          "Do you want to continue to turn off the services?"),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: Text("No"),
                            color: Colors.red,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: RaisedButton(
                            child: Text("Yes"),
                            color: Colors.green,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSuccessDialog extends StatelessWidget {
  final image =  'https://firebasestorage.googleapis.com/v0/b/dl-flutter-ui-challenges.appspot.com/o/img%2F3.jpg?alt=media';
  final TextStyle subtitle = TextStyle(fontSize: 12.0, color: Colors.grey);
  final TextStyle label = TextStyle(fontSize: 14.0, color: Colors.grey);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 370,
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Thank You!",
                  style: TextStyle(color: Colors.green),
                ),
                Text(
                  "Your transaction was successful",
                  style: label,
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "DATE",
                      style: label,
                    ),
                    Text("TIME", style: label)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text("2, April 2019"), Text("9:10 AM")],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "TO",
                          style: label,
                        ),
                        Text("Manny Moto"),
                        Text(
                          "manny.moto@gmail.com",
                          style: subtitle,
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      backgroundImage: AssetImage(image),
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "AMOUNT",
                          style: label,
                        ),
                        Text("\$ 15000"),
                      ],
                    ),
                    Text(
                      "COMPLETED",
                      style: label,
                    )
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.account_balance_wallet),
                      ),
                      SizedBox(width: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Credit/Debit Card"),
                          Text(
                            "Master Card ending ***5",
                            style: subtitle,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AlertDialogType {
  SUCCESS,
  ERROR,
  WARNING,
  INFO,
  LOADING,
}

class CustomAlertDialog extends StatelessWidget {
  final AlertDialogType type;
  final String title;
  final String content;
  final Widget icon;
  final String buttonLabel;
  final TextStyle titleStyle = TextStyle(
        fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold);
  CustomAlertDialog(
      {Key key,
      this.title = "Successful",
      @required this.content,
      this.icon,
      this.type = AlertDialogType.INFO,
      this.buttonLabel = "Ok"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Container(
          alignment: Alignment.center,
          child: Column(
                  mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const  Radius.circular(20.0),
                    topRight: const  Radius.circular(20.0),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    icon ??_getIconForType(type),
                    const SizedBox(height: 10.0),
                    Text(
                      title,
                      style: titleStyle,
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              (buttonLabel!=null)?Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  width: double.infinity,
                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: const  Radius.circular(20.0),
                      bottomRight: const  Radius.circular(20.0),
                    ),
                    color: AppSettings.PRIMARY,
                  ),
                  child: FlatButton(
                    // padding: const EdgeInsets.all(5.0),
                    child: Text(buttonLabel),
                    textColor: AppSettings.white,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ):SizedBox(
                  width: double.infinity
                ),
            ],
          ),
        ));
  }

  Widget _getIconForType(AlertDialogType type) {
    switch (type) {
      case AlertDialogType.SUCCESS:
        return  Icon(
            FontAwesomeIcons.thumbsUp,
            color: _getColorForType(type),
            size: 50,
          );
      case AlertDialogType.WARNING:
       return Icon(
            Icons.check_circle,
            color: _getColorForType(type),
            size: 50,
          );
      case AlertDialogType.ERROR:
        return Icon(
            Icons.error,
            color: _getColorForType(type),
            size: 50,
          );
      case AlertDialogType.INFO:
      default:
        return Icon(
            Icons.info_outline,
            color: _getColorForType(type),
            size: 50,
          );
    }
  }

  Color _getColorForType(AlertDialogType type) {
    switch (type) {
      case AlertDialogType.WARNING:
        return Colors.orange;
      case AlertDialogType.SUCCESS:
        return Colors.green;
      case AlertDialogType.ERROR:
        return Colors.red;
      case AlertDialogType.INFO:
      default:
        return Colors.blue;
    }
  }
}