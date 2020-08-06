import 'dart:isolate';
import 'dart:ui';

import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Attachments extends StatefulWidget {
  @override
  _AttachmentsState createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  ClasseViva _session;

  List<ClasseVivaAttachment> _attachments;

  bool _showLoadMoreButton = true;

  bool _showLoadMoreSpinner = false;

  ReceivePort _port = ReceivePort();

  Future<void> _handleRefresh() async {
    final List<ClasseVivaAttachment> attachments = await _session.getAttachments();

    if (mounted)
      setState(() {
        _attachments = attachments;
      });
  }

  Future<void> _requestPermission() async {
    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) await Permission.storage.request();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');

    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      _session = ClasseViva(
        sessionId: preferences.getString("sessionId"),
        context: context
      );

      _handleRefresh();
    });

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];

      if (status == DownloadTaskStatus.complete) FlutterDownloader.open(taskId: id);
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Didattica'
          ),
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            child: _session == null
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Theme.of(context).primaryColor,
                        child: _attachments == null
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _attachments.length + 1,
                              itemBuilder: (context, index) {
                                if (_attachments.isEmpty)
                                {
                                  return SelectableText(
                                    "Non sono presenti elementi in Didattica",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                }

                                if (index == _attachments.length)
                                {
                                  if (_showLoadMoreSpinner)
                                    return Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                                        ),
                                      ),
                                    );

                                  if (!_showLoadMoreButton) return Container();

                                  return Padding(
                                    padding: EdgeInsets.all(4),
                                    child: FlatButton(
                                      color: Theme.of(context).accentColor,
                                      disabledColor: Theme.of(context).disabledColor,
                                      padding: EdgeInsets.all(15),
                                      child: Text(
                                        "Carica più elementi",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          _showLoadMoreButton = false;
                                          _showLoadMoreSpinner = true;
                                        });

                                        _session.attachmentsPage++;

                                        final List<ClasseVivaAttachment> attachments = await _session.getAttachments();

                                        if (mounted)
                                          setState(() {
                                            _attachments.addAll(attachments);

                                            _showLoadMoreButton = attachments.isNotEmpty;
                                            _showLoadMoreSpinner = false;
                                          });
                                      },
                                    ),
                                  );
                                }

                                final ClasseVivaAttachment attachment = _attachments[index];

                                IconData _getAttachmentIcon(ClasseVivaAttachment attachment)
                                {
                                  IconData icon;

                                  switch (attachment.type)
                                  {
                                    case ClasseVivaAttachmentType.File: icon = Icons.insert_drive_file; break;
                                    case ClasseVivaAttachmentType.Link: icon = Icons.link; break;
                                    case ClasseVivaAttachmentType.Text: icon = Icons.text_fields; break;
                                  }

                                  return icon; 
                                }

                                return Card(
                                  color: Theme.of(context).disabledColor,
                                  child: ListTile(
                                    onTap: () async {
                                      final String url = attachment.url.toString();

                                      switch (attachment.type)
                                      {
                                        case ClasseVivaAttachmentType.File:
                                          await _requestPermission();

                                          await FlutterDownloader.enqueue(
                                            url: attachment.url.toString(),
                                            savedDir: (Theme.of(context).platform == TargetPlatform.android
                                              ? await getExternalStorageDirectory()
                                              : await getApplicationDocumentsDirectory()).path,
                                            showNotification: true,
                                            openFileFromNotification: true,
                                            headers: _session.getSessionCookieHeader(),
                                          );
                                          break;
                                        case ClasseVivaAttachmentType.Link:
                                          if (await canLaunch(url)) await launch(url);
                                          else
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text("Errore"),
                                                  content: Text("Impossibile aprire il link"),
                                                );
                                              },
                                            );
                                          break;
                                        case ClasseVivaAttachmentType.Text:
                                          final response = await http.get(
                                            url,
                                            headers: _session.getSessionCookieHeader(),
                                          );

                                          final document = parse(response.body);

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Text(document.body.text.trim()),
                                              );
                                            },
                                          );
                                          break;
                                      }
                                    },
                                    isThreeLine: true,
                                    leading: CircleAvatar(
                                      child: Icon(
                                        _getAttachmentIcon(attachment),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      backgroundColor: Theme.of(context).accentColor,
                                      radius: 25,
                                    ),
                                    title: SelectableText(
                                      attachment.name,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 5,),
                                        SelectableText(
                                          attachment.teacher,
                                          style: TextStyle(
                                            color: Theme.of(context).accentColor,
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        SelectableText(
                                          DateFormat.yMMMMd().format(attachment.date),
                                          style: TextStyle(
                                            color: Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}