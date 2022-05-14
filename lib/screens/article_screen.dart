import 'package:flutter/material.dart';
import 'package:flutter_notion_test/notion_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _futureArticle = NotionRepository().getBlocks(pageId: widget.pageId);
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
            Text("Data"),
          ],
        ),
      ),
    );
  }
}
