import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:staggered_grid/src/rendering/sliver_staggered_grid.dart';
import 'package:staggered_grid/src/rendering/sliver_variable_size_box_adaptor.dart';
import 'package:staggered_grid/src/widgets/staggered_tile.dart';

abstract class SliverVariableSizeBoxAdaptorWidget extends SliverWithKeepAliveWidget {
  /// 初始化子类字段。
  const SliverVariableSizeBoxAdaptorWidget({
    super.key,
    required this.delegate,
    this.addAutomaticKeepAlives = true,
  });

  /// 是否为子组件添加自动保持存活（AutomaticKeepAlives）功能。
  ///
  /// 如果为 true，则会自动包裹 AutomaticKeepAlive。
  /// 注意：这并不意味着所有子项都会被永久保持，只有那些请求了 KeepAlive 的子项才会被保持。
  final bool addAutomaticKeepAlives;

  /// 提供此 Widget 子项的代理。
  ///
  /// 使用此 Widget 懒加载构建子项，以避免创建比通过 [Viewport] 可见部分更多的子项。
  ///
  /// 参见:
  ///
  ///  * [SliverChildBuilderDelegate] 和 [SliverChildListDelegate]，
  ///    它们是 [SliverChildDelegate] 的常用子类，分别使用构建器回调和显式子列表。
  final SliverChildDelegate delegate;

  @override
  SliverVariableSizeBoxAdaptorElement createElement() => SliverVariableSizeBoxAdaptorElement(
        this,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
      );

  @override
  RenderSliverVariableSizeBoxAdaptor createRenderObject(BuildContext context);

  /// 返回所有子项的最大滚动范围估计值。
  ///
  /// 如果子类有关于其最大滚动范围的额外信息，应该重写此函数。
  ///
  /// 这被 [SliverMultiBoxAdaptorElement] 用于实现 [RenderSliverBoxChildManager] API 的一部分。
  ///
  /// 默认实现是通过其 [SliverChildDelegate.estimateMaxScrollOffset] 方法委托给 [delegate]。
  double? estimateMaxScrollOffset(
    SliverConstraints constraints,
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    assert(lastIndex >= firstIndex);
    return delegate.estimateMaxScrollOffset(
      firstIndex,
      lastIndex,
      leadingScrollOffset,
      trailingScrollOffset,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<SliverChildDelegate>('delegate', delegate),
    );
  }
}

class SliverVariableSizeBoxAdaptorElement extends RenderObjectElement
    implements RenderSliverVariableSizeBoxChildManager {
  /// 创建一个懒加载构建子项的 Element。
  SliverVariableSizeBoxAdaptorElement(SliverVariableSizeBoxAdaptorWidget super.widget,
      {this.addAutomaticKeepAlives = true});

  /// 是否为子组件添加自动保持存活功能。
  final bool addAutomaticKeepAlives;

  @override
  SliverVariableSizeBoxAdaptorWidget get widget => super.widget as SliverVariableSizeBoxAdaptorWidget;

  @override
  RenderSliverVariableSizeBoxAdaptor get renderObject => super.renderObject as RenderSliverVariableSizeBoxAdaptor;

  @override
  void update(covariant SliverVariableSizeBoxAdaptorWidget newWidget) {
    final SliverVariableSizeBoxAdaptorWidget oldWidget = widget;
    super.update(newWidget);
    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType || newDelegate.shouldRebuild(oldDelegate))) {
      performRebuild();
    }
  }

  // 我们在两个不同的时间点 inflate (挂载) widgets：
  //  1. 当我们自己被告知需要重建时（见 performRebuild）。
  //  2. 当我们的 render object 需要一个子项时（见 createChild）。
  // 在这两种情况下，我们都会缓存调用 delegate 获取 widget 的结果，
  // 这样如果稍后执行情况 2，我们就不必再次调用 builder。
  // 但是，任何时候我们执行情况 1，我们都会重置缓存。

  final Map<int, Widget?> _childWidgets = HashMap<int, Widget?>();
  final SplayTreeMap<int, Element> _childElements = SplayTreeMap<int, Element>();

  @override
  void performRebuild() {
    _childWidgets.clear(); // 如上所述，重置缓存。
    super.performRebuild();
    assert(_currentlyUpdatingChildIndex == null);
    try {
      late final int firstIndex;
      late final int lastIndex;
      if (_childElements.isEmpty) {
        firstIndex = 0;
        lastIndex = 0;
      } else if (_didUnderflow) {
        firstIndex = _childElements.firstKey()!;
        lastIndex = _childElements.lastKey()! + 1;
      } else {
        firstIndex = _childElements.firstKey()!;
        lastIndex = _childElements.lastKey()!;
      }

      for (int index = firstIndex; index <= lastIndex; ++index) {
        _currentlyUpdatingChildIndex = index;
        final Element? newChild = updateChild(_childElements[index], _build(index), index);
        if (newChild != null) {
          _childElements[index] = newChild;
        } else {
          _childElements.remove(index);
        }
      }
    } finally {
      _currentlyUpdatingChildIndex = null;
    }
  }

  Widget? _build(int index) {
    return _childWidgets.putIfAbsent(index, () => widget.delegate.build(this, index));
  }

  @override
  void createChild(int index) {
    assert(_currentlyUpdatingChildIndex == null);
    owner!.buildScope(this, () {
      Element? newChild;
      try {
        _currentlyUpdatingChildIndex = index;
        newChild = updateChild(_childElements[index], _build(index), index);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      if (newChild != null) {
        _childElements[index] = newChild;
      } else {
        _childElements.remove(index);
      }
    });
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, dynamic newSlot) {
    final oldParentData = child?.renderObject?.parentData as SliverVariableSizeBoxAdaptorParentData?;
    final Element? newChild = super.updateChild(child, newWidget, newSlot);
    final newParentData = newChild?.renderObject?.parentData as SliverVariableSizeBoxAdaptorParentData?;

    // 如果 renderObject 被交换出去，保留旧的 layoutOffset。
    if (oldParentData != newParentData && oldParentData != null && newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }

    return newChild;
  }

  @override
  void forgetChild(Element child) {
    assert(child.slot != null);
    assert(_childElements.containsKey(child.slot));
    _childElements.remove(child.slot);
    super.forgetChild(child);
  }

  @override
  void removeChild(RenderBox child) {
    final int index = renderObject.indexOf(child);
    assert(_currentlyUpdatingChildIndex == null);
    assert(index >= 0);
    owner!.buildScope(this, () {
      assert(_childElements.containsKey(index));
      try {
        _currentlyUpdatingChildIndex = index;
        final Element? result = updateChild(_childElements[index], null, index);
        assert(result == null);
      } finally {
        _currentlyUpdatingChildIndex = null;
      }
      _childElements.remove(index);
      assert(!_childElements.containsKey(index));
    });
  }

  double? _extrapolateMaxScrollOffset(
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  ) {
    final int? childCount = widget.delegate.estimatedChildCount;
    if (childCount == null) {
      return double.infinity;
    }
    if (lastIndex == childCount - 1) {
      return trailingScrollOffset;
    }
    final int reifiedCount = lastIndex! - firstIndex! + 1;
    final double averageExtent = (trailingScrollOffset! - leadingScrollOffset!) / reifiedCount;
    final int remainingCount = childCount - lastIndex - 1;
    return trailingScrollOffset + averageExtent * remainingCount;
  }

  @override
  double estimateMaxScrollOffset(
    SliverConstraints constraints, {
    int? firstIndex,
    int? lastIndex,
    double? leadingScrollOffset,
    double? trailingScrollOffset,
  }) {
    return widget.estimateMaxScrollOffset(
          constraints,
          firstIndex!,
          lastIndex!,
          leadingScrollOffset!,
          trailingScrollOffset!,
        ) ??
        _extrapolateMaxScrollOffset(
          firstIndex,
          lastIndex,
          leadingScrollOffset,
          trailingScrollOffset,
        )!;
  }

  @override
  int get childCount => widget.delegate.estimatedChildCount ?? 0;

  @override
  void didStartLayout() {
    assert(debugAssertChildListLocked());
  }

  @override
  void didFinishLayout() {
    assert(debugAssertChildListLocked());
    final int firstIndex = _childElements.firstKey() ?? 0;
    final int lastIndex = _childElements.lastKey() ?? 0;
    widget.delegate.didFinishLayout(firstIndex, lastIndex);
  }

  int? _currentlyUpdatingChildIndex;

  @override
  bool debugAssertChildListLocked() {
    assert(_currentlyUpdatingChildIndex == null);
    return true;
  }

  @override
  void didAdoptChild(RenderBox child) {
    assert(_currentlyUpdatingChildIndex != null);
    final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
    childParentData.index = _currentlyUpdatingChildIndex;
  }

  bool _didUnderflow = false;

  @override
  void setDidUnderflow(bool value) {
    _didUnderflow = value;
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, int slot) {
    assert(_currentlyUpdatingChildIndex == slot);
    assert(renderObject.debugValidateChild(child));
    renderObject[_currentlyUpdatingChildIndex!] = child;
    assert(() {
      final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
      assert(slot == childParentData.index);
      return true;
    }());
  }

  @override
  void moveRenderObjectChild(
    covariant RenderObject child,
    covariant Object? oldSlot,
    covariant Object? newSlot,
  ) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(
    covariant RenderObject child,
    covariant Object? slot,
  ) {
    assert(_currentlyUpdatingChildIndex != null);
    renderObject.remove(_currentlyUpdatingChildIndex!);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    // 使用 toList() 创建副本，以便访问者可以修改底层列表：
    _childElements.values.toList().forEach(visitor);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    _childElements.values.where((Element child) {
      final parentData = child.renderObject!.parentData as SliverMultiBoxAdaptorParentData?;
      late double itemExtent;
      switch (renderObject.constraints.axis) {
        case Axis.horizontal:
          itemExtent = child.renderObject!.paintBounds.width;
          break;
        case Axis.vertical:
          itemExtent = child.renderObject!.paintBounds.height;
          break;
      }

      return parentData!.layoutOffset! <
              renderObject.constraints.scrollOffset + renderObject.constraints.remainingPaintExtent &&
          parentData.layoutOffset! + itemExtent > renderObject.constraints.scrollOffset;
    }).forEach(visitor);
  }
}

class SliverStaggeredGrid extends SliverVariableSizeBoxAdaptorWidget {
  /// 创建一个 Sliver，将多个盒状子项放置在二维排列中。
  const SliverStaggeredGrid({
    super.key,
    required super.delegate,
    required this.gridDelegate,
    super.addAutomaticKeepAlives,
  });

  /// 创建一个 Sliver，将多个盒状子项放置在具有固定交叉轴 tile 数量的二维排列中。
  SliverStaggeredGrid.count({
    super.key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles.length,
        ),
        super(
          delegate: SliverChildListDelegate(
            children,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
          ),
        );

  /// 创建一个 Sliver，构建具有固定交叉轴 tile 数量的二维排列的多个盒状子项。
  SliverStaggeredGrid.countBuilder({
    super.key,
    required int crossAxisCount,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
          ),
        );

  /// 创建一个 Sliver，将多个盒状子项放置在二维排列中，每个 tile 都有最大交叉轴范围。
  SliverStaggeredGrid.extent({
    super.key,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles.length,
        ),
        super(
          delegate: SliverChildListDelegate(
            children,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
          ),
        );

  /// 创建一个 Sliver，构建具有每个 tile 都有最大交叉轴范围的二维排列的多个盒状子项。
  SliverStaggeredGrid.extentBuilder({
    super.key,
    required double maxCrossAxisExtent,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    bool addAutomaticKeepAlives = true,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        super(
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
          ),
        );

  /// 控制子项大小和位置的代理。
  final SliverStaggeredGridDelegate gridDelegate;

  @override
  RenderSliverStaggeredGrid createRenderObject(BuildContext context) {
    final element = context as SliverVariableSizeBoxAdaptorElement;
    return RenderSliverStaggeredGrid(childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverStaggeredGrid renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }
}
