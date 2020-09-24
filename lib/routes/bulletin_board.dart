import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItem.dart';
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
    await for (final List<ClasseVivaBulletinBoardItem> items in _session.getBulletinBoard(hideInactive: _hideInactive))
    {
      if (items == null) continue;

      if (mounted)
        setState(() {
          _items = items;
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
            'Bacheca'
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "Cerca",
              onPressed: () => showSearch(
                context: context,
                delegate: BulletinBoardSearchDelegate(),
              ),
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
              SwitchListTile(
                title: Text("Nascondi comunicazioni non attive"),
                value: _hideInactive,
                onChanged: (checked) {
                  setState(() {
                    _items = null;

                    _hideInactive = checked;
                  });

                  _handleRefresh();
                },
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
          itemCount: _items.isNotEmpty
            ? _items.length
            : 1,
          itemBuilder: (context, index) {
            if (_items.isEmpty)
              return SelectableText(
                "Non sono presenti elementi in bacheca",
                textAlign: TextAlign.center,
              );

            final ClasseVivaBulletinBoardItem item = _items[index];

            return ListTile(
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
            );
          },
        );
  }
}

class BulletinBoardSearchDelegate extends SearchDelegate
{
  BulletinBoardSearchDelegate(): super(
    searchFieldStyle: TextStyle(
      color: Colors.white70,
    ),
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return theme.copyWith(
      primaryColor: theme.appBarTheme.color,
      textTheme: theme.primaryTextTheme.copyWith(
        headline6: theme.primaryTextTheme.headline6.copyWith(
          color: Colors.white,
        ),
      ),
    );
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
    return StreamBuilder<List<ClasseVivaBulletinBoardItem>>(
      stream: ClasseViva(ClasseViva.getCurrentSession()).getBulletinBoard(
        query: query,
        hideInactive: false,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Spinner();

        return BulletinBoardItemsListView(snapshot.data);
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}