import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './screens/home_screen.dart';

void main() async {
  await dotenv.load(fileName: '.envrc');
  runApp(const NotionTestApp());
}

class NotionTestApp extends StatelessWidget {
  const NotionTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
      child: HomeScreen(),
    ));
  }
}
