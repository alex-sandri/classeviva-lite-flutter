import 'package:classeviva_lite/widgets/sessions_list.dart';
import 'package:flutter/material.dart';

class ManageAccounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gestisci account"),
        ),
        body: SessionsList(),
      ),
    );
  }
}