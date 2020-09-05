import 'package:classeviva_lite/routes/bulletin_board_item.dart';
import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    ClasseViva.getCurrentSession().then((session) {
      _session = ClasseViva(session);

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
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _session == null
            ? Spinner()
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _items == null
                  ? Spinner()
                  : ListView.builder(
                      itemCount: _items.length + 1,
                      itemBuilder: (context, index) {
                        if (_items.isEmpty)
                          return SelectableText(
                            "Non sono presenti elementi in bacheca",
                            textAlign: TextAlign.center,
                          );

                        if (index == _items.length) return Container();

                        final ClasseVivaBulletinBoardItem item = _items[index];

                        return Card(
                          child: ListTile(
                            onTap: () => Get.to(BulletinBoardItem(item)),
                            trailing: Icon(
                              item.conf_lettura
                                ? Icons.mail
                                : Icons.drafts,
                              color: item.conf_lettura
                                ? Colors.green
                                : Colors.red,
                            ),
                            title: Text(
                              item.titolo,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 5,),
                                Text(
                                  DateFormat.yMMMMd().format(item.evento_data),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  item.tipo_com_desc,
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
    );
  }
}