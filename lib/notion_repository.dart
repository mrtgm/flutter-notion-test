import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import './md.dart' as md;
import './models/item_model.dart';

class MdBlock {
  String parent;
  List<MdBlock> children;

  MdBlock({required this.parent, required this.children});

  @override
  String toString() {
    return "{parent: $parent, children: ${children.toString()}}";
  }
}

class NotionRepository {
  static const String _baseUrl = 'https://api.notion.com/v1/';

  final http.Client _client;
  final Map<String, String> reqHeader = {
    HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['NOTION_API_KEY']}',
    'Notion-Version': '2022-02-22',
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

  Future<List<Map<String, dynamic>>> getBlocks({required String pageId}) async {
    try {
      final url = '${_baseUrl}blocks/$pageId/children?page_size=100';
      final response = await _client.get(
        Uri.parse(url),
        headers: reqHeader,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return [...data['results']];
      } else {
        throw 'Something went wrong!';
      }
    } catch (_) {
      throw 'Something went wrong!';
    }
  }

  Future blocksToMarkdown(
      {List<Map<String, dynamic>>? blocks, List<MdBlock>? mdBlocks}) async {
    mdBlocks = [];
    if (blocks == null) return mdBlocks;

    try {
      for (int i = 0; i < blocks.length; i++) {
        dynamic block = blocks[i];

        if (block.containsKey("has_children") &&
            block["has_children"] &&
            block["type"] != "column_list") {
          List<Map<String, dynamic>> child_blocks =
              await getBlocks(pageId: block["id"]);
          mdBlocks.add(
            MdBlock(parent: await blockToMarkdown(block), children: []),
          );

          await blocksToMarkdown(
              blocks: child_blocks,
              mdBlocks: mdBlocks[mdBlocks.length - 1].children);
          continue;
        }
        String tmp = await blockToMarkdown(block);

        mdBlocks.add(
          MdBlock(parent: tmp, children: []),
        );
      }
    } catch (e) {
      throw e;
    }

    for (dynamic mdBlock in mdBlocks) {
      print(mdBlock.toString());
    }

    return mdBlocks;
  }

  String toMarkdownString(
      {required List<MdBlock> mdBlocks, int nestingLevel = 0}) {
    String mdString = "";
    mdBlocks.forEach((mdBlock) {
      if (mdBlock.parent != null) {
        mdString += "${md.addTabSpace(mdBlock.parent, nestingLevel)}";
      }
      if (mdBlock.children != null && mdBlock.children.length > 0) {
        mdString += toMarkdownString(
            mdBlocks: mdBlock.children, nestingLevel: nestingLevel + 1);
      }
    });
    return mdString;
  }

  Future<String> blockToMarkdown(Map<String, dynamic> block) async {
    String parsedData = "";

    if (!(block.containsKey("type"))) return "";

    var type = block["type"];

    try {
      switch (type) {
        case "image":
          var blockContent = block["image"];
          String imageCaptionPlain = blockContent['caption'].map((item) {
            return item["plain_text"];
          }).join("");
          String imageType = blockContent["type"];

          if (imageType == 'external') {
            return md.image(imageCaptionPlain, blockContent["external"]["url"]);
          }
          if (imageType == 'file') {
            return md.image(imageCaptionPlain, blockContent["file"]["url"]);
          }
          break;
        //
        case "divider":
          return md.divider();

        case "equation":
          return md.codeBlock(block['equation']['expression'], "");

        case "video":
        case "file":
        case "pdf":
          break;

        case "bookmark":
        case "embed":
        case "link_preview":
          break;

        case "table":
          break;

        case "column_list":
          break;

        case "column":
          break;

        default:
          List<dynamic> blockContent = block[type] is Map
              ? block[type]["text"] ?? block[type]["rich_text"] ?? []
              : [];

          blockContent.forEach((content) {
            dynamic annotations = content["annotations"];
            String plain_text = content["plain_text"];

            plain_text = annotatePlainText(plain_text, annotations);

            if (content["href"] != null) {
              plain_text = md.link(plain_text, content["href"]);
            }
            parsedData += plain_text;
          });
          break;
      }

      switch (type) {
        case "code":
          parsedData = md.codeBlock(parsedData, block[type]["language"]);
          break;

        case "heading_1":
          parsedData = md.heading1(parsedData);
          break;

        case "heading_2":
          parsedData = md.heading2(parsedData);
          break;

        case "heading_3":
          parsedData = md.heading3(parsedData);
          break;

        case "quote":
          parsedData = md.quote(parsedData);
          break;

        case "callout":
          parsedData = md.callout(parsedData, block[type]["icon"]);
          break;

        case "bulleted_list_item":
        case "numbered_list_item":
          parsedData = md.bullet(parsedData);
          break;

        case "to_do":
          parsedData = md.todo(parsedData, block["to_do"]["checked"]);
          break;
      }
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }

    return parsedData;
  }

  String annotatePlainText(String text, annotations) {
    if (text.contains(RegExp(r'^\s*$'))) {
      return text;
    }

    final String leading_space =
        RegExp(r'^(\s*)').firstMatch(text)?.group(0) ?? "";
    final String trailing_space =
        RegExp(r'(\s*)$').firstMatch(text)?.group(0) ?? "";

    text.trim();

    if (text != "") {
      if (annotations["code"]) text = md.inlineCode(text);
      if (annotations["bold"]) text = md.bold(text);
      if (annotations["italic"]) text = md.italic(text);
      if (annotations["strikethrough"]) text = md.strikethrough(text);
      if (annotations["underline"]) text = md.underline(text);
    }

    return leading_space + text + trailing_space;
  }
}
