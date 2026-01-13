class StaggeredTile {
  /// 创建一个具有给定 [crossAxisCellCount]（交叉轴单元格数）和
  /// [mainAxisCellCount]（主轴单元格数）的 [StaggeredTile]。
  ///
  /// 此 tile 的主轴范围将是 [mainAxisCellCount] 个单元格的长度（包括内部间距）。
  const StaggeredTile.count(this.crossAxisCellCount, this.mainAxisCellCount)
      : assert(crossAxisCellCount >= 0),
        assert(mainAxisCellCount != null && mainAxisCellCount >= 0),
        mainAxisExtent = null;

  /// 创建一个具有给定 [crossAxisCellCount] 和 [mainAxisExtent] 的 [StaggeredTile]。
  ///
  /// 此 tile 将具有固定的主轴范围。
  const StaggeredTile.extent(this.crossAxisCellCount, this.mainAxisExtent)
      : assert(crossAxisCellCount >= 0),
        assert(mainAxisExtent != null && mainAxisExtent >= 0),
        mainAxisCellCount = null;

  /// 创建一个具有给定 [crossAxisCellCount] 的 [StaggeredTile]，
  /// 其主轴范围适应其内容。
  ///
  /// 此 tile 将具有固定的主轴范围。
  const StaggeredTile.fit(this.crossAxisCellCount)
      : assert(crossAxisCellCount >= 0),
        mainAxisExtent = null,
        mainAxisCellCount = null;

  /// 交叉轴上占用的单元格数。
  final int crossAxisCellCount;

  /// 主轴上占用的单元格数。
  final double? mainAxisCellCount;

  /// 主轴上占用的像素数。
  final double? mainAxisExtent;

  bool get fitContent => mainAxisCellCount == null && mainAxisExtent == null;
}
