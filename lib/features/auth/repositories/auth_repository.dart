import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xorr/features/auth/configs/client_config.dart';
import 'package:xorr/features/auth/models/user_model.dart';

class AuthRepository {
  final Client _client;

  new({required this._client});
  Future<({String? message, UserModel? user})> signup({
    required String email,
    required String password,
  }) async {
    try {
      final path = "/register";
      final response = await _client.post(
        path,
        body: {'email': email, 'password': password},
      );
      final data = jsonDecode(response.body);

      final String? message = data['message'];

      if (response.statusCode == 201) {
        final token = data['token'];
        if (token != null) {
          await _client.tokenConfig.saveToken(token);
        }
        final userData = data['user'] as Map<String, dynamic>?;
        final user = userData == null ? null : UserModel.fromMap(userData);

        return (message: message, user: user);
      } else {
        final String error =
            message ?? "Something went wrong, please try again.";
        debugPrint(error);

        return (message: error, user: null);
      }
    } catch (err) {
      debugPrint(err.toString());
      return (
        message: "$err Something went wrong, please try again.",
        user: null,
      );
    }
  }

  Future<({String? message, UserModel? user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final path = '/login';

      final response = await _client.post(
        path,
        body: {"password": password, "email": email},
      );
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _client.tokenConfig.saveToken(token);
      }
      final userData = data["user"] as Map<String, dynamic>?;
      final user = userData == null ? null : UserModel.fromMap(userData);
      final String? message = data["message"];

      if (response.statusCode == 200) {
        return (message: message, user: user);
      } else {
        return (message: message ?? "Something went wrong.", user: null);
      }
    } catch (err) {
      debugPrint(err.toString());

      return (message: err.toString(), user: null);
    }
  }

  Future<({String? message, UserModel? user})> me() async {
    try {
      final currentToken = await _client.tokenConfig.getToken();

      if (currentToken == null || currentToken == "") {
        return (message: "", user: null);
      }
      final path = '/me';

      final response = await _client.get(path);
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        await _client.tokenConfig.saveToken(token);
      }
      final userData = data["user"] as Map<String, dynamic>?;
      final user = userData == null ? null : UserModel.fromMap(userData);
      final String? message = data["message"];

      if (response.statusCode == 200) {
        return (message: message, user: user);
      } else {
        return (message: message ?? "Something went wrong.", user: null);
      }
    } catch (err) {
      debugPrint(err.toString());

      return (message: err.toString(), user: null);
    }
  }

  Future<void> logout() async {
    await _client.tokenConfig.clearToken();
  }

  Future<({String? message, bool? status})> updateUser({
    required UserModel data,
  }) async {
    String path = "/users";
    try {
      final response = await _client.put(path, body: data.toMap());
      final body = jsonDecode(response.body);
      final String? message = body['message'];
      if (response.statusCode == 200) {
        return (message: message, status: true);
      } else {
        return (
          message: message ?? somethingWentWrongPleaseTryAgain,
          status: false,
        );
      }
    } catch (err) {
      debugPrint(err.toString());
      return (message: somethingWentWrongPleaseTryAgain, status: null);
    }
  }

  var somethingWentWrongPleaseTryAgain =
      'Something went wrong, please try again.';
}
