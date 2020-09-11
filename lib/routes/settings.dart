import 'package:classeviva_lite/miscellaneous/authentication_manager.dart';
import 'package:classeviva_lite/miscellaneous/cache_manager.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:flutter/material.dart';
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
                    if (await AuthenticationManager.authenticate())
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
            Builder(
              builder: (context) => ListTile(
                title: Text("Svuota cache"),
                onTap: () async {
                  await CacheManager.empty();

                  Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text("Cache svuotata")));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}