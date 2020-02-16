import 'package:flutter/material.dart';
import 'package:ime_boost/boost/ime_boost.dart';
import 'package:ime_boost/circle_page.dart';
import 'package:ime_boost/skin_shop_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    ImeBoost.singleton.registerPageBuilders(
      {
        "skin_shop": (pageName, params, _) => SkinShopMainPage(),
        "circle": (pageName, params, _) => CirclePage(),
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: ImeBoost.init(),
      home: Container(color: Colors.blueGrey,),
    );
  }

}