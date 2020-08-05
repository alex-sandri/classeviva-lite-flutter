import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Attachments extends StatefulWidget {
  @override
  _AttachmentsState createState() => _AttachmentsState();
}

class _AttachmentsState extends State<Attachments> {
  ClasseViva _session;

  List<ClasseVivaAttachment> _attachments;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaAttachment> attachments = await _session.getAttachments();

    if (mounted)
      setState(() {
        _attachments = attachments;
      });
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
                                    onTap: () {},
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
                                        SelectableText(
                                          attachment.date,
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