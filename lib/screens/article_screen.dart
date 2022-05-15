import 'package:flutter/material.dart';
import 'package:flutter_notion_test/notion_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  Future<void>? _futureArticle;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
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
              child: WebView(
                debuggingEnabled: true,
                onWebViewCreated: (WebViewController webViewController) async {
                  _controller = webViewController;
                  await _controller
                      .loadFlutterAsset('assets/web/dist/index.html');
                },
                onPageFinished: (String url) {
                  print(widget.pageId);
                  _controller.runJavascript("RenderMd(${widget.pageId})");
                },
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
