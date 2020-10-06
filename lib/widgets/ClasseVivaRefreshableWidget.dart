import 'package:flutter/material.dart';

class ClasseVivaRefreshableWidget<T> extends StatefulWidget {
  final Stream<T> Function() stream;

  final Widget Function(T result) builder;

  final bool Function(T result) isResultEmpty;

  final String emptyResultMessage;

  ClasseVivaRefreshableWidget({
    @required this.stream,
    @required this.builder,
    @required this.isResultEmpty,
    @required this.emptyResultMessage,
  });

  @override
  _ClasseVivaRefreshableWidgetState<T> createState() => _ClasseVivaRefreshableWidgetState<T>();
}

class _ClasseVivaRefreshableWidgetState<T> extends State<ClasseVivaRefreshableWidget> {
  T _result;

  Future<void> _handleRefresh() async {
    setState(() => _result = null);

    await for (final T result in widget.stream())
    {
      if (result == null) continue;

      if (mounted) setState(() => _result = result);
    }
  }

  @override
  void initState() {
    super.initState();

    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              backgroundColor: Theme.of(context).appBarTheme.color,
              child: _result == null
                ? LinearProgressIndicator()
                : ((widget as ClasseVivaRefreshableWidget<T>).isResultEmpty(_result)
                  ? LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: SelectableText(widget.emptyResultMessage),
                            ),
                          ),
                        ],
                      ),
                    )
                  : (widget as ClasseVivaRefreshableWidget<T>).builder(_result)
                ),
            ),
          ),
        ],
      ),
    );
  }
}