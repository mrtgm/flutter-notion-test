import 'package:flutter/material.dart';
import 'package:flutter_notion_test/lib/notion_to_md.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  String markdownStrings = "";

  @override
  void initState() {
    super.initState();
    _article = fetchData();
  }

  Future<String> fetchData() async {
    NotionToMd notion = NotionToMd();
    List<Map<String, dynamic>> itemList =
        await notion.getBlocks(pageId: widget.pageId);
    dynamic result = await notion.blocksToMarkdown(blocks: itemList);
    return notion.toMarkdownString(mdBlocks: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DefaultTabController(
        length: 2,
        child: FutureBuilder(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(fontSize: 24.0),
                              ),
                              Text(widget.client),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 24.0,
                        ),
                        Icon(Icons.star_border, size: 32.0)
                      ],
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    TabBar(
                      labelColor: Colors.black,
                      tabs: [
                        Tab(text: "Content"),
                        Tab(text: "Flow"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        Markdown(
                          data: article,
                          imageBuilder: (uri, title, alt) {
                            return Center(
                              child: ExtendedImage.network(
                                uri.toString(),
                                height: ScreenUtil().setHeight(300),
                                cache: true,
                              ),
                            );
                          },
                        ),
                        Text("flow"),
                      ]),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
