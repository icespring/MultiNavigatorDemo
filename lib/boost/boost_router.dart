// Copyright (c) Baidu.Inc 2020
//
// Created by yuanbingquan on 2020-02-13

import 'package:flutter/material.dart';

typedef Widget PageBuilder(String pageName, Map params, String uniqueId);

/// 每个Container容器的第一个Route应该是BoostPageRoute
class BoostPageRoute<T> extends MaterialPageRoute<T> {
  final String pageName;
  final String uniqueId;
  final Map params;
  final WidgetBuilder builder; // page
  final RouteSettings settings; // 路由设置

  BoostPageRoute({Key stubKey,
    this.pageName,
    this.params,
    this.uniqueId,
    this.builder,
    this.settings})
      : super(
    builder: (BuildContext context) => Stub(stubKey, builder(context)),
    settings: settings,
    maintainState: true,
    fullscreenDialog: false,);

  static BoostPageRoute<T> of<T>(BuildContext context) {
    final Route<T> route = ModalRoute.of(context);
    if (route != null && route is BoostPageRoute<T>) {
      return route;
    } else {
      return null;
    }
  }

}

@immutable
class Stub extends StatefulWidget {
  final Widget child;

  const Stub(Key key, this.child) : super(key: key);

  @override
  _StubState createState() => _StubState();
}

class _StubState extends State<Stub> {
  @override
  Widget build(BuildContext context) => widget.child;
}
