import 'dart:collection';

import 'package:flutter/rendering.dart';

/// 具有子列表的渲染对象的通用 Mixin。
///
/// 为渲染对象子类提供一个子模型，将子项存储在 HashMap (具体为 SplayTreeMap) 中。
/// 使用 SplayTreeMap 是为了保持键（索引）的顺序。
mixin TileContainerRenderObjectMixin<ChildType extends RenderObject, ParentDataType extends ParentData>
    on RenderObject {
  final SplayTreeMap<int, ChildType> _childRenderObjects = SplayTreeMap<int, ChildType>();

  /// 子项的数量。
  int get childCount => _childRenderObjects.length;

  /// 返回所有子项的迭代器。
  /// 注意：返回的顺序是按索引从小到大的顺序（绘制顺序）。
  Iterable<ChildType> get children => _childRenderObjects.values;

  /// 返回所有子项索引的迭代器。
  Iterable<int> get indices => _childRenderObjects.keys;

  /// 检查给定的渲染对象是否具有正确的 [runtimeType] 以成为此渲染对象的子项。
  ///
  /// 如果禁用断言，则不执行任何操作。
  ///
  /// 始终返回 true。
  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw FlutterError('一个 $runtimeType 期望一个 $ChildType 类型的子项，但接收到了一个 '
            '${child.runtimeType} 类型的子项。\n'
            'RenderObjects 期望特定类型的子项，因为它们在布局和绘制期间 '
            '与其子项协调。例如，RenderSliver 不能是 RenderBox 的子项，因为 '
            'RenderSliver 不理解 RenderBox 布局协议。\n'
            '\n'
            '期望 $ChildType 子项的 $runtimeType 是由以下创建的：\n'
            '  $debugCreator\n'
            '\n'
            '不符合预期子类型的 ${child.runtimeType} 是由以下创建的：\n'
            '  ${child.debugCreator}\n');
      }
      return true;
    }());
    return true;
  }

  ChildType? operator [](int index) => _childRenderObjects[index];

  void operator []=(int index, ChildType child) {
    if (index < 0) {
      throw ArgumentError(index);
    }
    _removeChild(_childRenderObjects[index]);
    adoptChild(child);
    _childRenderObjects[index] = child;
  }

  void forEachChild(void Function(ChildType child) f) {
    _childRenderObjects.values.forEach(f);
  }

  /// 从子列表中移除指定索引处的子项。
  void remove(int index) {
    final child = _childRenderObjects.remove(index);
    _removeChild(child);
  }

  void _removeChild(ChildType? child) {
    if (child != null) {
      // 移除旧子项。
      dropChild(child);
    }
  }

  /// 从此渲染对象的子列表中移除所有子项。
  ///
  /// 比逐个移除它们更有效。
  void removeAll() {
    _childRenderObjects.values.forEach(dropChild);
    _childRenderObjects.clear();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (var child in _childRenderObjects.values) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    for (var child in _childRenderObjects.values) {
      child.detach();
    }
  }

  @override
  void redepthChildren() {
    _childRenderObjects.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    _childRenderObjects.values.forEach(visitor);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    _childRenderObjects.forEach((index, child) => children.add(child.toDiagnosticsNode(name: '子项 $index')));
    return children;
  }
}
