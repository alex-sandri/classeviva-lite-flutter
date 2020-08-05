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

  bool _downloaderInitialized = false;

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

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      _session = ClasseViva(
        sessionId: preferences.getString("sessionId"),
        context: context
      );

      _handleRefresh();
    });
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
                              itemCount: _attachments.length,
                              itemBuilder: (context, index) {
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

                                          if (!_downloaderInitialized)
                                          {
                                            _downloaderInitialized = true;

                                            await FlutterDownloader.initialize(debug: false);
                                          }

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