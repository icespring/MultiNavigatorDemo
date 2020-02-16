// Copyright (c) Baidu.Inc 2020
//
// Created by yuanbingquan on 2020-02-14

import 'package:flutter/services.dart';
import 'package:ime_boost/boost/ime_boost.dart';

/// 基于FlutterBoost修改而来，用于双端通信

typedef Future<dynamic> MethodHandler(MethodCall call);

class BoostChannel {
  final MethodChannel _methodChannel = MethodChannel("ime_boost");

  MethodHandler _methodHandler;

  BoostChannel() {
    _methodChannel.setMethodCallHandler((MethodCall call) {
      if (call.method == "pushContainer") {
        Map param = call.arguments;
        String pageName = param['pageName'];
        String uniqueId = param['uniqueId'];
        ImeBoost.singleton.openPage(name: pageName, uniqueId: uniqueId);
      }
      /// 暂时只返回空
      return Future.value();
    });
  }


}

