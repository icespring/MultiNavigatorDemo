// Copyright (c) Baidu.Inc 2020
//
// Created by icespring on 2020-02-16

import 'package:flutter/material.dart';

class CirclePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circle'),
      ),
      body: Container(
        color: Colors.yellow,
        child: Center(
          child: RaisedButton(child: Text("Skin Shop Button"), onPressed: () => {},),
        ),
      ),
    );
  }
}
