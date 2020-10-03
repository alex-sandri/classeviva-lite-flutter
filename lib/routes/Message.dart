import 'package:classeviva_lite/models/ClasseVivaMessage.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final ClasseVivaMessage message;

  Message(this.message);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(message.subject),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Text(message.content),
        ),
      ),
    );
  }
}