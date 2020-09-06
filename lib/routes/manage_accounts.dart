import 'package:classeviva_lite/widgets/sessions_list.dart';
import 'package:flutter/material.dart';

class ManageAccounts extends StatefulWidget {
  @override
  _ManageAccountsState createState() => _ManageAccountsState();
}

class _ManageAccountsState extends State<ManageAccounts> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Gestisci account"
          ),
        ),
        body: SessionsList(),
      ),
    );
  }
}