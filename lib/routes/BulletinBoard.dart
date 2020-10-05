import 'package:classeviva_lite/miscellaneous/ClasseVivaSearchDelegate.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItem.dart';
import 'package:classeviva_lite/routes/BulletinBoardItem.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BulletinBoard extends StatefulWidget {
  @override
  _BulletinBoardState createState() => _BulletinBoardState();
}

class _BulletinBoardState extends State<BulletinBoard> {
  bool _hideInactive = true;

  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaBulletinBoardItem>>(
      title: "Bacheca",
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
        ),
      ],
      head: SwitchListTile(
        title: Text("Nascondi comunicazioni non attive"),
        value: _hideInactive,
        onChanged: (checked) => setState(() => _hideInactive = checked),
      ),
      stream: () => ClasseViva.current.getBulletinBoard(hideInactive: _hideInactive),
      builder: (items) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) =>  BulletinBoardListTile(items[index]),
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti elementi in bacheca",
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