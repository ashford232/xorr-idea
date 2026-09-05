import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xorr/features/auth/configs/token_config.dart';

class Client {
  final TokenConfig tokenConfig;
  static const String baseUrl = 'http://10.50.106.68:8080';
  static const _timeout = Duration(seconds: 10);
  Client({required this.tokenConfig});

  Future<Map<String, String>> _headers() async {
    final token = await tokenConfig.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    try {
      return await http
          .get(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(_timeout);
    } on TimeoutException catch (err) {
      debugPrint(err.toString());
      throw Exception("Something went wrong, please try again");
    }
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    try {
      return await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
    } on TimeoutException catch (err) {
      debugPrint(err.toString());
      throw Exception("Something went wrong, please try again");
    }
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    try{
    return await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    }on TimeoutException catch (err) {
      debugPrint(err.toString());
      throw Exception("Something went wrong, please try again");
    }
  }

  Future<http.Response> delete(String path) async {
    try{
    return await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(_timeout);
    }on TimeoutException catch (err) {
      debugPrint(err.toString());
      throw Exception("Something went wrong, please try again");
    }
  }
}
