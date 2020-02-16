// Copyright (c) Baidu.Inc 2020
//
// Created by yuanbingquan on 2020-02-14


import 'package:flutter/material.dart';
import 'package:ime_boost/boost/boost_router.dart';

/// 参考Flutter Boost实现的一个容器
/// 它是一个Navigator，有自己的push和pop结构

class BoostContainer extends Navigator {
  /// 每个Container的基础信息
  final BoostContainerInfo info;

  @override
  BoostContainerState createState() {
    return BoostContainerState();
  }

  const BoostContainer({@required GlobalKey<BoostContainerState> key,
    this.info = const BoostContainerInfo(),
    String initRoute,
    RouteFactory onGenerateRoute,
    RouteFactory onUnknownRoute,
    List<NavigatorObserver> observers,
  }) : super(
      key: key,
      initialRoute: initRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      observers: observers
  );

  factory BoostContainer.fromNavigator(Navigator navigator) {
    return BoostContainer(
      key: GlobalKey<BoostContainerState>(),
      initRoute: navigator.initialRoute,
      onGenerateRoute: navigator.onGenerateRoute,
      onUnknownRoute: navigator.onUnknownRoute,
      observers: navigator.observers,
    );
  }

  factory BoostContainer.obtain(Navigator navigator, BoostContainerInfo info) {
    return BoostContainer(
      key: GlobalKey<BoostContainerState>(),
      info: info,
      onGenerateRoute: (RouteSettings routeSettings) {
        if (routeSettings.name == "/") {
          return BoostPageRoute<dynamic>(
            pageName: info.name,
            uniqueId: info.uniqueId,
            params: info.params,
            builder: info.builder,
            settings: routeSettings
          );
        }
        return navigator.onGenerateRoute(routeSettings);
      },
      onUnknownRoute: navigator.onUnknownRoute,
      observers: <NavigatorObserver>[],
    );
  }

  /// 外部通过获取，获取当前的Container
  static BoostContainerState of(BuildContext context) {
    final BoostContainerState state = context.findAncestorStateOfType<BoostContainerState>();
    assert(state != null, "cannot find state of BoostContainerState, maybe not in BoostContainer");
    return state;
  }

  String debugInfo() => "{uniqueId=${info.uniqueId}, name=${info.name}";

}

/// BoostContainerState职责 维护当前的页面信息，并完成路由的push pop等操作
class BoostContainerState extends NavigatorState {
  String get uniqueId => widget.info.uniqueId;

  String get name => widget.info.name;

  Map get params => widget.info.params;

  BoostContainer get widget => super.widget;

  BoostContainerInfo get info => widget.info;

  /// navigator的history
  final List<Route<dynamic>> history = <Route<dynamic>>[];

  VoidCallback backPressHandler;

  @override
  void initState() {
    super.initState();
    backPressHandler = () => {};
  }


  @override
  void dispose() {
    backPressHandler = null;
    history.clear();
    super.dispose();
  }

  @override
  Future<bool> maybePop<T extends Object>([T result]) async {
//    super.maybePop(result);
    /// 这里改写了原始的逻辑，因为接管了pop方案，对于bubble类型的，由pop方法通知系统进行关闭
    var route = history.last;
    final RoutePopDisposition disposition = await route.willPop();
    if (mounted) {
      switch (disposition) {
        case RoutePopDisposition.pop:
        case RoutePopDisposition.bubble:
          pop(result);
          return true;
          break;
        case RoutePopDisposition.doNotPop:
          return false;
          break;
      }
    }
    return false;
  }

  @override
  bool pop<T extends Object>([T result]) {
    if (history.length > 1) {
      history.removeLast();
    }

    if (canPop()) {
      return super.pop(result);
    }

    /// todo:处理最后一个页面的关闭，需要通知native端，交给native端来处理
    /// clostLast
    return false;
  }

  @override
  Future<T> push<T extends Object>(Route<T> route) {
//    return super.push(route);
    history.add(route);

    return super.push(route);

  }


}


class BoostContainerInfo {
  /// 创建容器时的唯一标识，比如使用时间戳
  final String uniqueId;

  /// 本容器的唯一标识，如skin / xxDiy / personalCenter etc..
  final String name;

  /// 初始化信息
  final Map params;

  /// 用于找到当前页面
  final WidgetBuilder builder;

  const BoostContainerInfo({
    this.uniqueId = "init", this.name = "init", this.params, this.builder});
}