import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _theme;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      final String theme = preferences.getString("theme") ?? "system";

      setState(() {
        _theme = theme;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Impostazioni'
          ),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text(
                "Tema",
              ),
              trailing: DropdownButton(
                value: _theme,
                items: [
                  DropdownMenuItem(
                    value: "system",
                    child: Text("Predefinito"),
                  ),
                  DropdownMenuItem(
                    value: "light",
                    child: Text("Chiaro"),
                  ),
                  DropdownMenuItem(
                    value: "dark",
                    child: Text("Scuro"),
                  ),
                ],
                onChanged: (value) async {
                  final SharedPreferences preferences = await SharedPreferences.getInstance();

                  await preferences.setString("theme", value);

                  setState(() {
                    _theme = value;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}