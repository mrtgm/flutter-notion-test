import 'package:flutter/material.dart';
import 'package:flutter_notion_test/notion_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ArticleScreen extends StatefulWidget {
  ArticleScreen(
      {required this.title, required this.client, required this.pageId});
  final String title;
  final String client;
  final String pageId;

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late Future<String> _article;
  late WebViewController _controller;
  String markdownStrings = "";

  @override
  void initState() {
    super.initState();
    _article = fetchData();
  }

  Future<String> fetchData() async {
    NotionRepository notion = NotionRepository();
    List<Map<String, dynamic>> itemList =
        await notion.getBlocks(pageId: widget.pageId);
    dynamic result = await notion.blocksToMarkdown(blocks: itemList);
    return notion.toMarkdownString(mdBlocks: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder(
          future: _article,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final article = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 24.0),
                      ),
                      Text(widget.client),
                    ],
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Expanded(
                    child: Markdown(
                      data: article,
                      imageBuilder: (uri, title, alt) {
                        return Center(
                          child: Image.network(
                            uri.toString(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
