class StaggeredTile {
  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisCellCount].
  ///
  /// The main axis extent of this tile will be the length of
  /// [mainAxisCellCount] cells (inner spacings included).
  const StaggeredTile.count(this.crossAxisCellCount, this.mainAxisCellCount)
      : assert(crossAxisCellCount >= 0),
        assert(mainAxisCellCount != null && mainAxisCellCount >= 0),
        mainAxisExtent = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] and
  /// [mainAxisExtent].
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.extent(this.crossAxisCellCount, this.mainAxisExtent)
      : assert(crossAxisCellCount >= 0),
        assert(mainAxisExtent != null && mainAxisExtent >= 0),
        mainAxisCellCount = null;

  /// Creates a [StaggeredTile] with the given [crossAxisCellCount] that
  /// fit its main axis extent to its content.
  ///
  /// This tile will have a fixed main axis extent.
  const StaggeredTile.fit(this.crossAxisCellCount)
      : assert(crossAxisCellCount >= 0),
        mainAxisExtent = null,
        mainAxisCellCount = null;

  /// The number of cells occupied in the cross axis.
  final int crossAxisCellCount;

  /// The number of cells occupied in the main axis.
  final double? mainAxisCellCount;

  /// The number of pixels occupied in the main axis.
  final double? mainAxisExtent;

  bool get fitContent => mainAxisCellCount == null && mainAxisExtent == null;
}
