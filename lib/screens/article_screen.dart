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
  late Future<String> _article;
  late WebViewController _controller;
  String markdownStrings = "";

  @override
  void initState() {
    super.initState();
    _article = NotionRepository().getBlocks(pageId: widget.pageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder(
          future: _article,
          builder: (context, snapshot) {
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
                  Expanded(child: ListView(children: [Text(markdownStrings)])),
                  SizedBox(
                    height: 0,
                    child: WebView(
                      debuggingEnabled: true,
                      onWebViewCreated:
                          (WebViewController webViewController) async {
                        _controller = webViewController;
                        await _controller
                            .loadFlutterAsset('assets/web/dist/index.html');
                      },
                      onPageFinished: (String url) {
                        runScript(article);
                      },
                      javascriptMode: JavascriptMode.unrestricted,
                      javascriptChannels: Set.from([
                        JavascriptChannel(
                            name: "getData",
                            onMessageReceived: (JavascriptMessage result) {
                              getMarkdownStrings(result.message);
                            })
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void runScript(dynamic article) async {
    await _controller.runJavascript("RenderMd('${article}')");
  }

  void getMarkdownStrings(String str) {
    setState(() {
      markdownStrings = str;
    });
  }
}
