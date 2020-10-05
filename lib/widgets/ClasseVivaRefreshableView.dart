import 'dart:isolate';
import 'dart:ui';

import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ClasseVivaRefreshableView<T> extends StatefulWidget {
  final String title;

  final List<Widget> actions;

  final Widget head;

  final Stream<T> Function() stream;

  final Widget Function(T result) builder;

  final bool Function(T result) isResultEmpty;

  final String emptyResultMessage;

  ClasseVivaRefreshableView({
    @required this.title,
    this.actions,
    this.head,
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

  final ReceivePort _port = ReceivePort();

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');

    send.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();

    _handleRefresh();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];

      if (status == DownloadTaskStatus.complete) FlutterDownloader.open(taskId: id);
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: NotificationListener<ClasseVivaRefreshableViewRefreshNotification>(
        onNotification: (notification) {
          _handleRefresh();

          return true;
        },
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
                if (widget.head != null)
                  widget.head,

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
      ),
    );
  }
}

class ClasseVivaRefreshableViewRefreshNotification extends Notification
{}