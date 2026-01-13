import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:staggered_grid/src/rendering/sliver_variable_size_box_adaptor.dart';
import 'package:staggered_grid/src/widgets/staggered_tile.dart';

/// 给定索引创建 [StaggeredTile] 的函数签名。
typedef IndexedStaggeredTileBuilder = StaggeredTile? Function(int index);

/// 指定交错网格的配置方式。
@immutable
class StaggeredGridConfiguration {
  /// 创建一个保存交错网格配置的对象。
  const StaggeredGridConfiguration({
    required this.crossAxisCount,
    required this.staggeredTileBuilder,
    required this.cellExtent,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.reverseCrossAxis,
    required this.staggeredTileCount,
    this.mainAxisOffsetsCacheSize = 3,
  })  : assert(crossAxisCount > 0),
        assert(cellExtent >= 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(mainAxisOffsetsCacheSize > 0),
        cellStride = cellExtent + crossAxisSpacing;

  /// 交叉轴上的最大子项数。
  final int crossAxisCount;

  /// 在两个轴上，从一个单元格的前缘到同一单元格的后缘的像素数。
  final double cellExtent;

  /// 主轴上每个子项之间的逻辑像素数。
  final double mainAxisSpacing;

  /// 交叉轴上每个子项之间的逻辑像素数。
  final double crossAxisSpacing;

  /// 调用以获取 [SliverGridStaggeredTileLayout] 指定索引处的 tile。
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  /// 此代理可以提供的 tile 总数。
  ///
  /// 如果为 null，则 tile 数量由 [builder] 返回 null 的最小索引决定。
  final int? staggeredTileCount;

  /// 子项是否应按交叉轴坐标增加的相反顺序放置。
  ///
  /// 例如，如果交叉轴是水平的，当 [reverseCrossAxis] 为 false 时，子项从左到右放置；
  /// 当 [reverseCrossAxis] 为 true 时，从右到左放置。
  final bool reverseCrossAxis;

  final double cellStride;

  /// 缓存 mainAxisOffsets 值所需的页数。
  final int mainAxisOffsetsCacheSize;

  List<double> generateMainAxisOffsets() => List.generate(crossAxisCount, (i) => 0.0);

  /// 获取给定索引的归一化 tile。
  StaggeredTile? getStaggeredTile(int index) {
    StaggeredTile? tile;
    if (staggeredTileCount == null || index < staggeredTileCount!) {
      // 这个索引可能有一个 tile。
      tile = _normalizeStaggeredTile(staggeredTileBuilder(index));
    }
    return tile;
  }

  /// 计算任何交错 tile 的主轴范围。
  double _getStaggeredTileMainAxisExtent(StaggeredTile tile) {
    return tile.mainAxisExtent ??
        (tile.mainAxisCellCount! * cellExtent) + (tile.mainAxisCellCount! - 1) * mainAxisSpacing;
  }

  /// 使用给定的 tile 创建具有计算范围的交错 tile。
  StaggeredTile? _normalizeStaggeredTile(StaggeredTile? staggeredTile) {
    if (staggeredTile == null) {
      return null;
    } else {
      final crossAxisCellCount = staggeredTile.crossAxisCellCount.clamp(0, crossAxisCount).toInt();
      if (staggeredTile.fitContent) {
        return StaggeredTile.fit(crossAxisCellCount);
      } else {
        return StaggeredTile.extent(crossAxisCellCount, _getStaggeredTileMainAxisExtent(staggeredTile));
      }
    }
  }
}

class _Block {
  const _Block(this.index, this.crossAxisCount, this.minOffset, this.maxOffset);

  final int index;
  final int crossAxisCount;
  final double minOffset;
  final double maxOffset;
}

const double _epsilon = 0.0001;

bool _nearEqual(double d1, double d2) {
  return (d1 - d2).abs() < _epsilon;
}

@immutable
class SliverStaggeredGridGeometry {
  /// 创建一个对象，描述子项在 [RenderSliverStaggeredGrid] 中的位置。
  const SliverStaggeredGridGeometry({
    required this.scrollOffset,
    required this.crossAxisOffset,
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.crossAxisCellCount,
    required this.blockIndex,
  });

  /// 子项前缘相对于父级前缘的滚动偏移。
  final double scrollOffset;

  /// 子项在非滚动轴上的偏移。
  final double crossAxisOffset;

  /// 子项在滚动轴上的范围。
  final double? mainAxisExtent;

  /// 子项在非滚动轴上的范围。
  final double crossAxisExtent;

  final int crossAxisCellCount;

  final int blockIndex;

  bool get hasTrailingScrollOffset => mainAxisExtent != null;

  /// 子项后缘相对于父级前缘的滚动偏移。
  double get trailingScrollOffset => scrollOffset + (mainAxisExtent ?? 0);

  SliverStaggeredGridGeometry copyWith({
    double? scrollOffset,
    double? crossAxisOffset,
    double? mainAxisExtent,
    double? crossAxisExtent,
    int? crossAxisCellCount,
    int? blockIndex,
  }) {
    return SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset ?? this.scrollOffset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      mainAxisExtent: mainAxisExtent ?? this.mainAxisExtent,
      crossAxisExtent: crossAxisExtent ?? this.crossAxisExtent,
      crossAxisCellCount: crossAxisCellCount ?? this.crossAxisCellCount,
      blockIndex: blockIndex ?? this.blockIndex,
    );
  }

  /// 返回一个紧密的 [BoxConstraints]，强制子项具有所需的大小。
  BoxConstraints getBoxConstraints(SliverConstraints constraints) {
    return constraints.asBoxConstraints(
      minExtent: mainAxisExtent ?? 0.0,
      maxExtent: mainAxisExtent ?? double.infinity,
      crossAxisExtent: crossAxisExtent,
    );
  }

  @override
  String toString() {
    return 'SliverStaggeredGridGeometry('
        'scrollOffset: $scrollOffset, '
        'crossAxisOffset: $crossAxisOffset, '
        'mainAxisExtent: $mainAxisExtent, '
        'crossAxisExtent: $crossAxisExtent, '
        'crossAxisCellCount: $crossAxisCellCount, '
        'startIndex: $blockIndex)';
  }
}

class RenderSliverStaggeredGrid extends RenderSliverVariableSizeBoxAdaptor {
  /// 创建一个包含多个盒状子项的 Sliver，这些子项的大小和位置由代理确定。
  ///
  /// [configuration] 和 [childManager] 参数不能为空。
  RenderSliverStaggeredGrid({
    required super.childManager,
    required SliverStaggeredGridDelegate gridDelegate,
  })  : _gridDelegate = gridDelegate,
        _pageSizeToViewportOffsets = HashMap<double, SplayTreeMap<int, _ViewportOffsets?>>();

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverVariableSizeBoxAdaptorParentData) {
      final data = SliverVariableSizeBoxAdaptorParentData();
      child.parentData = data;
    }
  }

  /// 控制交错网格配置的代理。
  SliverStaggeredGridDelegate get gridDelegate => _gridDelegate;
  SliverStaggeredGridDelegate _gridDelegate;
  set gridDelegate(SliverStaggeredGridDelegate value) {
    if (_gridDelegate == value) {
      return;
    }
    if (value.runtimeType != _gridDelegate.runtimeType || value.shouldRelayout(_gridDelegate)) {
      markNeedsLayout();
    }
    _gridDelegate = value;
  }

  /// 缓存不同页面大小（pageSize）对应的视口偏移量。
  /// 这里的 key 是 pageSize。
  final HashMap<double, SplayTreeMap<int, _ViewportOffsets?>> _pageSizeToViewportOffsets;

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    bool reachedEnd = false;
    double trailingScrollOffset = 0;
    double leadingScrollOffset = double.infinity;
    bool visible = false;
    int firstIndex = 0;
    int lastIndex = 0;

    final configuration = _gridDelegate.getConfiguration(constraints);

    final pageSize = configuration.mainAxisOffsetsCacheSize * constraints.viewportMainAxisExtent;
    if (pageSize == 0.0) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }
    final pageIndex = scrollOffset ~/ pageSize;
    assert(pageIndex >= 0);

    // [优化]: 限制缓存大小。在桌面端调整窗口大小时，viewportMainAxisExtent 会变化，
    // 导致 pageSize 频繁变化。如果不限制，这个 Map 会无限膨胀导致内存泄漏。
    // 我们保留少量最近使用的缓存以应对屏幕旋转（横屏/竖屏切换）。
    if (!_pageSizeToViewportOffsets.containsKey(pageSize)) {
      if (_pageSizeToViewportOffsets.length >= 4) {
        _pageSizeToViewportOffsets.clear();
      }
    }

    // 如果视口调整大小，我们将保留旧的偏移量缓存。（如果仅方向多次更改，这将很有用）。
    final viewportOffsets =
        _pageSizeToViewportOffsets.putIfAbsent(pageSize, () => SplayTreeMap<int, _ViewportOffsets?>());

    _ViewportOffsets? viewportOffset;
    if (viewportOffsets.isEmpty) {
      viewportOffset = _ViewportOffsets(configuration.generateMainAxisOffsets(), pageSize);
      viewportOffsets[0] = viewportOffset;
    } else {
      final smallestKey = viewportOffsets.lastKeyBefore(pageIndex + 1);
      viewportOffset = viewportOffsets[smallestKey!];
    }

    // 交错网格总是必须从零索引基础布局子项到最后一个可见子项。
    final mainAxisOffsets = viewportOffset!.mainAxisOffsets.toList();
    final visibleIndices = HashSet<int>();

    // 遍历所有子项，只要它们可能可见。
    for (var index = viewportOffset.firstChildIndex; mainAxisOffsets.any((o) => o <= targetEndScrollOffset); index++) {
      SliverStaggeredGridGeometry? geometry = getSliverStaggeredGeometry(index, configuration, mainAxisOffsets);
      if (geometry == null) {
        // 要么没有子项，要么我们已经超过了所有子项的末尾。
        reachedEnd = true;
        break;
      }

      final bool hasTrailingScrollOffset = geometry.hasTrailingScrollOffset;
      RenderBox? child;
      if (!hasTrailingScrollOffset) {
        // 布局子项以计算其 tailingScrollOffset。
        // parentUsesSize 设置为 true，因为我们需要子项的尺寸来计算偏移量。
        final constraints = BoxConstraints.tightFor(width: geometry.crossAxisExtent);
        child = addAndLayoutChild(index, constraints, parentUsesSize: true);
        geometry = geometry.copyWith(mainAxisExtent: paintExtentOf(child!));
      }

      if (!visible && targetEndScrollOffset >= geometry.scrollOffset && scrollOffset <= geometry.trailingScrollOffset) {
        visible = true;
        leadingScrollOffset = geometry.scrollOffset;
        firstIndex = index;
      }

      if (visible && hasTrailingScrollOffset) {
        child = addAndLayoutChild(index, geometry.getBoxConstraints(constraints));
      }

      if (child != null) {
        final childParentData = child.parentData! as SliverVariableSizeBoxAdaptorParentData;
        childParentData.layoutOffset = geometry.scrollOffset;
        childParentData.crossAxisOffset = geometry.crossAxisOffset;
        assert(childParentData.index == index);
      }

      if (visible && indices.contains(index)) {
        visibleIndices.add(index);
      }

      if (geometry.trailingScrollOffset >= viewportOffset!.trailingScrollOffset) {
        final nextPageIndex = viewportOffset.pageIndex + 1;
        final nextViewportOffset =
            _ViewportOffsets(mainAxisOffsets, (nextPageIndex + 1) * pageSize, nextPageIndex, index);
        viewportOffsets[nextPageIndex] = nextViewportOffset;
        viewportOffset = nextViewportOffset;
      }

      final double endOffset = geometry.trailingScrollOffset + configuration.mainAxisSpacing;
      for (var i = 0; i < geometry.crossAxisCellCount; i++) {
        mainAxisOffsets[i + geometry.blockIndex] = endOffset;
      }

      trailingScrollOffset = mainAxisOffsets.reduce(math.max);
      lastIndex = index;
    }

    collectGarbage(visibleIndices);

    if (!visible) {
      if (scrollOffset > viewportOffset!.trailingScrollOffset) {
        // 我们超出了边界，我们必须修正滚动。
        final viewportOffsetScrollOffset = pageSize * viewportOffset.pageIndex;
        final correction = viewportOffsetScrollOffset - scrollOffset;
        geometry = SliverGeometry(
          scrollOffsetCorrection: correction,
        );
      } else {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
      }
      return;
    }

    double estimatedMaxScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = trailingScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      );
      assert(estimatedMaxScrollOffset >= trailingScrollOffset - leadingScrollOffset);
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // 保守地避免在滚动期间闪烁裁剪。
      hasVisualOverflow: trailingScrollOffset > targetEndScrollOffset || constraints.scrollOffset > 0.0,
    );

    // 我们可能在滚动到底部时开始布局，这不会暴露子项。
    if (estimatedMaxScrollOffset == trailingScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  static SliverStaggeredGridGeometry? getSliverStaggeredGeometry(
      int index, StaggeredGridConfiguration configuration, List<double> offsets) {
    final tile = configuration.getStaggeredTile(index);
    if (tile == null) {
      return null;
    }

    final block = _findFirstAvailableBlockWithCrossAxisCount(tile.crossAxisCellCount, offsets);

    final scrollOffset = block.minOffset;
    var blockIndex = block.index;
    if (configuration.reverseCrossAxis) {
      blockIndex = configuration.crossAxisCount - tile.crossAxisCellCount - blockIndex;
    }
    final crossAxisOffset = blockIndex * configuration.cellStride;
    final geometry = SliverStaggeredGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: tile.mainAxisExtent,
      crossAxisExtent: configuration.cellStride * tile.crossAxisCellCount - configuration.crossAxisSpacing,
      crossAxisCellCount: tile.crossAxisCellCount,
      blockIndex: block.index,
    );
    return geometry;
  }

  /// 在 [offsets] 列表中查找至少具有指定 [crossAxisCount] 的第一个可用块。
  static _Block _findFirstAvailableBlockWithCrossAxisCount(int crossAxisCount, List<double> offsets) {
    // 这里使用 List.from 复制一份 offsets，因为 _findFirstAvailableBlockWithCrossAxisCountAndOffsets
    // 是一种尝试填充（Try-Fill）算法，它会修改传入的列表来模拟填充过程。
    // 我们不能修改原始的 offsets 列表。
    return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(crossAxisCount, List.from(offsets));
  }

  /// 查找至少具有指定 [crossAxisCount] 的第一个可用块。
  static _Block _findFirstAvailableBlockWithCrossAxisCountAndOffsets(int crossAxisCount, List<double> offsets) {
    final block = _findFirstAvailableBlock(offsets);
    if (block.crossAxisCount < crossAxisCount) {
      // 空间不足以容纳指定的交叉轴数量。
      // 我们必须填充这个块并重试（递归调用）。
      for (var i = 0; i < block.crossAxisCount; ++i) {
        offsets[i + block.index] = block.maxOffset;
      }
      return _findFirstAvailableBlockWithCrossAxisCountAndOffsets(crossAxisCount, offsets);
    } else {
      return block;
    }
  }

  /// 查找指定 [offsets] 列表的第一个可用块。
  static _Block _findFirstAvailableBlock(List<double> offsets) {
    int index = 0;
    double minBlockOffset = double.infinity;
    double maxBlockOffset = double.infinity;
    int crossAxisCount = 1;
    bool contiguous = false;

    // 由于浮点运算，我们必须使用 _nearEqual 函数。
    // 例如：0.1 + 0.2 = 0.30000000000000004 而不是 0.3。

    for (var i = index; i < offsets.length; ++i) {
      final offset = offsets[i];
      if (offset < minBlockOffset && !_nearEqual(offset, minBlockOffset)) {
        index = i;
        maxBlockOffset = minBlockOffset;
        minBlockOffset = offset;
        crossAxisCount = 1;
        contiguous = true;
      } else if (_nearEqual(offset, minBlockOffset) && contiguous) {
        crossAxisCount++;
      } else if (offset < maxBlockOffset && offset > minBlockOffset && !_nearEqual(offset, minBlockOffset)) {
        contiguous = false;
        maxBlockOffset = offset;
      } else {
        contiguous = false;
      }
    }

    return _Block(index, crossAxisCount, minBlockOffset, maxBlockOffset);
  }
}

class _ViewportOffsets {
  _ViewportOffsets(
    List<double> mainAxisOffsets,
    this.trailingScrollOffset, [
    this.pageIndex = 0,
    this.firstChildIndex = 0,
  ]) : mainAxisOffsets = mainAxisOffsets.toList();

  final int pageIndex;

  final int firstChildIndex;

  final double trailingScrollOffset;

  final List<double> mainAxisOffsets;

  @override
  String toString() => '[$pageIndex-$trailingScrollOffset] ($firstChildIndex, $mainAxisOffsets)';
}

abstract class SliverStaggeredGridDelegate {
  /// 创建一个生成交错网格布局的代理
  ///
  /// 所有参数都不能为 null。[mainAxisSpacing] 和
  /// [crossAxisSpacing] 参数不能为负数。
  const SliverStaggeredGridDelegate({
    required this.staggeredTileBuilder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.staggeredTileCount,
  })  : assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0);

  /// 主轴上每个子项之间的逻辑像素数。
  final double mainAxisSpacing;

  /// 交叉轴上每个子项之间的逻辑像素数。
  final double crossAxisSpacing;

  /// 调用以获取 [RenderSliverStaggeredGrid] 指定索引处的 tile。
  final IndexedStaggeredTileBuilder staggeredTileBuilder;

  /// 此代理可以提供的 tile 总数。
  ///
  /// 如果为 null，则 tile 数量由 [builder] 返回 null 的最小索引决定。
  final int? staggeredTileCount;

  bool _debugAssertIsValid() {
    assert(mainAxisSpacing >= 0);
    assert(crossAxisSpacing >= 0);
    return true;
  }

  /// 返回有关交错网格配置的信息。
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints);

  /// 当子项需要重新布局时，重写此方法返回 true。
  ///
  /// 这应该比较当前代理和给定的 `oldDelegate` 的字段，
  /// 如果字段使得布局不同，则返回 true。
  bool shouldRelayout(SliverStaggeredGridDelegate oldDelegate) {
    return oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.staggeredTileCount != staggeredTileCount ||
        oldDelegate.staggeredTileBuilder != staggeredTileBuilder;
  }
}

class SliverStaggeredGridDelegateWithFixedCrossAxisCount extends SliverStaggeredGridDelegate {
  /// 创建一个代理，使用交叉轴上固定数量的 tile 进行交错网格布局。
  ///
  /// 所有参数都不能为 null。[mainAxisSpacing] 和
  /// [crossAxisSpacing] 参数不能为负数。[crossAxisCount]
  /// 参数必须大于零。
  const SliverStaggeredGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
    required super.staggeredTileBuilder,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    super.staggeredTileCount,
  }) : assert(crossAxisCount > 0);

  /// 交叉轴上的子项数量。
  final int crossAxisCount;

  @override
  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    return super._debugAssertIsValid();
  }

  @override
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return StaggeredGridConfiguration(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      staggeredTileCount: staggeredTileCount,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(covariant SliverStaggeredGridDelegateWithFixedCrossAxisCount oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount || super.shouldRelayout(oldDelegate);
  }
}

class SliverStaggeredGridDelegateWithMaxCrossAxisExtent extends SliverStaggeredGridDelegate {
  /// 创建一个代理，使用具有最大交叉轴范围的 tile 进行交错网格布局。
  ///
  /// 所有参数都不能为 null。[maxCrossAxisExtent]、
  /// [mainAxisSpacing] 和 [crossAxisSpacing] 参数不能为负数。
  const SliverStaggeredGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    required super.staggeredTileBuilder,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    super.staggeredTileCount,
  }) : assert(maxCrossAxisExtent > 0);

  /// 交叉轴上 tile 的最大范围。
  ///
  /// 此代理将为 tile 选择尽可能大的交叉轴范围，但要满足以下条件：
  ///
  ///  - 该范围能整除网格的交叉轴范围。
  ///  - 该范围最多为 [maxCrossAxisExtent]。
  ///
  /// 例如，如果网格是垂直的，网格宽 500.0 像素，
  /// 且 [maxCrossAxisExtent] 为 150.0，此代理将创建一个具有 4 列的网格，
  /// 每列宽 125.0 像素。
  final double maxCrossAxisExtent;

  @override
  bool _debugAssertIsValid() {
    assert(maxCrossAxisExtent >= 0);
    return super._debugAssertIsValid();
  }

  @override
  StaggeredGridConfiguration getConfiguration(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final int crossAxisCount =
        ((constraints.crossAxisExtent + crossAxisSpacing) / (maxCrossAxisExtent + crossAxisSpacing)).ceil();

    final double usableCrossAxisExtent = constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);

    final double cellExtent = usableCrossAxisExtent / crossAxisCount;
    return StaggeredGridConfiguration(
      crossAxisCount: crossAxisCount,
      staggeredTileBuilder: staggeredTileBuilder,
      staggeredTileCount: staggeredTileCount,
      cellExtent: cellExtent,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(covariant SliverStaggeredGridDelegateWithMaxCrossAxisExtent oldDelegate) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent || super.shouldRelayout(oldDelegate);
  }
}
