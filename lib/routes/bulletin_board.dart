import 'package:classeviva_lite/miscellaneous/ClasseVivaSearchDelegate.dart';
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
  final ClasseViva _session = ClasseViva.current;

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
          title: Text("Bacheca"),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "Cerca",
              onPressed: () => showSearch(
                context: context,
                delegate: ClasseVivaSearchDelegate(
                  stream: (query) => ClasseViva.current.getBulletinBoard(
                    query: query,
                    hideInactive: false,
                  ),
                  builder: (item) => BulletinBoardListTile(item),
                ),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
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
                  child: _items.isNull
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

                          return BulletinBoardListTile(_items[index]);
                        },
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletinBoardListTile extends StatelessWidget {
  final ClasseVivaBulletinBoardItem item;

  BulletinBoardListTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.to(BulletinBoardItem(item)),
      trailing: Icon(
        item.isRead
          ? Icons.mail
          : Icons.drafts,
        color: item.isRead
          ? Colors.green
          : Colors.red,
      ),
      title: Text(item.titolo),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 5),
          Text(DateFormat.yMMMMd().format(item.eventDate)),
          SizedBox(height: 5),
          Text(item.typeDescription),
        ],
      )
    );
  }
}