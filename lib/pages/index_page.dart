import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'photograph_page.dart';
import 'home_page.dart';


class Indexpage extends StatefulWidget {
  @override
  _IndexpageState createState() => _IndexpageState();
}

class _IndexpageState extends State<Indexpage> {
  final List<BottomNavigationBarItem> bottomtabs=[
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home),label: "首页"),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.photo),label: "上传图片/视频"),
  ];
  final List taBodies=[HomePage(),PhotographPage()];

  int currentIndex=0;
  var currentPage;

  @override
  void initState() {
    // TODO: implement initState
    currentPage=taBodies[currentIndex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(147, 24, 24, 1.0),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        items: bottomtabs,
        onTap: (index){
          setState(() {
            currentIndex=index;
            currentPage=taBodies[currentIndex];
          });
        },
      ),
      body: currentPage,
    );

  }
}
