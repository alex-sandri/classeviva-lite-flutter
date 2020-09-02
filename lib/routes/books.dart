import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  ClasseViva _session;

  List<ClasseVivaBook> _books;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaBook> books = await _session.getBooks();

    if (mounted)
      setState(() {
        _books = books;
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
            "Libri"
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
                  child: _books == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _books.isNotEmpty
                        ? _books.length
                        : 1,
                      itemBuilder: (context, index) {
                        if (_books.isEmpty)
                          return SelectableText(
                            "Non sono presenti libri",
                            textAlign: TextAlign.center,
                          );

                        final ClasseVivaBook book = _books[index];

                        return ListTile(
                          title: SelectableText(
                            book.title,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                book.description,
                              ),
                              SelectableText(
                                book.categories.toString(),
                              ),
                              SelectableText(
                                book.publisher,
                              ),
                              SelectableText(
                                book.isbn,
                              ),
                              SelectableText(
                                NumberFormat.currency(
                                  locale: "it-IT",
                                  name: "EUR",
                                  symbol: "€",
                                ).format(book.price),
                              ),
                              SelectableText(
                                book.mustBuy.toString(),
                              ),
                              SelectableText(
                                book.isInUse.toString(),
                              ),
                              SelectableText(
                                book.isSuggested.toString(),
                              ),
                            ],
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