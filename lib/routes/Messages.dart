import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaMessage.dart';
import 'package:classeviva_lite/routes/Message.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaMessage>>(
      title: "Messaggi",
      stream: () => ClasseViva.current.getMessages(),
      builder: (messages) {
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final ClasseVivaMessage message = messages[index];

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
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti messaggi",
    );
  }
}