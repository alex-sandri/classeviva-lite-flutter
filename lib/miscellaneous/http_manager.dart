import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HttpManager
{
  static Future<HttpManagerResult> get({ String url, Map<String, String> headers}) async {
    http.Response response;
    bool isError = false;

    try
    {
      response = await http.get(url, headers: headers);
    }
    on SocketException catch (e)
    {
      isError = true;

      Get.rawSnackbar(message: "Nessuna connessione a Internet");
    }

    return HttpManagerResult(
      response: response,
      isError: isError,
    );
  }
}

class HttpManagerResult
{
  final http.Response response;
  final bool isError;

  HttpManagerResult({
    @required this.response,
    @required this.isError,
  });
}