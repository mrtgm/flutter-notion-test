import 'dart:convert';
import 'dart:io';

import './md.dart' as md;
import 'package:flutter_notion_test/notion/client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_notion_test/models/mdblock_model.dart';
import 'package:flutter_notion_test/models/item_model.dart';

class NotionToMd {
  void dispose() {
    Client.client.close();
  }

  Future<List<Item>> getItems() async {
    try {
      final url =
          '${Client.baseUrl}databases/${dotenv.env['NOTION_DATABASE_ID']}/query';
      final response = await Client.client.post(
        Uri.parse(url),
        headers: Client.reqHeader,
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
      final url = '${Client.baseUrl}blocks/$pageId/children?page_size=100';
      final response = await Client.client.get(
        Uri.parse(url),
        headers: Client.reqHeader,
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

  List<MdBlock> mdBlocks = [];
  Future blocksToMarkdown(
      {required List<Map<String, dynamic>>? blocks,
      List<MdBlock>? mdBlock,
      bool? hasChild}) async {
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

          int l = mdBlocks.length;

          await blocksToMarkdown(
              blocks: child_blocks,
              mdBlock: mdBlocks[l - 1].children,
              hasChild: true);

          continue;
        }
        String tmp = await blockToMarkdown(block);

        if (hasChild != null) {
          mdBlock?.add(
            MdBlock(parent: tmp, children: []),
          );
          return;
        }
        mdBlocks.add(
          MdBlock(parent: tmp, children: []),
        );
      }
    } catch (e) {
      print(e);
    }

    // for (dynamic mdBlock in mdBlocks) {
    //   print(mdBlock.toString());
    // }

    return mdBlocks;
  }

  int nestingLevel = 0;
  String toMarkdownString(
      {required List<MdBlock> mdBlocks, int? nesting, bool? hasChild}) {
    String mdString = "";
    mdBlocks.forEach((mdBlock) {
      if (mdBlock.parent != null) {
        if (hasChild != null && nesting != null) {
          mdString += '\n${md.addTabSpace(text: mdBlock.parent, n: nesting)}\n';
          return;
        }
        mdString +=
            '\n${md.addTabSpace(text: mdBlock.parent, n: nestingLevel)}\n';
      }
      if (mdBlock.children.isNotEmpty) {
        mdString += toMarkdownString(
            mdBlocks: mdBlock.children, nesting: 1, hasChild: true);
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
