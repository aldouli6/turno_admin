import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:turno_admin/classes/app_settings.dart';

class PNetworkImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double width,height;
  const PNetworkImage(this.image, {Key key,this.fit,this.height,this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return CachedNetworkImage(
    //     imageUrl: image,
    //     progressIndicatorBuilder: (context, url, downloadProgress) => 
    //             Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
    //     errorWidget: (context, url, error) => Icon(Icons.error,color: AppSettings.DANGER,),
    //     fit: fit,
    //   width: width,
    //   height: height,
    //  );
     return Image.network(
         image,
         key: ValueKey(new Random().nextInt(100)), 
          errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
              return Icon(Icons.error,color: AppSettings.DANGER,);
          },
         loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ? 
                    loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          },
        fit: fit,
      width: width,
      height: height,
     );
     
  }
}