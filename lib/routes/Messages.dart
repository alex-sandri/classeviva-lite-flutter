import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaMessage.dart';
import 'package:classeviva_lite/routes/Message.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final ClasseViva _session = ClasseViva.current;

  List<ClasseVivaMessage> _messages;

  Future<void> _handleRefresh() async {
    await for (final List<ClasseVivaMessage> messages in _session.getMessages())
    {
      if (messages == null) continue;

      if (mounted)
        setState(() {
          _messages = messages;
        });
    }
  }

  void initState() {
    super.initState();

    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Messaggi"),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _messages == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _messages.isNotEmpty
                        ? _messages.length
                        : 1,
                      itemBuilder: (context, index) {
                        if (_messages.isEmpty)
                          return SelectableText(
                            "Non sono presenti messaggi",
                            textAlign: TextAlign.center,
                          );

                        final ClasseVivaMessage message = _messages[index];

                        return ListTile(
                          title: Text(message.subject),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(DateFormat.yMMMMd().add_jms().format(message.createdAt)),
                              Text(message.content),
                            ],
                          ),
                          trailing: !message.isRead
                            ? Tooltip(
                                message: "Non letto",
                                child: Icon(
                                  Icons.circle,
                                  color: ClasseViva.PRIMARY_LIGHT,
                                ),
                              )
                            : null,
                          onTap: () {
                            message.markAsRead();

                            Get.to(Message(message));
                          },
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