import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Client {
  static const String baseUrl = 'https://api.notion.com/v1/';

  static final http.Client client = http.Client();
  static final Map<String, String> reqHeader = {
    HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['NOTION_API_KEY']}',
    'Notion-Version': '2022-02-22',
  };
}
