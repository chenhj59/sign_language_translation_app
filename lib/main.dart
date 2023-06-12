import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'services/service_locator.dart';
import 'pages/index_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*
    ScreenUtilInit 是 flutter_screenutil 库的一部分，
    它是一个用于初始化屏幕尺寸的 widget。它通常用于在应用程序中设置基准屏幕尺寸，以便您可以按比例调整 UI 元素的大小和位置。
    */
    return ScreenUtilInit(
        builder: (_,child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
              home: Indexpage(),
            ));
  }
}
