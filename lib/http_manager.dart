import 'dart:io';

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