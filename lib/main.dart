import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './screens/home_screen.dart';

void main() async {
  await dotenv.load(fileName: '.envrc');
  runApp(const NotionTestApp());
}

class NotionTestApp extends StatelessWidget {
  const NotionTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      //ターゲットデバイスの設定
      designSize: const Size(375, 812),
      //幅と高さの最小値に応じてテキストサイズを可変させるか
      minTextAdapt: true,
      //split screenに対応するかどうか？
      splitScreenMode: true,
      builder: (BuildContext context, Widget? widget) => MaterialApp(
        home: SafeArea(
          child: HomeScreen(),
        ),
      ) as Widget,
    );
  }
}
