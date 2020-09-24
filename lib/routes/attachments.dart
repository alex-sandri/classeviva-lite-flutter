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

  bool _showFolders = false;

  ReceivePort _port = ReceivePort();

  Future<void> _handleRefresh() async {
    await for (final List<ClasseVivaAttachment> attachments in _session.getAttachments())
    {
      if (attachments == null) continue;

      if (mounted)
        setState(() {
          _attachments = attachments;
        });
    }
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
              onPressed: () => showSearch(
                context: context,
                delegate: AttachmentsSearchDelegate(),
              ),
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
              SwitchListTile(
                title: Text("Mostra cartelle"),
                value: _showFolders,
                onChanged: (checked) => setState(() => _showFolders = checked),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _showFolders
                    ? Container()
                    : AttachmentsListView(_attachments),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttachmentsListView extends StatelessWidget {
  final List<ClasseVivaAttachment> _attachments;

  AttachmentsListView(this._attachments);

  Future<void> _requestPermission() async {
    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return _attachments == null
      ? Spinner()
      : ListView.builder(
          itemCount: _attachments.isNotEmpty
            ? _attachments.length
            : 1,
          itemBuilder: (context, index) {
            if (_attachments.isEmpty)
            {
              return SelectableText(
                "Non sono presenti elementi in Didattica",
                textAlign: TextAlign.center,
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
                final ClasseViva session = ClasseViva(ClasseViva.getCurrentSession());

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
                      headers: session.getSessionCookieHeader(),
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
                      headers: session.getSessionCookieHeader(),
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
                    DateFormat.yMMMMd().add_jms().format(attachment.date),
                  ),
                ],
              )
            );
          },
        );
  }
}

class AttachmentsSearchDelegate extends SearchDelegate
{
  AttachmentsSearchDelegate(): super(
    searchFieldStyle: TextStyle(
      color: Colors.white70,
    ),
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return theme.copyWith(
      primaryColor: theme.appBarTheme.color,
      textTheme: theme.primaryTextTheme.copyWith(
        headline6: theme.primaryTextTheme.headline6.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        tooltip: "Cancella",
        onPressed: () {
          query = "";
        },
      )
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<ClasseVivaAttachment>>(
      stream: ClasseViva(ClasseViva.getCurrentSession()).getAttachments(query: query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Spinner();

        return AttachmentsListView(snapshot.data);
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}