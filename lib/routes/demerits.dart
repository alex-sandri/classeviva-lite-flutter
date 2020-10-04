import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaDemerit.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Demerits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaDemerit>>(
      title: "Note",
      stream: () => ClasseViva.current.getDemerits(),
      builder: (demerits) {
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: demerits.length,
          itemBuilder: (context, index) {
            final ClasseVivaDemerit demerit = demerits[index];

            return ListTile(
              title: SelectableText(demerit.teacher),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SelectableText(DateFormat.yMMMMd().format(demerit.date)),
                      Expanded(
                        child: SelectableText(
                          " - ${demerit.type}",
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  SelectableLinkify(
                    text: demerit.content,
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
                ],
              )
            );
          },
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti note",
    );
  }
}