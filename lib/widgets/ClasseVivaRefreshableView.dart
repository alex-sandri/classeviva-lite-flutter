import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';

class ClasseVivaRefreshableView<T> extends StatefulWidget {
  final String title;

  final List<Widget> actions;

  final Stream<T> Function() stream;

  final Widget Function(T result) builder;

  final bool Function(T result) isResultEmpty;

  final String emptyResultMessage;

  ClasseVivaRefreshableView({
    @required this.title,
    this.actions,
    @required this.stream,
    @required this.builder,
    @required this.isResultEmpty,
    @required this.emptyResultMessage,
  });

  @override
  _ClasseVivaRefreshableViewState<T> createState() => _ClasseVivaRefreshableViewState<T>();
}

class _ClasseVivaRefreshableViewState<T> extends State<ClasseVivaRefreshableView> {
  T _result;

  Future<void> _handleRefresh() async {
    await for (final T result in widget.stream())
    {
      if (result == null) continue;

      if (mounted) setState(() => _result = result);
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
          title: Text(widget.title),
          actions: widget.actions,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _result == null
                    ? Spinner()
                    : ((widget as ClasseVivaRefreshableView<T>).isResultEmpty(_result)
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
                      : (widget as ClasseVivaRefreshableView<T>).builder(_result)
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