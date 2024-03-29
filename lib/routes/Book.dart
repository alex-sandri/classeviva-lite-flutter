import 'package:classeviva_lite/models/ClasseVivaBook.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Book extends StatelessWidget {
  final ClasseVivaBook book;

  Book(this.book);

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(book.title),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "Informazioni",
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
                        label: SelectableText(category),
                      );
                    }).toList(),
                  ),
                  SelectableText(
                    book.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 8),
                  SelectableText(book.description),
                  SizedBox(height: 8),
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
                          DataCell(SelectableText(book.mustBuy ? "Sì" : "No")),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("In uso")),
                          DataCell(SelectableText(book.isInUse ? "Sì" : "No")),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(SelectableText("Consigliato")),
                          DataCell(SelectableText(book.isSuggested ? "Sì" : "No")),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              ListView(
                children: [
                  ListTile(
                    title: Text("Amazon"),
                    onTap: () => _launchUrl("https://www.amazon.it/s?k=${book.isbn}"),
                  ),
                  ListTile(
                    title: Text("HOEPLI"),
                    onTap: () => _launchUrl("https://www.hoepli.it/cerca/libri.aspx?query=${book.isbn}"),
                  ),
                  ListTile(
                    title: Text("IBS"),
                    onTap: () => _launchUrl("https://www.ibs.it/search/?query=${book.isbn}"),
                  ),
                  ListTile(
                    title: Text("Libraccio"),
                    onTap: () => _launchUrl("https://www.libraccio.it/src/?xy=${book.isbn}"),
                  ),
                  ListTile(
                    title: Text("Libreria Scolastica"),
                    onTap: () => _launchUrl("https://www.libreriascolastica.it/ricerca/query/${book.isbn}"),
                  ),
                  ListTile(
                    title: Text("Mondadori Store"),
                    onTap: () => _launchUrl("https://www.mondadoristore.it/search/?g=${book.isbn}"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}