import 'dart:isolate';
import 'dart:ui';

import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAttachment.dart';
import 'package:classeviva_lite/widgets/classeviva_webview.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
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
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  List<ClasseVivaAttachment> _attachments;

  bool _showLoadMoreButton = true;

  ReceivePort _port = ReceivePort();

  Future<void> _handleRefresh() async {
    _session.attachmentsPage = 1;

    await for (final List<ClasseVivaAttachment> attachments in _session.getAttachments())
    {
      if (attachments == null) continue;

      if (mounted)
        setState(() {
          _attachments = attachments;
        });
    }
  }

  bool _loading = false;

  Future<void> _loadMore() async {
    if (!_showLoadMoreButton) return;

    setState(() {
      _loading = true;

      _showLoadMoreButton = false;
    });

    _session.attachmentsPage++;

    await for (final List<ClasseVivaAttachment> attachments in _session.getAttachments())
    {
      if (attachments == null) continue;

      if (mounted)
        setState(() {
        _loading = false;

        _attachments.addAll(attachments);

        _showLoadMoreButton = attachments.isNotEmpty;
      });
    }
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

    _handleRefresh();

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
          title: Text("Didattica"),
          actions: [
            FlatButton(
              child: Text("Compiti"),
              onPressed: () => Get.to(ClasseVivaWebview(
                session: _session,
                title: "Compiti",
                url: Uri.parse(ClasseVivaEndpoints(_session.getShortYear()).homework()),
              )),
            ),
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "Cerca",
              onPressed: () {
                // TODO
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.extentAfter == 0)
                      _loadMore();

                    return true;
                  },
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    backgroundColor: Theme.of(context).appBarTheme.color,
                    child: _attachments == null
                      ? Spinner()
                      : ListView.builder(
                          itemCount: _attachments.length + 1,
                          itemBuilder: (context, index) {
                            if (_attachments.isEmpty)
                            {
                              return SelectableText(
                                "Non sono presenti elementi in Didattica",
                                textAlign: TextAlign.center,
                              );
                            }

                            if (index == _attachments.length)
                            {
                              if (_loading)
                                return Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Spinner(),
                                );

                              if (!_showLoadMoreButton) return Container();

                              return FlatButton(
                                color: Theme.of(context).appBarTheme.color,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  "Carica più elementi",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                onPressed: _loadMore,
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

                            return ListTile(
                              onTap: () async {
                                final String url = attachment.url;

                                switch (attachment.type)
                                {
                                  case ClasseVivaAttachmentType.File:
                                    await _requestPermission();

                                    await FlutterDownloader.enqueue(
                                      url: url,
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
                                          content: SingleChildScrollView(
                                            child: SelectableLinkify(
                                              text: document.body.text.trim(),
                                              options: LinkifyOptions(humanize: false),
                                              onOpen: (link) async {
                                                if (await canLaunch(link.url)) await launch(link.url);
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
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    break;
                                }
                              },
                              leading: CircleAvatar(
                                child: Icon(
                                  _getAttachmentIcon(attachment),
                                  color: Theme.of(context).accentColor,
                                ),
                                backgroundColor: Theme.of(context).appBarTheme.color,
                                radius: 25,
                              ),
                              title: Text(
                                attachment.name,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 5,),
                                  Text(
                                    attachment.teacher,
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    DateFormat.yMMMMd().format(attachment.date),
                                  ),
                                ],
                              )
                            );
                          },
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}