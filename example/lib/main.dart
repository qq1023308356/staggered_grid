import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:staggered_grid/staggered_grid.dart';

// 假设你提供的代码保存在这个文件中，或者你可以直接把上面的类定义和下面的代码放在同一个文件里
// import 'staggered_grid_view.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      home: StaggeredGridDemoHome(),
    ),
  );
}

class StaggeredGridDemoHome extends StatefulWidget {
  const StaggeredGridDemoHome({super.key});

  @override
  State<StaggeredGridDemoHome> createState() => _StaggeredGridDemoHomeState();
}

class _StaggeredGridDemoHomeState extends State<StaggeredGridDemoHome> {
  @override
  Widget build(BuildContext context) {
    return MasonryDemo();
  }
}

class MasonryDemo extends StatefulWidget {
  const MasonryDemo({super.key});

  @override
  State<MasonryDemo> createState() => _MasonryDemoState();
}

class _MasonryDemoState extends State<MasonryDemo> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLoading = !_isLoading;
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('动态瀑布流 Demo (.builder)')),
        backgroundColor: Colors.grey[200],
        body: CustomScrollView(
          slivers: [
            SliverStaggeredGrid.countBuilder(
              itemCount: 60, // 列表长度
              itemBuilder: (context, index) {
                return _ImageTile(index: index);
              },
              crossAxisCount: 4,
              staggeredTileBuilder: (index) {
                // 模拟：根据 index 随机生成高度，制造高低错落的效果
                // 这里使用了 .count(x, y)，其中 y 是高度份数。
                // 也可以使用 .fit(x) 让 Item 高度随内容自适应（如果你的组件支持 fit 逻辑完备的话）。
                // 为了演示稳定性，这里根据 index 模运算模拟“随机”高度
                final heightCount = (index % 3 + 1).toDouble(); // 高度为 1.5, 3.0, 4.5 份
                // 使用 .fit，第二个参数不仅不需要，而且它会自动计算高度
                // 确保强转为 num 或 double，并处理空值
                if (_isLoading) {
                  return StaggeredTile.count(index % 2 == 0 ? 2 : 1, heightCount);
                }
                return StaggeredTile.count(index % 2 == 0 ? 1 : 2, heightCount);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 辅助组件：简单的色块 Tile
// -----------------------------------------------------------------------------
class _Tile extends StatelessWidget {
  final int index;
  final Color color;
  final IconData icon;
  final String title;

  const _Tile({required this.index, required this.color, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 辅助组件：模拟图片的 Tile
// -----------------------------------------------------------------------------
class _ImageTile extends StatelessWidget {
  final int index;

  const _ImageTile({required this.index});

  @override
  Widget build(BuildContext context) {
    print('11111111111 $index');
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.primaries[index % Colors.primaries.length],
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white70, fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Item Title $index", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Description text...", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
