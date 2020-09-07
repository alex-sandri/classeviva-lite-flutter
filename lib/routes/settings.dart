import 'package:classeviva_lite/authentication_manager.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
              title: Text("Tema"),
              trailing: DropdownButton(
                value: Provider.of<ThemeManager>(context).themeMode.toString().split(".").last,
                items: [
                  DropdownMenuItem(
                    value: "system",
                    child: Text("Predefinito di sistema"),
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
                onChanged: (value) {
                  Provider.of<ThemeManager>(context, listen: false).setTheme(value);
                },
              ),
            ),
            ListTile(
              title: Text("Blocco app"),
              trailing: Switch(
                onChanged: (checked) async {
                  try
                  {
                    bool didAuthenticate = await AuthenticationManager.authenticate();

                    if (didAuthenticate)
                    {
                      AuthenticationManager.isAuthenticationEnabled = checked;

                      setState(() {});
                    }
                  }
                  catch (e)
                  {
                    print(e);
                  }
                },
                value: AuthenticationManager.isAuthenticationEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}