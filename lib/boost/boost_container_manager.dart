// Copyright (c) Baidu.Inc 2020
//
// Created by yuanbingquan on 2020-02-13

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:ime_boost/boost/ime_boost.dart';

import 'boost_container.dart';

/// 全局只有一个，用于Container的统一管理
class BoostContainerManager extends StatefulWidget {

  final Navigator initialNavigator;

  const BoostContainerManager({
    GlobalKey<ContainerManagerState> key,
    @required this.initialNavigator,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ContainerManagerState();
  }

  static ContainerManagerState of(BuildContext context) {
    final ContainerManagerState manager = context.findAncestorStateOfType<ContainerManagerState>();
    assert(manager != null, 'not in ime boost');
    return manager;
  }
}

/// 重点维护
class ContainerManagerState extends State<BoostContainerManager> {

  // 维护了一个OverLay，这个OverLay是一个类似Stack的结构，提供onStage和OffStage
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  // 维护了一个Offstage列表
  final List<BoostContainer> _offstage = <BoostContainer>[];

  List<BoostContainer> get offstage => _offstage;

  BoostContainer _onstage;

  BoostContainer get onstage => _onstage;

  BoostContainerState get onstageContainer => _stateOf(_onstage);

  // 至少有一个onstage
  int get containerNumbers => _offstage.length + 1;

  String _lastShownContainer;

// 继承自OverLayEntry，是一个持有entry的class
  List<_ContainerOverlayEntry> _leastEntries;

  @override
  void initState() {
    super.initState();

    assert(widget.initialNavigator != null);

    // 保证至少有一个在onstage, 即使这个container只是个空壳
    _onstage = BoostContainer.fromNavigator(widget.initialNavigator);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    // 不需要调用super.setState()
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      /// 如果正在处理build、layout、paint
      /// 则在下一帧进行处理
      SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
        _refreshOverlayEntries();
      });
    } else {
      _refreshOverlayEntries();
    }

    fn();
  }

  void _refreshOverlayEntries() {
    final OverlayState overlayState = _overlayKey.currentState;
    if (overlayState == null) {
      return;
    }

    if (_leastEntries != null && _leastEntries.isNotEmpty) {
      for (_ContainerOverlayEntry entry in _leastEntries) {
        entry.remove();
      }
    }
    final List<BoostContainer> containers = <BoostContainer>[];
    containers.addAll(_offstage);

    assert(_onstage != null, 'Should have a least one BoostContainer');
    containers.add(_onstage);

    _leastEntries = containers.map<_ContainerOverlayEntry>(
            (container) => _ContainerOverlayEntry(container)
    ).toList(growable: false);

    /// 这里会调用setstate，所以不需要显示调用
    overlayState.insertAll(_leastEntries);

    void updateFocus() {
      final BoostContainerState now = _stateOf(_onstage);
      if (now != null) {
        FocusScope.of(context).setFirstFocus(now.focusScopeNode);
      }
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      final String now = _onstage.info.uniqueId;
      if (_lastShownContainer != now) {
        final String old = _lastShownContainer;
        _lastShownContainer = now;
        _notifyContainerChanged(old, now);
      }
      updateFocus();
    });
  }

  /// 如果Container已经存在，直接切换到前台显示，如果不存在，则创建一个用于显示
  void showContainer(BoostContainerInfo info) {
    if (info.uniqueId == onstage.info.uniqueId) {
      _notifyContainerChanged(null, info.uniqueId);
      return;
    }

    // 查找当前所需要的页面在offstage里是否存在
    final int index = _offstage.indexWhere((BoostContainer container) => container.info.uniqueId == info.uniqueId);
    if (index > -1) {
      _offstage.add(onstage);
      _onstage = offstage.removeAt(index);
      setState(() {});
    } else {
      _offstage.add(onstage);
      _onstage = BoostContainer.obtain(widget.initialNavigator, info);
      setState(() {});
    }

  }

  /// 如果当前页面在前台，尝试替换下面的
  void removeContainer(String uniqueId) {
    if (_onstage.info.uniqueId == uniqueId) {
      assert (_offstage.isNotEmpty, "offstage should not be empty");
      // 当前onstage的dispose会被调用
      final BoostContainer old = _onstage;
      _onstage = _offstage.removeLast();
      setState(() {});
    } else {
      final BoostContainer container = _offstage.firstWhere(
              (BoostContainer container) => container.info.uniqueId == uniqueId,
          orElse: () => null);

      if (container != null) {
        _offstage.remove(container);
        // 调用setState对页面无影响，但是会调用container的dispose
        setState(() {});
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayKey,
      initialEntries: const <OverlayEntry>[],
    );
  }

  BoostContainerState _stateOf(BoostContainer container) {
    if (container == null || container.key == null) {
      return null;
    }
    assert (container.key is GlobalKey<BoostContainerState>, "wrong container!!!");

    return (container.key as GlobalKey<BoostContainerState>).currentState;
  }

  void _notifyContainerChanged(String old, String now) {
    Map<String, dynamic> properties = new Map<String, dynamic>();
    properties['newName'] = now;
    properties['oldName'] = old;

//    ImeBoost.singleton.channel.invoke
   // todo: 需要通知native层，已切换Container
  }


}

/// 这是一个自定义的OverLay，由于这个OverLay承载的是Container,因此opaque和maintainState都需要为true
class _ContainerOverlayEntry extends OverlayEntry {
  bool _removed = false;

  _ContainerOverlayEntry(BoostContainer container)
      : super(
      builder: (BuildContext ctx) => container,
      opaque: true,
      maintainState: true);

  @override
  void remove() {
    assert(!_removed);

    if (_removed) {
      return;
    }

    _removed = true;
    super.remove();
  }
}

