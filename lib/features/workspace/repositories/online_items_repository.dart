import 'dart:convert';

import 'package:xorr/features/auth/configs/client_config.dart';
import 'package:xorr/features/workspace/models/online_item.dart';

class OnlineItemsRepository {
  final Client _client;

  OnlineItemsRepository({required Client client}) : _client = client;

  Future<List<OnlineItem>> getAll() async {
    try {
      final response = await _client.get('/notes');

      if (response.statusCode != 200) {
        throw Exception('Unable to load online items');
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Invalid online items response');
      }

      return data
          .map(
            (item) => OnlineItem.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (e) {
      print('Error loading online items: $e');
      return [];
    }
  }

  Future<OnlineItem> create({
    required String title,
    required String content,
  }) async {
    final response = await _client.post(
      '/notes',
      body: {
        'title': title,
        'content': content,
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Unable to create online item');
    }

    return OnlineItem.fromMap(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> update({
    required int id,
    required String title,
    required String content,
  }) async {
    final response = await _client.put(
      '/notes/$id',
      body: {
        'title': title,
        'content': content,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to save online item');
    }
  }

  Future<void> delete(int id) async {
    final response = await _client.delete('/notes/$id');

    if (response.statusCode != 204) {
      throw Exception('Unable to delete online item');
    }
  }
}
