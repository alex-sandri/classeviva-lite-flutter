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
                  icon: Icon(Icons.info),
                ),
                Tab(
                  text: "Compra",
                  icon: Icon(Icons.shopping_cart),
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
                        label: SelectableText(
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
                  DataTable(
                    headingRowHeight: 0,
                    columns: [
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("")),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(SelectableText("Editore")),
                          DataCell(SelectableText(book.publisher)),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("ISBN")),
                          DataCell(SelectableText(book.isbn)),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("Prezzo")),
                          DataCell(
                            SelectableText(
                              NumberFormat.currency(
                                locale: "it-IT",
                                name: "EUR",
                                symbol: "€",
                              ).format(book.price),
                            )
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("Da acquistare")),
                          DataCell(SelectableText(book.mustBuy.toString())),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("In uso")),
                          DataCell(SelectableText(book.isInUse.toString())),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("Consigliato")),
                          DataCell(SelectableText(book.isSuggested.toString())),
                        ],
                      ),
                    ],
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