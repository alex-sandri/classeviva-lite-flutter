import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaDemerit.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Demerits extends StatefulWidget {
  @override
  _DemeritsState createState() => _DemeritsState();
}

class _DemeritsState extends State<Demerits> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  List<ClasseVivaDemerit> _demerits;

  Future<void> _handleRefresh() async {
    await for (final List<ClasseVivaDemerit> demerits in _session.getDemerits())
    {
      if (demerits == null) continue;

      if (mounted)
        setState(() {
          _demerits = demerits;
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
          title: Text(
            'Note'
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _demerits == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _demerits.isNotEmpty
                        ? _demerits.length
                        : 1,
                      itemBuilder: (context, index) {
                        if (_demerits.isEmpty)
                          return SelectableText(
                            "Non sono presenti note",
                            textAlign: TextAlign.center,
                          );

                        final ClasseVivaDemerit demerit = _demerits[index];

                        return ListTile(
                          title: SelectableText(
                            demerit.teacher,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 5,),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  SelectableText(
                                    DateFormat.yMMMMd().format(demerit.date),
                                  ),
                                  Expanded(
                                    child: SelectableText(
                                      " - ${demerit.type}",
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5,),
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