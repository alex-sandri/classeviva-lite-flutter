import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Demerits extends StatefulWidget {
  @override
  _DemeritsState createState() => _DemeritsState();
}

class _DemeritsState extends State<Demerits> {
  ClasseViva _session;

  List<ClasseVivaDemerit> _demerits;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaDemerit> demerits = await _session.getDemerits();

    demerits.sort((a, b) {
      // Most recent first
      return b.date.compareTo(a.date);
    });

    if (mounted)
      setState(() {
        _demerits = demerits;
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
            'Note'
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
                    child: _demerits == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).accentColor,
                        ),
                        itemCount: _demerits.length,
                        itemBuilder: (context, index) {
                          final ClasseVivaDemerit demerit = _demerits[index];

                          return ListTile(
                            title: SelectableText(
                              demerit.teacher,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w900,
                              ),
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
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: SelectableText(
                                        " - ${demerit.type}",
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                SelectableLinkify(
                                  text: demerit.content,
                                  options: LinkifyOptions(humanize: false),
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
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
      ),
    );
  }
}