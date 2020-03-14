import 'dart:io';

import 'package:apod/components/typewritertext.dart';
import 'package:apod/models/download_progress.dart';
import 'package:apod/models/pic.dart';
import 'package:apod/services/api.dart';
import 'package:apod/services/wall.dart';
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PicView extends StatefulWidget {
  final DateTime date;
  final Function() imageNotAvailable;

  const PicView(this.date, {Key key, this.imageNotAvailable}) : super(key: key);
  @override
  _PicViewState createState() => _PicViewState();
}

class _PicViewState extends State<PicView> {
  GlobalKey<ScaffoldState> _skey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: api.getPic(widget.date),
        builder: (c, snap) {
          if (snap.hasData) {
            Pic p = snap.data;

            return Scaffold(
              key: _skey,
              body: Stack(
                children: <Widget>[
                  if (p.isImage()) buildPic(p) else buildSomethingElse(p),
                  buildInfo(p),
                  buildActions(p)
                ],
              ),
            );
          }

          if (snap.hasError) {
            var error = snap.error;

            if (error is DioError && error.response?.statusCode == 400) {
              widget.imageNotAvailable();
            }

            return Center(child: Text(snap.error.toString()));
          }

          return Center(child: CircularProgressIndicator());
        });
  }

  buildSomethingElse(Pic pic) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("¯\\_(ツ)_/¯", style: Theme.of(context).textTheme.display3),
        SizedBox(height: 10),
        Text("Format not supported.",
            style: Theme.of(context).textTheme.subtitle),
        SizedBox(height: 30),
        FlatButton(
            color: Theme.of(context).primaryColor,
            onPressed: () => openWebsite(pic),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Text(
              "Open on browser",
              style: TextStyle(color: Colors.white),
            ))
      ],
    ));
  }

  openWebsite(Pic p) {
    launch(p.getNasaArchiveUrl());
  }

  buildActions(Pic p) {
    var date = DateFormat("dd MMMM yyyy").format(p.date);
    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      child: AppBar(
        title: Text("// $date"),
        backgroundColor: Colors.black.withOpacity(0.3),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              onPressed: () => openWebsite(p)),
          PopupMenuButton<int>(
            icon: Icon(
              Icons.wallpaper,
              color: Colors.white,
            ),
            onSelected: (mode) => setWallPaper(p, mode),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<int>(
                  value: Wall.HOME,
                  child: Text("Home screen"),
                ),
                PopupMenuItem<int>(
                  value: Wall.LOCK,
                  child: Text("Lock screen"),
                ),
                PopupMenuItem<int>(
                  value: Wall.BOTH,
                  child: Text("Both"),
                ),
                // PopupMenuItem<int>(
                //   value: Wall.SYSTEM,
                //   child: Text("System"),
                // )
              ];
            },
          ),
        ],
      ),
    );
  }

  buildInfo(Pic p) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        color: Colors.black87.withOpacity(0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              p.title,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.white),
            ),
            SizedBox(
              height: 4,
            ),
            if (p.copyright != null)
              Text(
                "${p.copyright}",
                style: Theme.of(context)
                    .textTheme
                    .subtitle
                    .copyWith(color: Colors.white54),
              )
          ],
        ),
      ),
    );
  }

  showSnackBar(Widget content, {Duration duration}) {
    var snack = _skey.currentState.showSnackBar(SnackBar(
      content: content,
      behavior: SnackBarBehavior.floating,
    ));
    return snack;
  }

  setWallPaper(Pic p, int mode) async {
    File f = await api.getFile(p);

    String name = f.path.split('/').last;
    Wall.setWallPaper(name, mode: mode).then((v) {
      showSnackBar(Text("Wallpaper set!"));
    }).catchError((e) {
      if (e is PlatformException) {
        showSnackBar(Text(e.message));
      } else {
        showSnackBar(Text(e.toString()));
      }
    });
  }

  buildProgressStatus([DownloadProgress p]) {
    return Center(
        child: Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            value: p == null ? null : p.received / p.total,
          ),
          SizedBox(height: 20),
          TypewriterText(
            'You must wait it\'s worth it',
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 20),
            delay: Duration(milliseconds: 700),
          ),
          SizedBox(height: 10),
          if (p != null) Text("${filesize(p.received)}/${filesize(p.total)}")
        ],
      ),
    ));
  }

  Widget buildPic(Pic p) {
    // if (false)
    //   return CachedNetworkImage(
    //     imageUrl: p.url,
    //     height: double.infinity,
    //     fit: BoxFit.fitHeight,
    //     placeholder: (b, a) {
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     },
    //   );
    return StreamBuilder(
        stream: api.getFileAsStream(p),
        builder: (c, snap) {
          if (snap.hasError) return Center(child: Text(snap.error.toString()));

          dynamic data = snap.data;
          if (data is File) {
            return Container(
              height: double.infinity,
              child: Image.file(
                snap.data,
                fit: BoxFit.fitHeight,
              ),
            );
          } else if (data is DownloadProgress) {
            return buildProgressStatus(data);
          }

          return buildProgressStatus();
        });
  }
}
