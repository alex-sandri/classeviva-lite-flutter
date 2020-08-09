import 'package:classeviva_lite/bulletin_board_item.dart';
import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BulletinBoard extends StatefulWidget {
  @override
  _BulletinBoardState createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard> {
  ClasseViva _session;

  List<ClasseVivaBulletinBoardItem> _items;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaBulletinBoardItem> items = await _session.getBulletinBoard();

    items.sort((a, b) {
      // Most recent first
      return b.evento_data.compareTo(a.evento_data);
    });

    if (mounted)
      setState(() {
        _items = items;
      });
  }

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) async {
      _session = ClasseViva(
        sessionId: await ClasseViva.getCurrentSession(),
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
            'Bacheca'
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
                    child: _items == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _items.length + 1,
                        itemBuilder: (context, index) {
                          if (_items.isEmpty)
                            return SelectableText(
                              "Non sono presenti elementi in bacheca",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                              textAlign: TextAlign.center,
                            );

                          if (index == _items.length) return Container();

                          final ClasseVivaBulletinBoardItem item = _items[index];

                          return Card(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BulletinBoardItem(item),
                                  )
                                );
                              },
                              isThreeLine: true,
                              title: Text(
                                item.titolo,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 5,),
                                  Text(
                                    DateFormat.yMMMMd().format(item.evento_data),
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Text(
                                    item.tipo_com_desc,
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