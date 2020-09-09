import 'package:classeviva_lite/routes/bulletin_board_item.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BulletinBoard extends StatefulWidget {
  @override
  _BulletinBoardState createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  List<ClasseVivaBulletinBoardItem> _items;

  bool _hideInactive = true;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaBulletinBoardItem> items = await _session.getBulletinBoard(hideInactive: _hideInactive);

    if (mounted)
      setState(() {
        _items = items;
      });
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
            'Bacheca'
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "Cerca",
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: BulletinBoardSearchDelegate(),
                );
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text("Nascondi comunicazioni non attive"),
                trailing: Switch(
                  value: _hideInactive,
                  onChanged: (checked) async {
                    setState(() {
                      _items = null;

                      _hideInactive = checked;
                    });

                    final List<ClasseVivaBulletinBoardItem> items = await _session.getBulletinBoard(hideInactive: checked);

                    if (mounted)
                      setState(() {
                        _items = items;
                      });
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: BulletinBoardItemsListView(_items),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletinBoardItemsListView extends StatelessWidget {
  final List<ClasseVivaBulletinBoardItem> _items;

  BulletinBoardItemsListView(this._items);

  @override
  Widget build(BuildContext context) {
    return _items == null
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
        );
  }
}

class BulletinBoardSearchDelegate extends SearchDelegate
{
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
      primaryColor: Theme.of(context).appBarTheme.color,
    );

    return theme;
  }
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        tooltip: "Cancella",
        onPressed: () {
          query = "";
        },
      )
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    // TODO
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}