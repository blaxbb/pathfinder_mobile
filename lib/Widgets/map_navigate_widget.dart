import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/map_node.dart';

class MapNavigateWidget extends StatefulWidget {
  String target;

  MapNavigateWidget(this.target, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapNavigateWidgetState(target);

}

class MapNavigateWidgetState extends State<MapNavigateWidget>
  with SingleTickerProviderStateMixin {

  String target;
  String? location;
  final nodes = ValueNotifier<List<MapNode>>([]);
  var allLocations = <String>{};

  late AnimationController _animation;

  MapNavigateWidgetState(this.target);

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this) ..duration=Duration(seconds: 2) ..addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 1), () {
          _animation.forward(from: 0);
        });
      }
    });
  }

  @override void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _animation.stop();
    _animation.reset();
    _animation.forward(from: 0);
    // _animation.repeat(
    //   period: Duration(seconds: 2),
    // );
  }

  Future<List<List<MapNode>>?> buildPath() async {

    nodes.value = [];
    for(var mapName in MapNode.allMaps()) {
      var data = await MapNode.load(mapName);
      for(var node in data) {
        node.siblings = node.siblings.map((e) => e + nodes.value.length).toSet();
      }
      nodes.value.addAll(data);
    }

    allLocations = nodes.value.map((n) => n.names.isNotEmpty ? n.names.first : "").toSet();
    allLocations.remove("");
    var tmp = allLocations.toList();
    tmp.sort((a,b) => a.compareTo(b));
    allLocations = tmp.toSet();

    if(location == null && allLocations.isNotEmpty) {
      location = "Pathfinders";
    }

    var path = MapNode.buildPath(nodes.value, location ?? "", target);
    var paths = path == null ? null : MapNode.splitPath(path);

    return paths;
  }

  MapNode? findNode(List<MapNode> nodes, String name) {
    return nodes.cast<MapNode?>().firstWhere((element) => element!.names.any((n)  => n.contains(name)), orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    _startAnimation();
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigate to $target"),
      ),
      body: FutureBuilder<List<List<MapNode>>?>(
        future: buildPath(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text("Navigation Error");
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("Navigate From: "),
                    Expanded(
                      child: DropdownButton<String>(
                        value: location,
                        items: allLocations.map((e) => DropdownMenuItem(child: Text(e), value: e,)).toList(),
                        onChanged: ((value) {setState(() {
                          location = value;
                          nodes.notifyListeners();
                        });})
                      ),
                    ),
                  ],
                ),
              ),
              ...(snapshot.data?.map((path) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InteractiveViewer(
                    panEnabled: false,
                    minScale: .1,
                    maxScale: 4,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: (MediaQuery.of(context).size.height * .6)),
                        child: CustomPaint(
                            foregroundPainter: MapNavigatePainter(path, _animation),
                            child: Image.asset("assets/maps/${path.first.map}.jpg", fit: BoxFit.fill),
                          ),
                      ),
                    ),
                  ),
                );
              }).toList()) ?? []
            ],
          );
        },
      )
    );
  }

}

class MapNavigatePainter extends CustomPainter {

  final Animation<double> _animation;

  MapNavigatePainter(this.path, this._animation) : super(repaint: _animation);

  List<MapNode>? path;
  Size? prevSize;

  @override
  void paint(Canvas canvas, Size size) {
    prevSize = size;

    var p = Path();
    if(path != null)
    {
      p.addPolygon(path!.map((e) => scale(e.location, size)).toList(), false);

      var animated = createAnimatedPath(p, _animation.value);
      canvas.drawPath(animated, Paint() ..color=Colors.blue.shade400 ..strokeWidth=5 ..strokeCap=StrokeCap.round ..style=PaintingStyle.stroke);
      
      var start = path!.first;
      var end = path!.last;

      canvas.drawCircle(scale(start.location, size), 12, Paint() ..color=Colors.blue ..strokeWidth=5 ..style=PaintingStyle.stroke);
      canvas.drawCircle(scale(end.location, size), 12, Paint() ..color=Colors.red ..strokeWidth=5 ..style=PaintingStyle.stroke);
    }
  }

  Offset scale(Offset offset, Size size) => Offset(offset.dx * size.width, offset.dy * size.height);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  //https://stackoverflow.com/a/54697903/14645624
  Path createAnimatedPath(Path originalPath, double animationPercent) {
    // ComputeMetrics can only be iterated once!
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    return extractPathUntilLength(originalPath, currentLength);
  }  

  Path extractPathUntilLength(Path originalPath, double length) {
    var currentLength = 0.0;

    final path = new Path();

    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;

      var nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        // There might be a more efficient way of extracting an entire path
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }

}