import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Impostazioni'
          ),
          elevation: 0,
        ),
        body: Container(
          
        ),
      ),
    );
  }
}