// Copyright (c) Baidu.Inc 2020
//
// Created by yuanbingquan on 2020-02-14

import 'package:flutter/material.dart';
import 'package:ime_boost/boost/boost_channel.dart';
import 'package:ime_boost/boost/boost_container.dart';
import 'package:ime_boost/boost/boost_container_manager.dart';

/// 基于FlutterBoost修改而来

typedef Widget PageBuilder(String pageName, Map params, String uniqueId);


class ImeBoost {

  static final ImeBoost _instance = ImeBoost();

  static ImeBoost get singleton => _instance;

  BoostChannel _boostChannel = BoostChannel();
  BoostChannel get channel => _boostChannel;

  final GlobalKey<ContainerManagerState> containerManagerKey = GlobalKey<ContainerManagerState>();
  static ContainerManagerState get containerManager => _instance.containerManagerKey.currentState;


  /// 所有的一级页面的注册地，每一个相当于一个Container的根页面
  final Map<String, PageBuilder> _pageBuilders = <String, PageBuilder>{};


  /// 用于MaterialApp的builder中，用于接管当前的navigator
  static TransitionBuilder init({TransitionBuilder builder}) {
    return (BuildContext context, Widget child) {
      assert(child is Navigator);

      BoostContainerManager manager = BoostContainerManager(
        key: _instance.containerManagerKey,
        initialNavigator: child,
      );

      if (builder != null) {
        return builder(context, manager);
      }
      return manager;
    };
  }

  void registerPageBuilders(Map<String, PageBuilder> builders) {
    if (builders?.isNotEmpty == true) {
      _pageBuilders.addAll(builders);
    }

  }

  BoostContainerInfo _createContainerSettings(String name, Map params, String uniqueId) {

    Widget page;

    final BoostContainerInfo routeSettings = BoostContainerInfo(
        uniqueId: uniqueId,
        name: name,
        params: params,
        builder: (BuildContext ctx) {
          //Try to build a page using builder.
          if (_pageBuilders[name] != null) {
            page = _pageBuilders[name](name, params, uniqueId);
          }

          assert(page != null);

          return page;
        });

    return routeSettings;
  }

  /// 从Native打开页面, uniqueId从Native端生成
  void openPage({String name, Map<String, dynamic> param, String uniqueId}) {
    BoostContainerInfo info = _createContainerSettings(name, param, uniqueId);
    containerManager.showContainer(info);
  }

  /// 从Native端关闭页面
  void close(String uniqueId) {

  }


}