import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

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
              onTap: () async {
                showLicensePage(
                  context: context,
                  applicationVersion: (await PackageInfo.fromPlatform()).version,
                  applicationIcon: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: Image.asset(
                      "assets/icon/icon.png",
                      height: 50,
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}