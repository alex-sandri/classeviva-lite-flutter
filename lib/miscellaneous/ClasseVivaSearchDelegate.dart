import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';

class ClasseVivaSearchDelegate<T> extends SearchDelegate
{
  final Stream<List<T>> Function(String) stream;

  final Widget Function(T) builder;

  final ListView Function(List<T>) listBuilder;

  ClasseVivaSearchDelegate({
    @required this.stream,
    this.builder,
    this.listBuilder
  }):
    assert(builder != null || listBuilder != null),
    super(searchFieldStyle: TextStyle(color: Colors.white70));

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
        onPressed: () => query = "",
      ),
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) => BackButton(onPressed: Navigator.of(context).pop);
  
  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Spinner();

        final List<T> items = snapshot.data;

        if (listBuilder != null) return listBuilder(items);

        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.isNotEmpty
            ? items.length
            : 1,
          itemBuilder: (context, index) {
            if (items.isEmpty)
              return SelectableText(
                "Nessun risultato",
                textAlign: TextAlign.center,
              );

            final T item = items[index];

            return builder(item);
          },
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) => ListView();
}