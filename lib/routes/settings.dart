import 'package:classeviva_lite/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Impostazioni'
          ),
        ),
        body: FutureBuilder(
          future: Provider.of<ThemeManager>(context).themeMode,
          builder: (context, themeMode) {
            if (!themeMode.hasData) return Container();

            return ListView(
              children: [
                ListTile(
                  title: Text(
                    "Tema",
                  ),
                  trailing: DropdownButton(
                    value: themeMode.data.toString().split(".").last,
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
                )
              ],
            );
          },
        ),
      ),
    );
  }
}