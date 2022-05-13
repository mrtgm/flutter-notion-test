import 'package:flutter/material.dart';
import '../notion_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    NotionRepository().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
