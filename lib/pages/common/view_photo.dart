import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhoto extends StatelessWidget {
  final String _url;
  final File file;
  ViewPhoto(this._url, this.file);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   title: Text('图片'),
      // ),
      body: Container(
        // appBar:AppBar(title: Text('查看照片'),),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: PhotoView(
              imageProvider:
                  _url != null ? NetworkImage(_url) : AssetImage(file.path)),
        ),
      ),
    );
  }
}

// class ViewPhoto extends StatefulWidget {
//   final String _url;
//   final File file;
//   ViewPhoto(this._url, this.file);
//   @override
//   _ViewPhotoState createState() => _ViewPhotoState();
// }

// class _ViewPhotoState extends State<ViewPhoto> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: GestureDetector(
//         onTap: () {
//           Navigator.pop(context);
//         },
//         child: PhotoView(
//             imageProvider: this.widget._url != null
//                 ? NetworkImage(this.widget._url)
//                 : AssetImage(this.widget.file.path)),
//       ),
//     );
//   }
// }
