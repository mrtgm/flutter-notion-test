import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import './models/item_model.dart';

class NotionRepository {
  static const String _baseUrl = 'https://api.notion.com/v1/';

  final http.Client _client;
  final Map<String, String> reqHeader = {
    HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['NOTION_API_KEY']}',
    'Notion-Version': '2021-05-13',
  };

  NotionRepository({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  Future<List<Item>> getItems() async {
    try {
      final url =
          '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_ID']}/query';
      final response = await _client.post(
        Uri.parse(url),
        headers: reqHeader,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List).map((e) => Item.fromMap(e)).toList();
      } else {
        throw 'Something went wrong!';
      }
    } catch (_) {
      throw 'Something went wrong!';
    }
  }

  Future<void> getBlocks({required String pageId}) async {
    try {
      final url = '${_baseUrl}blocks/${pageId}/children?page_size=100';

      final response = await _client.get(
        Uri.parse(url),
        headers: reqHeader,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print(data);
      } else {
        throw 'Something went wrong!';
      }
    } catch (_) {
      throw 'Something went wrong!';
    }
  }
}
