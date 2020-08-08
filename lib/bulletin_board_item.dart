import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BulletinBoardItem extends StatefulWidget {
  final ClasseVivaBulletinBoardItem _item;

  BulletinBoardItem(this._item);

  @override
  _BulletinBoardItemState createState() => _BulletinBoardItemState();
}

class _BulletinBoardItemState extends State<BulletinBoardItem> {
  ClasseViva _session;

  ClasseVivaBulletinBoardItemDetails _item;

  Future<void> _handleRefresh() async {
    final ClasseVivaBulletinBoardItemDetails item = await _session.getBulletinBoardItemDetails(widget._item.id);

    if (mounted)
      setState(() {
        _item = item;
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
            widget._item.titolo,
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
                    child: _item == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ),
                      )
                    : ListView.builder(
                      itemCount: _item.attachments.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0)
                          return Padding(
                            padding: EdgeInsets.all(4),
                            child: SelectableText(
                              _item.description,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          );
                        
                        if (index == 1)
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                            child: SelectableText(
                              "Allegati",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 25,
                              ),
                            ),
                          );

                        if (_item.attachments.isEmpty)
                          return Padding(
                            padding: EdgeInsets.all(4),
                            child: SelectableText(
                              "Non sono presenti allegati",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          );

                        final ClasseVivaBulletinBoardItemDetailsAttachment attachment = _item.attachments[index - 2];

                        return Card(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              print(attachment.id);
                            },
                            title: Text(
                              attachment.name,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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