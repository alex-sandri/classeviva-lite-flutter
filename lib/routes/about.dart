import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Informazioni"
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text("Licenze"),
              onTap: () => showLicensePage(
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}