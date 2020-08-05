import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Agenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        final SharedPreferences preferences = await SharedPreferences.getInstance();

        return ClasseViva(
          sessionId: preferences.getString("sessionId"),
          context: context
        );
      }.call(),
      builder: (context, AsyncSnapshot<ClasseViva> session) {
        if (!session.hasData)
          return Container(
            color: Theme.of(context).primaryColor,
          );

        return Material(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Agenda & Compiti'
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: FutureBuilder(
                        future: session.data.getAgenda(DateTime(2020, 5, 1), DateTime(2020, 6, 1)),
                        builder: (context, AsyncSnapshot<List<ClasseVivaAgendaItem>> agenda) {
                          if (!agenda.hasData)
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                              ),
                            );

                          agenda.data.sort((a, b) {
                            // Most recent first
                            return b.start.compareTo(a.start);
                          });

                          return ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                              color: Theme.of(context).accentColor,
                            ),
                            shrinkWrap: true,
                            itemCount: agenda.data.length,
                            itemBuilder: (context, index) {
                              final ClasseVivaAgendaItem item = agenda.data[index];

                              return ListTile(
                                title: SelectableText(
                                  item.autore_desc,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 5,),
                                    SelectableText(
                                      "(${DateFormat.yMMMMd().add_jm().format(item.start)} - ${DateFormat.yMMMMd().add_jm().format(item.end)})",
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    SelectableText(
                                      item.nota_2,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ],
                                )
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}