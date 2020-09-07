import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HttpManager
{
  static Future<http.Response> get({ String url, Map<String, String> headers}) async {
    http.Response response;

    try
    {
      response = await http.get(url, headers: headers);
    }
    on SocketException catch (e)
    {
      Get.rawSnackbar(message: "Errore");
    }

    return response;
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