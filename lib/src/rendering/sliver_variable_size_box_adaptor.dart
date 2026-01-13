import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:staggered_grid/src/rendering/tile_container_render_object_mixin.dart';

/// [RenderSliverVariableSizeBoxAdaptor] 使用的代理，用于管理其子项。
///
/// [RenderSliverVariableSizeBoxAdaptor] 对象会懒加载其实例化子项，以避免在视口不可见的子项上浪费资源。
/// 此代理允许这些对象创建和移除子项，并估计完整子列表占用的总滚动偏移范围。
abstract class RenderSliverVariableSizeBoxChildManager {
  /// 在布局期间需要新子项时调用。子项应插入到子项列表的适当位置。
  /// 其索引和滚动偏移将自动被适当地设置。
  ///
  /// `index` 参数给出了要显示的子项的索引。可能会请求负索引。
  /// 例如：如果用户从子项 0 滚动到子项 10，然后这些子项变小了很多，
  /// 然后用户又向上滚动，最终可能会请求生成索引为 -1 的子项。
  ///
  /// 如果没有对应 `index` 的子项，则不执行任何操作。
  ///
  /// 索引零对应的子项取决于 [RenderSliverVariableSizeBoxAdaptor.constraints] 中指定的
  /// [GrowthDirection]。
  ///
  /// 在调用 [createChild] 期间，如果是本帧未创建且未更新的子项，
  /// 从 [RenderSliverVariableSizeBoxAdaptor] 对象中移除它们是有效的。
  /// 向此渲染对象添加任何其他子项是无效的。
  ///
  /// 如果此方法没有为大于或等于零的给定 `index` 创建子项，
  /// 那么 [estimateMaxScrollOffset] 必须能够返回一个精确值。
  void createChild(int index);

  /// 从子列表中移除给定的子项。
  ///
  /// 由 [RenderSliverVariableSizeBoxAdaptor.collectGarbage] 调用，
  /// 而后者又由 [RenderSliverVariableSizeBoxAdaptor.performLayout] 调用。
  ///
  /// 给定子项的索引可以通过 [RenderSliverVariableSizeBoxAdaptor.indexOf] 方法获得，
  /// 该方法从子项 [RenderObject.parentData] 的 [SliverVariableSizeBoxAdaptorParentData.index] 字段读取。
  void removeChild(RenderBox child);

  /// 调用以估计此对象的总可滚动范围。
  ///
  /// 必须返回从具有最早可能索引的子项开始到具有最后可能索引的子项结束的总距离。
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  });

  /// 调用以获取子项总数的精确度量。
  ///
  /// 必须返回比 `createChild` 实际创建子项的最大 `index` 大一的数字。
  ///
  /// 当 [createChild] 无法为正 `index` 添加子项时，用于确定 sliver 的精确尺寸。
  /// 它必须返回一个准确且精确的非空值。
  int get childCount;

  /// 在 [RenderSliverVariableSizeBoxAdaptor.adoptChild] 期间调用。
  ///
  /// 子类必须确保在此函数返回后，子项 [RenderObject.parentData] 的
  /// [SliverVariableSizeBoxAdaptorParentData.index] 字段准确反映了子项在子列表中的索引。
  void didAdoptChild(RenderBox child);

  /// 在布局期间调用，指示此对象提供的子项是否不足以填充
  /// [RenderSliverVariableSizeBoxAdaptor] 的 [SliverConstraints.remainingPaintExtent]。
  ///
  /// 通常在布局开始时无条件调用 false，然后在 [RenderSliverVariableSizeBoxAdaptor]
  /// 无法创建填充 [SliverConstraints.remainingPaintExtent] 所需的子项时调用 true。
  // ignore: avoid_positional_boolean_parameters
  void setDidUnderflow(bool value);

  /// 在布局开始时调用，指示布局即将发生。
  void didStartLayout() {}

  /// 在布局结束时调用，指示布局现已完成。
  void didFinishLayout() {}

  /// 在调试模式下，断言此管理器不期望对 [RenderSliverVariableSizeBoxAdaptor] 的子列表进行任何修改。
  ///
  /// 此函数始终返回 true。
  bool debugAssertChildListLocked() => true;
}

/// [RenderSliverVariableSizeBoxAdaptor] 使用的 Parent Data 结构。
class SliverVariableSizeBoxAdaptorParentData extends SliverMultiBoxAdaptorParentData {
  /// 子项在非滚动轴上的偏移。
  ///
  /// 如果滚动轴是垂直的，则此偏移是从父级最左边缘到子级最左边缘。
  /// 如果滚动轴是水平的，则此偏移是从父级最上边缘到子级最上边缘。
  late double crossAxisOffset;

  /// 该 Widget 当前是否在 [RenderSliverVariableSizeBoxAdaptor._keepAliveBucket] 中。
  bool _keptAlive = false;

  @override
  String toString() => 'crossAxisOffset=$crossAxisOffset; ${super.toString()}';
}

/// 具有多个可变大小盒状子项的 Sliver。
///
/// [RenderSliverVariableSizeBoxAdaptor] 是具有多个可变大小盒状子项的 Sliver 的基类。
/// 子项由 [RenderSliverVariableSizeBoxChildManager] 管理，它允许子类在布局期间懒加载创建子项。
/// 通常，子类只会创建填充 [SliverConstraints.remainingPaintExtent] 所需的那些子项。
///
/// 从此渲染对象添加和移除子项的契约比普通渲染对象更严格：
///
/// * 可以在布局过程中移除子项，前提是它们在该布局过程中已经被布局过。
/// * 只能在调用 [childManager] 期间添加子项，并且仅当没有对应于该索引的子项时（或者对应于该索引的子项首先被移除）。
abstract class RenderSliverVariableSizeBoxAdaptor extends RenderSliver
    with
        TileContainerRenderObjectMixin<RenderBox, SliverVariableSizeBoxAdaptorParentData>,
        RenderSliverWithKeepAliveMixin,
        RenderSliverHelpers {
  /// 创建具有多个盒状子项的 Sliver。
  ///
  /// [childManager] 参数不能为空。
  RenderSliverVariableSizeBoxAdaptor({required RenderSliverVariableSizeBoxChildManager childManager})
      : _childManager = childManager;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverVariableSizeBoxAdaptorParentData) {
      child.parentData = SliverVariableSizeBoxAdaptorParentData();
    }
  }

  /// 管理此对象子项的代理。
  ///
  /// [RenderSliverVariableSizeBoxAdaptor] 不具有具体的子项列表，而是使用
  /// [RenderSliverVariableSizeBoxChildManager] 在布局期间创建子项，以填充
  /// [SliverConstraints.remainingPaintExtent]。
  @protected
  RenderSliverVariableSizeBoxChildManager get childManager => _childManager;
  final RenderSliverVariableSizeBoxChildManager _childManager;

  /// 尽管不可见但仍保持存活的节点（缓存桶）。
  final Map<int, RenderBox> _keepAliveBucket = <int, RenderBox>{};

  @override
  void adoptChild(RenderObject child) {
    super.adoptChild(child);
    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    if (!childParentData._keptAlive) {
      childManager.didAdoptChild(child as RenderBox);
    }
  }

  bool _debugAssertChildListLocked() => childManager.debugAssertChildListLocked();

  @override
  void remove(int index) {
    final RenderBox? child = this[index];

    // 如果 child 为 null，表示此元素已被缓存 - 丢弃缓存的元素
    if (child == null) {
      final RenderBox? cachedChild = _keepAliveBucket[index];
      if (cachedChild != null) {
        dropChild(cachedChild);
        _keepAliveBucket.remove(index);
      }
      return;
    }

    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    if (!childParentData._keptAlive) {
      super.remove(index);
      return;
    }
    assert(_keepAliveBucket[childParentData.index!] == child);
    _keepAliveBucket.remove(childParentData.index);
    dropChild(child);
  }

  @override
  void removeAll() {
    super.removeAll();
    _keepAliveBucket.values.forEach(dropChild);
    _keepAliveBucket.clear();
  }

  void _createOrObtainChild(int index) {
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      assert(constraints == this.constraints);
      if (_keepAliveBucket.containsKey(index)) {
        final RenderBox child = _keepAliveBucket.remove(index)!;
        final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        assert(childParentData._keptAlive);
        dropChild(child);
        child.parentData = childParentData;
        this[index] = child;
        childParentData._keptAlive = false;
      } else {
        _childManager.createChild(index);
      }
    });
  }

  void _destroyOrCacheChild(int index) {
    final RenderBox child = this[index]!;
    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    // 如果子项要求保持存活（keepAlive 为 true），则放入缓存桶
    if (childParentData.keepAlive) {
      assert(!childParentData._keptAlive);
      remove(index);
      _keepAliveBucket[childParentData.index!] = child;
      child.parentData = childParentData;
      super.adoptChild(child);
      childParentData._keptAlive = true;
    } else {
      assert(child.parent == this);
      _childManager.removeChild(child);
      assert(child.parent == null);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (var child in _keepAliveBucket.values) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    for (var child in _keepAliveBucket.values) {
      child.detach();
    }
  }

  @override
  void redepthChildren() {
    super.redepthChildren();
    _keepAliveBucket.values.forEach(redepthChild);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    _keepAliveBucket.values.forEach(visitor);
  }

  bool addChild(int index) {
    assert(_debugAssertChildListLocked());
    _createOrObtainChild(index);
    final child = this[index];
    if (child != null) {
      assert(indexOf(child) == index);
      return true;
    }
    childManager.setDidUnderflow(true);
    return false;
  }

  RenderBox? addAndLayoutChild(
    int index,
    BoxConstraints childConstraints, {
    bool parentUsesSize = false,
  }) {
    assert(_debugAssertChildListLocked());
    _createOrObtainChild(index);
    final child = this[index];
    if (child != null) {
      // [优化]: 移除了原始代码中的 try-catch 块。
      // 捕获异常并打印 "This not Error" 是不好的做法，会掩盖真正的布局错误。
      // 如果 child.layout 抛出异常，应该让它向上冒泡，以便开发者修复问题。
      assert(indexOf(child) == index);
      child.layout(childConstraints, parentUsesSize: parentUsesSize);
      return child;
    }
    childManager.setDidUnderflow(true);
    return null;
  }

  /// 布局后调用，带有可在子列表的头部和尾部进行垃圾回收的子项数。
  ///
  /// [SliverVariableSizeBoxAdaptorParentData.keepAlive] 属性为 true 的子项将被移除到缓存中，而不是被丢弃。
  ///
  /// 此方法还会收集以前保持存活但现在不再需要的任何子项。
  @protected
  void collectGarbage(Set<int> visibleIndices) {
    assert(_debugAssertChildListLocked());
    assert(childCount >= visibleIndices.length);
    invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
      // 我们只销毁那些不可见的。
      indices.toSet().difference(visibleIndices).forEach(_destroyOrCacheChild);

      // 要求子管理器移除不再保持存活的子项。
      _keepAliveBucket.values
          .where((RenderBox child) {
            final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
            return !childParentData.keepAlive;
          })
          .toList()
          .forEach(_childManager.removeChild);

      // 断言确保缓存桶中剩余的都是需要 keepAlive 的。
      assert(_keepAliveBucket.values.where((RenderBox child) {
        final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        return !childParentData.keepAlive;
      }).isEmpty);
    });
  }

  /// 返回给定子项的索引，由其 [parentData] 的 [SliverVariableSizeBoxAdaptorParentData.index] 字段给出。
  int indexOf(RenderBox child) {
    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    assert(childParentData.index != null);
    return childParentData.index!;
  }

  /// 返回主轴上给定子项的尺寸，由子项的 [RenderBox.size] 属性给出。这仅在布局后有效。
  @protected
  double paintExtentOf(RenderBox child) {
    assert(child.hasSize);
    switch (constraints.axis) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  @override
  bool hitTestChildren(HitTestResult result, {required double mainAxisPosition, required double crossAxisPosition}) {
    for (final child in children.toList().reversed) {
      if (hitTestBoxChild(BoxHitTestResult.wrap(result), child,
          mainAxisPosition: mainAxisPosition, crossAxisPosition: crossAxisPosition)) {
        return true;
      }
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    // [优化]: 移除了这里的 try-catch。如果有异常，说明 layoutOffset 为空，这是程序错误，不应被掩盖。
    return childScrollOffset(child)! - (constraints.scrollOffset);
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    return childParentData.crossAxisOffset;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    assert(childParentData.layoutOffset != null);
    return childParentData.layoutOffset;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount == 0) {
      return;
    }
    // offset 指向左上角，无论我们的轴方向如何。
    // originOffset 提供了从真实原点到轴方向原点的增量。
    Offset? mainAxisUnit, crossAxisUnit, originOffset;
    bool? addExtent;
    switch (applyGrowthDirectionToAxisDirection(constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0, -1);
        crossAxisUnit = const Offset(1, 0);
        originOffset = offset + Offset(0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1, 0);
        crossAxisUnit = const Offset(0, 1);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0, 1);
        crossAxisUnit = const Offset(1, 0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1, 0);
        crossAxisUnit = const Offset(0, 1);
        originOffset = offset + Offset(geometry!.paintExtent, 0);
        addExtent = true;
        break;
    }

    for (final child in children) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx + mainAxisUnit.dx * mainAxisDelta + crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy + mainAxisUnit.dy * mainAxisDelta + crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) {
        childOffset += mainAxisUnit * paintExtentOf(child);
      }
      context.paintChild(child, childOffset);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsNode.message(childCount > 0 ? '当前存活的子项: ${indices.join(',')}' : '没有当前存活的子项'));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> childList = <DiagnosticsNode>[];
    if (childCount > 0) {
      for (final child in children) {
        final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        childList.add(child.toDiagnosticsNode(name: '索引为 ${childParentData.index} 的子项'));
      }
    }
    if (_keepAliveBucket.isNotEmpty) {
      final List<int> indices = _keepAliveBucket.keys.toList()..sort();
      for (final index in indices) {
        childList.add(_keepAliveBucket[index]!.toDiagnosticsNode(
          name: '索引为 $index 的子项 (保持存活且不可见)',
          style: DiagnosticsTreeStyle.offstage,
        ));
      }
    }
    return childList;
  }
}
