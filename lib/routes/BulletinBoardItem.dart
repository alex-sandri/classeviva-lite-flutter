import 'dart:isolate';
import 'dart:ui';

import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItem.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItemDetails.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableWidget.dart';
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
  final ClasseViva _session = ClasseViva.current;

  ReceivePort _port = ReceivePort();

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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget._item.titolo),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Descrizione",
                  icon: Icon(Icons.description),
                ),
                Tab(
                  text: "Allegati",
                  icon: Icon(Icons.attachment),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ClasseVivaRefreshableWidget<ClasseVivaBulletinBoardItemDetails>(
                stream: () => ClasseViva.current.getBulletinBoardItemDetails(widget._item.id),
                builder: (details) {
                  return Padding(
                    padding: EdgeInsets.all(4),
                    child: SelectableText(details.description),
                  );
                },
                isResultEmpty: (result) => false,
                emptyResultMessage: null,
              ),
              ClasseVivaRefreshableWidget<ClasseVivaBulletinBoardItemDetails>(
                stream: () => ClasseViva.current.getBulletinBoardItemDetails(widget._item.id),
                builder: (details) {
                  return ListView.builder(
                    itemCount: details.attachments.length,
                    itemBuilder: (context, index) {
                      final ClasseVivaBulletinBoardItemDetailsAttachment attachment = details.attachments[index];

                      return ListTile(
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
                        title: Text(attachment.name),
                      );
                    },
                  );
                },
                isResultEmpty: (result) => result.attachments.isEmpty,
                emptyResultMessage: "Non sono presenti allegati",
              ),
            ],
          ),
        ),
      ),
    );
  }
}