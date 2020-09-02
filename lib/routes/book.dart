import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Book extends StatefulWidget {
  final ClasseVivaBook item;

  Book(this.item);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.item.title,
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Info",
                  icon: Icon(Icons.info_outline),
                ),
                Tab(
                  text: "TODO",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView(
                padding: EdgeInsets.all(8),
                children: [
                  Wrap(
                    spacing: 4,
                    children: widget.item.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                        ),
                      );
                    }).toList(),
                  ),
                  SelectableText(
                    widget.item.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SelectableText(
                    widget.item.description,
                  ),
                ],
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}