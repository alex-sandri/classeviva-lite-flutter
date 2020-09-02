import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Book extends StatefulWidget {
  final ClasseVivaBook book;

  Book(this.book);

  @override
  _BookState createState() => _BookState();
}

class _BookState extends State<Book> {
  @override
  Widget build(BuildContext context) {
    final ClasseVivaBook book = widget.book;

    return Material(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              book.title,
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
                    children: book.categories.map((category) {
                      return Chip(
                        label: Text(
                          category,
                        ),
                      );
                    }).toList(),
                  ),
                  SelectableText(
                    book.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SelectableText(
                    book.description,
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