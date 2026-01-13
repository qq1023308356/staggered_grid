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

  /// Creates a scrollable, 2D array of widgets that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] improves the ability of the
  /// [SliverStaggeredGridDelegate] to estimate the maximum scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
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

  /// Creates a scrollable, 2D array of widgets with both a custom
  /// [SliverStaggeredGridDelegate] and a custom [SliverVariableSizeChildDelegate].
  ///
  /// To use an [IndexedWidgetBuilder] callback to build children, either use
  /// a [SliverVariableSizeChildBuilderDelegate] or use the
  /// [SliverStaggeredGridDelegate.builder] constructor.
  ///
  /// The [gridDelegate] and [childrenDelegate] arguments must not be null.
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

  /// Creates a scrollable, 2D array of widgets of variable sizes with a fixed
  /// number of tiles in the cross axis.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.count], the equivalent constructor for [SliverGrid].
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

  /// Creates a scrollable, 2D array of widgets of variable sizes with a fixed
  /// number of tiles in the cross axis that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverStaggeredGridDelegateWithFixedCrossAxisCount] as the
  /// [gridDelegate].
  ///
  ///  Providing a non-null [itemCount] improves the ability of the
  /// [SliverStaggeredGridDelegate] to estimate the maximum scroll extent.
  ///
  /// [itemBuilder] and [staggeredTileBuilder] will be called only with
  /// indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
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

  /// Creates a scrollable, 2D array of widgets of variable sizes with tiles
  /// that  each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate].
  ///
  ///  Providing a non-null [itemCount] improves the ability of the
  /// [SliverStaggeredGridDelegate] to estimate the maximum scroll extent.
  ///
  /// [itemBuilder] and [staggeredTileBuilder] will be called only with
  /// indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.extent], the equivalent constructor for [SliverGrid].
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

  /// Creates a scrollable, 2D array of widgets of variable sizes with tiles
  /// that  each have a maximum cross-axis extent that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Uses a [SliverGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverVariableSizeChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.extent], the equivalent constructor for [SliverGrid].
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

  /// A delegate that controls the layout of the children within the
  /// [StaggeredGridView].
  ///
  /// The [StaggeredGridView] and [StaggeredGridView.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverStaggeredGridDelegate gridDelegate;

  /// A delegate that provides the children for the [StaggeredGridView].
  ///
  /// The [StaggeredGridView.custom] constructor lets you specify this delegate
  /// explicitly. The other constructors create a [childrenDelegate] that wraps
  /// the given child list.
  final SliverChildDelegate childrenDelegate;

  /// Whether to add keepAlives to children
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
