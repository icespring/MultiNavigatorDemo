// Copyright (c) Baidu.Inc 2020
//
// Created by icespring on 2020-02-16

import 'package:flutter/material.dart';

class SkinShopMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SkinShop'),
      ),
      body: Container(
        color: Colors.green,
        child: Center(
          child: RaisedButton(child: Text("Skin Shop Button"), onPressed: () => {},),
        ),
      ),
    );
  }
}
