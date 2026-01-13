import 'package:flutter/widgets.dart';
import 'package:staggered_grid/src/rendering/sliver_staggered_grid.dart';
import 'package:staggered_grid/src/widgets/sliver.dart';
import 'package:staggered_grid/src/widgets/staggered_tile.dart';

class StaggeredGridView extends BoxScrollView {
  StaggeredGridView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    List<Widget> children = const <Widget>[],
    super.restorationId,
  }) : childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// 创建一个可滚动的、按需创建的二维 Widget 数组。
  ///
  /// 此构造函数适用于具有大量（或无限）子项的网格视图，
  /// 因为仅对实际可见的那些子项调用构建器。
  ///
  /// 提供非空的 [itemCount] 可以提高 [SliverStaggeredGridDelegate]
  /// 估计最大滚动范围的能力。
  ///
  /// [itemBuilder] 仅在索引大于或等于零且小于 [itemCount] 时被调用。
  ///
  /// [gridDelegate] 参数不能为空。
  ///
  /// `addAutomaticKeepAlives` 参数对应于
  /// [SliverVariableSizeChildBuilderDelegate.addAutomaticKeepAlives] 属性。
  /// `addRepaintBoundaries` 参数对应于
  /// [SliverVariableSizeChildBuilderDelegate.addRepaintBoundaries] 属性。
  /// 两者都不能为 null。
  StaggeredGridView.builder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required this.gridDelegate,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    super.restorationId,
  }) : childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// 创建一个可滚动的二维 Widget 数组，同时使用自定义的
  /// [SliverStaggeredGridDelegate] 和 [SliverVariableSizeChildDelegate]。
  ///
  /// 要使用 [IndexedWidgetBuilder] 回调构建子项，请使用
  /// [SliverVariableSizeChildBuilderDelegate] 或使用
  /// [SliverStaggeredGridDelegate.builder] 构造函数。
  ///
  /// [gridDelegate] 和 [childrenDelegate] 参数不能为空。
  const StaggeredGridView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.restorationId,
    required this.gridDelegate,
    required this.childrenDelegate,
    this.addAutomaticKeepAlives = true,
  });

  /// 创建一个可滚动的、具有固定交叉轴 tile 数量的可变大小 Widget 的二维数组。
  ///
  /// 使用 [SliverStaggeredGridDelegateWithFixedCrossAxisCount] 作为 [gridDelegate]。
  ///
  /// `addAutomaticKeepAlives` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] 属性。
  /// `addRepaintBoundaries` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] 属性。
  /// 两者都不能为 null。
  ///
  /// 参见:
  ///
  ///  * [SliverGrid.count]，[SliverGrid] 的等效构造函数。
  StaggeredGridView.count({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    super.restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles.length,
        ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// 创建一个可滚动的、具有固定交叉轴 tile 数量的、按需创建的可变大小 Widget 的二维数组。
  ///
  /// 此构造函数适用于具有大量（或无限）子项的网格视图，
  /// 因为仅对实际可见的那些子项调用构建器。
  ///
  /// 使用 [SliverStaggeredGridDelegateWithFixedCrossAxisCount] 作为 [gridDelegate]。
  ///
  /// 提供非空的 [itemCount] 可以提高 [SliverStaggeredGridDelegate]
  /// 估计最大滚动范围的能力。
  ///
  /// [itemBuilder] 和 [staggeredTileBuilder] 仅在索引大于或等于零且小于 [itemCount] 时被调用。
  ///
  /// `addAutomaticKeepAlives` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] 属性。
  /// `addRepaintBoundaries` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] 属性。
  /// 两者都不能为 null。
  StaggeredGridView.countBuilder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required int crossAxisCount,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    int? itemCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    super.restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// 创建一个可滚动的、具有每个 tile 都有最大交叉轴范围的可变大小 Widget 的二维数组。
  ///
  /// 使用 [SliverGridDelegateWithMaxCrossAxisExtent] 作为 [gridDelegate]。
  ///
  /// 提供非空的 [itemCount] 可以提高 [SliverStaggeredGridDelegate]
  /// 估计最大滚动范围的能力。
  ///
  /// [itemBuilder] 和 [staggeredTileBuilder] 仅在索引大于或等于零且小于 [itemCount] 时被调用。
  ///
  /// `addAutomaticKeepAlives` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] 属性。
  /// `addRepaintBoundaries` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] 属性。
  /// 两者都不能为 null。
  ///
  /// 参见:
  ///
  ///  * [SliverGrid.extent]，[SliverGrid] 的等效构造函数。
  StaggeredGridView.extent({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    List<Widget> children = const <Widget>[],
    List<StaggeredTile> staggeredTiles = const <StaggeredTile>[],
    super.restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: (i) => staggeredTiles[i],
          staggeredTileCount: staggeredTiles.length,
        ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// 创建一个可滚动的、具有每个 tile 都有最大交叉轴范围的、按需创建的可变大小 Widget 的二维数组。
  ///
  /// 此构造函数适用于具有大量（或无限）子项的网格视图，
  /// 因为仅对实际可见的那些子项调用构建器。
  ///
  /// 使用 [SliverGridDelegateWithMaxCrossAxisExtent] 作为 [gridDelegate]。
  ///
  /// `addAutomaticKeepAlives` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] 属性。
  /// `addRepaintBoundaries` 参数对应于
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] 属性。
  /// 两者都不能为 null。
  ///
  /// 参见:
  ///
  ///  * [SliverGrid.extent]，[SliverGrid] 的等效构造函数。
  StaggeredGridView.extentBuilder({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    required double maxCrossAxisExtent,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedStaggeredTileBuilder staggeredTileBuilder,
    int? itemCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    this.addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    super.restorationId,
  })  : gridDelegate = SliverStaggeredGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          staggeredTileBuilder: staggeredTileBuilder,
          staggeredTileCount: itemCount,
        ),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
        );

  /// 控制 [StaggeredGridView] 中子项布局的代理。
  ///
  /// [StaggeredGridView] 和 [StaggeredGridView.custom] 构造函数允许你明确指定此代理。
  /// 其他构造函数隐式创建 [gridDelegate]。
  final SliverStaggeredGridDelegate gridDelegate;

  /// 为 [StaggeredGridView] 提供子项的代理。
  ///
  /// [StaggeredGridView.custom] 构造函数允许你明确指定此代理。
  /// 其他构造函数创建一个包装给定子列表的 [childrenDelegate]。
  final SliverChildDelegate childrenDelegate;

  /// 是否为子项添加保持存活功能
  final bool addAutomaticKeepAlives;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverStaggeredGrid(
      delegate: childrenDelegate,
      gridDelegate: gridDelegate,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
    );
  }
}
