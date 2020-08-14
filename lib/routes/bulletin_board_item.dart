import 'dart:isolate';
import 'dart:ui';

import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BulletinBoardItem extends StatefulWidget {
  final ClasseVivaBulletinBoardItem _item;

  BulletinBoardItem(this._item);

  @override
  _BulletinBoardItemState createState() => _BulletinBoardItemState();
}

class _BulletinBoardItemState extends State<BulletinBoardItem> {
  ClasseViva _session;

  ClasseVivaBulletinBoardItemDetails _item;

  ReceivePort _port = ReceivePort();

  Future<void> _handleRefresh() async {
    final ClasseVivaBulletinBoardItemDetails item = await _session.getBulletinBoardItemDetails(widget._item.id);

    if (mounted)
      setState(() {
        _item = item;
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

    ClasseViva.getCurrentSession().then((session) {
      _session = ClasseViva(
        session: session,
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
            widget._item.titolo,
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _session == null
            ? Spinner()
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: Theme.of(context).primaryColor,
                  child: _item == null
                  ? Spinner()
                  : ListView.builder(
                    itemCount: _item.attachments.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0)
                        return Padding(
                          padding: EdgeInsets.all(4),
                          child: SelectableText(
                            _item.description,
                          ),
                        );
                      
                      if (index == 1)
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                          child: SelectableText(
                            "Allegati",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 25,
                            ),
                          ),
                        );

                      if (_item.attachments.isEmpty)
                        return Padding(
                          padding: EdgeInsets.all(4),
                          child: SelectableText(
                            "Non sono presenti allegati",
                          ),
                        );

                      final ClasseVivaBulletinBoardItemDetailsAttachment attachment = _item.attachments[index - 2];

                      return Card(
                        child: ListTile(
                          onTap: () async {
                            await _requestPermission();

                            await FlutterDownloader.enqueue(
                              url: "https://web${_session.getShortYear()}.spaggiari.eu/sif/app/default/bacheca_personale.php?action=file_download&com_id=${attachment.id}",
                              savedDir: (Theme.of(context).platform == TargetPlatform.android
                                ? await getExternalStorageDirectory()
                                : await getApplicationDocumentsDirectory()).path,
                              showNotification: true,
                              openFileFromNotification: true,
                              headers: _session.getSessionCookieHeader(),
                            );
                          },
                          title: Text(
                            attachment.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}