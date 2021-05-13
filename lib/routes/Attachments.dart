import 'package:classeviva_lite/miscellaneous/ClasseVivaSearchDelegate.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAttachment.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:classeviva_lite/widgets/ClassevivaWebview.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:collection/collection.dart';
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

class ClasseVivaAttachmentFolder
{
  final String name;
  
  final String teacher;

  final DateTime lastUpdated;

  final List<ClasseVivaAttachment> attachments;

  ClasseVivaAttachmentFolder({
    @required this.name,
    @required this.teacher,
    @required this.lastUpdated,
    @required this.attachments,
  });
}

extension on List<ClasseVivaAttachment>
{
  List<ClasseVivaAttachmentFolder> get folders {
    final List<ClasseVivaAttachmentFolder> folders = [];

    final Set<String> teachers = this.map((attachment) => attachment.teacher).toSet();

    teachers.forEach((teacher) {
      final Map<String, List<ClasseVivaAttachment>> teacherFolders = groupBy(
        this.where((element) => element.teacher == teacher),
        (attachment) => attachment.folder,
      );

      teacherFolders.forEach((key, value) {
        folders.add(ClasseVivaAttachmentFolder(
          name: key,
          teacher: teacher,
          lastUpdated: value.first.date,
          attachments: value,
        ));
      });
    });

    folders.sort((a, b) => -a.lastUpdated.compareTo(b.lastUpdated));

    return folders;
  }
}

class Attachments extends StatefulWidget {
  @override
  _AttachmentsState createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  bool _showFolders = false;

  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaAttachment>>(
      title: "Didattica",
      actions: [
        TextButton(
          child: Text("Compiti"),
          style: Theme.of(context).textButtonTheme.style.copyWith(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () => Get.to(ClasseVivaWebview(
            title: "Compiti",
            url: Uri.parse(ClasseVivaEndpoints.current.homework()),
          )),
        ),
        IconButton(
          icon: Icon(Icons.search),
          tooltip: "Cerca",
          onPressed: () => showSearch(
            context: context,
            delegate: ClasseVivaSearchDelegate<ClasseVivaAttachment>(
              stream: (query) => ClasseViva.current.getAttachments(query: query),
              builder: (item) => AttachmentListTile(item),
            ),
          ),
        ),
      ],
      head: SwitchListTile(
        title: Text("Mostra cartelle"),
        value: _showFolders,
        onChanged: (checked) => setState(() => _showFolders = checked),
      ),
      stream: () => ClasseViva.current.getAttachments(),
      builder: (attachments) {
        final List<ClasseVivaAttachmentFolder> folders = attachments.folders;

        // Do not show duplicates when not showing the folders
        attachments = attachments.where((element) => attachments.indexOf(element) == attachments.indexWhere((elementa) => elementa.id == element.id)).toList();

        return _showFolders
          ? ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final ClasseVivaAttachmentFolder folder = folders[index];

                return ExpansionTile(
                  title: Text(folder.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.teacher,
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        DateFormat.yMMMMd().add_jms().format(folder.lastUpdated),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  children: folder.attachments.map((attachment) => AttachmentListTile(attachment)).toList(),
                );
              },
            )
          : AttachmentsListView(attachments);
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti elementi in Didattica",
    );
  }
}

class AttachmentListTile extends StatelessWidget {
  final ClasseVivaAttachment attachment;

  AttachmentListTile(this.attachment);

  Future<void> _requestPermission() async {
    PermissionStatus permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) await Permission.storage.request();
  }

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final ClasseViva session = ClasseViva.current;

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
              Uri.parse(url),
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
  }
}

class AttachmentsListView extends StatelessWidget {
  final List<ClasseVivaAttachment> _attachments;

  AttachmentsListView(this._attachments);

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

            return AttachmentListTile(_attachments[index]);
          },
        );
  }
}