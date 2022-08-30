import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapWidget extends StatefulWidget {

  MapWidget({Key? key}) : super(key: key);  
  @override
  State<StatefulWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {

  final clickPos = ValueNotifier<Offset?>(null);
  PathPainter? painter;

  Future<PathPainter?> loadMap(String map) async {
    var map = Image.asset("assets/map_level_2.png");
    var mapData = await rootBundle.loadString("assets/maps/map_level_2.json");
    painter = PathPainter(repaint: clickPos);
    var iter = jsonDecode(mapData) as List;
var nodes = iter.map((e) => MapNode.fromJson(e)).toList();
    painter!.nodes = nodes;
    return painter;
  }

  Widget build(BuildContext context) {

    var map = Image.asset("assets/map_level_2.png");

    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: Center(
        child: 
          Listener(
            onPointerDown: (event) {
              if(painter == null) {
                return;
              }

              clickPos.value = event.localPosition;
              debugPrint(event.buttons.toString());
              var scaled = Offset(event.localPosition.dx / painter!.prevSize!.width, event.localPosition.dy / painter!.prevSize!.height);

              var copy = painter!.nodes.toList();
              copy.sort((a, b) => (scaled - a.location).distanceSquared.compareTo((scaled - b.location).distanceSquared));
              var nearest = copy.isEmpty ? null : copy.first;

              if(event.buttons == 1) {
                RenderBox? box = context.findRenderObject() as RenderBox?;
                //painter = LinePainter();
                //painter.clickPos = event.localPosition;
                var newNode = MapNode(scaled, {});

                if(painter!.selectedNode != null) {
                  var parentIndex = painter!.nodes.indexOf(painter!.selectedNode!);
                  newNode.siblings.add(parentIndex);
                  painter!.selectedNode!.siblings.add(painter!.nodes.length);
                }

                painter!.nodes.add(newNode);
                painter!.selectedNode = newNode;
              }
              else if(event.buttons == 2 && painter!.nodes.isNotEmpty && nearest != null) {
                var nearIndex = painter!.nodes.indexOf(nearest);
                for(var node in painter!.nodes) {
                  if(node == nearest) {
                    continue;
                  }

                  node.siblings.remove(nearIndex);
                  node.siblings = node.siblings.map((i) => i > nearIndex ? i - 1 : i).toSet();
                }
                painter!.nodes.remove(nearest);

                if(painter!.selectedNode == nearest) {
                  painter!.selectedNode = null;
                }

              }
              else if(event.buttons == 4 && nearest != null) {
                if(painter!.selectedNode == nearest) {
                  var jstest = nearest.toJson();
                  debugPrint(jsonEncode(painter!.nodes));
                }
                painter!.selectedNode = nearest;
              }
              else if(event.buttons == 16 && painter!.selectedNode != null && nearest != null) {
                if(nearest != painter!.selectedNode)
                {
                  var parentIndex = painter!.nodes.indexOf(painter!.selectedNode!);
                  var nearIndex = painter!.nodes.indexOf(nearest);
                  nearest.siblings.add(parentIndex);
                  painter!.selectedNode!.siblings.add(nearIndex);
                }
              }
              else if(event.buttons == 8 && painter!.selectedNode != null && nearest != null) {
                if(nearest != painter!.selectedNode)
                {
                  var parentIndex = painter!.nodes.indexOf(painter!.selectedNode!);
                  var nearIndex = painter!.nodes.indexOf(nearest);
                  nearest.siblings.remove(parentIndex);
                  painter!.selectedNode!.siblings.remove(nearIndex);
                }
              }
            },
            child: FutureBuilder<PathPainter?>(
              future: loadMap("map_level_2"),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return CustomPaint(
                    foregroundPainter: painter,
                    child: map,
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          )
      )
    );
  }

}

class PathPainter extends CustomPainter {

  PathPainter({required Listenable repaint}) : super(repaint: repaint);

  var clickedPoints = <Offset>[

  ];

  MapNode? selectedNode;

  var nodes = <MapNode>[
    MapNode(Offset(.1,.1), {1}),
    MapNode(Offset(.1, .5), {0,2,3}),
    MapNode(Offset(.1, .9), {1}),
    MapNode(Offset(.5, .5), {1, 4, 5, 6}),
    MapNode(Offset(.5, .1), {3}),
    MapNode(Offset(.5, .9), {3}),
    MapNode(Offset(.9, .5), {3,7,8}),
    MapNode(Offset(.9, .1), {6}),
    MapNode(Offset(.9, .9), {6}),

  ];

  Offset? clickPos;
  Size? prevSize;

  @override
  void paint(Canvas canvas, Size size) {
    prevSize = size;
    var p0 = Offset(.05, .5);
    var p1 = Offset(.5, .5);
    final pointMode = PointMode.polygon;
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // var points = [Offset(0,0), Offset(size.width, size.height)];
      
    if(selectedNode != null) {
      // canvas.drawPoints(PointMode.points, [Scale(selectedPoint!.location, size)], Paint() ..color=Colors.orange ..strokeWidth=16);
      canvas.drawCircle(Scale(selectedNode!.location, size), 16, Paint() ..color=Colors.orange ..strokeWidth=4 ..style=PaintingStyle.stroke);
    }
    // canvas.drawPoints(PointMode.polygon, clickedPoints.map((p) => Scale(p, size)).toList(), paint);
    // canvas.drawPoints(PointMode.points, clickedPoints.map((p) => Scale(p, size)).toList(), Paint() ..color = Colors.black ..strokeWidth=2);


    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i];

      n.siblings.forEach((sIndex) {
        if(sIndex > i) {
          canvas.drawPoints(
            PointMode.polygon,
            [
              Scale(n.location, size),
              Scale(nodes[sIndex].location, size)
            ],
            paint
          );
        }
      });
      canvas.drawCircle(Scale(n.location, size), 3, Paint());
    }

    if(clickPos != null) {
      canvas.drawPoints(PointMode.points, [clickPos!], paint);
    }
    
    // var path = nodes[8].Path(nodes, nodes[0]);
    // if(path != null)
    // {
    //   canvas.drawPoints(PointMode.polygon, path.map((e) => Scale(e.location, size)).toList(), paint);
    // }
  }

  Offset Scale(Offset offset, Size size) => Offset(offset.dx * size.width, offset.dy * size.height);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

class MapNode {
  Offset location;
  Set<int> siblings;
  Set<MapNode> siblingNodes(List<MapNode> nodes) => siblings.map<MapNode>((i) => nodes[i]).toSet();

  MapNode? _pathfindingParent;
  
  MapNode(this.location, this.siblings);

  MapNode.fromJson(Map<String, dynamic> json)
    : location = Offset(json['x'], json['y']),
      siblings = (json['siblings'] as List).cast<int>().toSet();

  Map<String, dynamic> toJson() => {
    'x': location.dx,
    'y': location.dy,
    'siblings': siblings.toList()
  };


  double gScore(MapNode? other) {
    if(other == null) {
      return 0;
    }

    return hScore(other);
  }

  double hScore(MapNode target) {
    return (target.location.dx - location.dx).abs() + (target.location.dy - location.dy).abs();
  }

  List<MapNode>? Path(List<MapNode> nodes, MapNode target) {

    if(this == target) {
      return null;
    }

    var openSet = <MapNode>{};
    var closedSet = <MapNode>{};

    openSet.add(this);

    while(openSet.isNotEmpty) {

      MapNode? current;

      double currentGScore = 0;
      double currentHScore = 0;

      for(var node in openSet) {

        if(node == target) {
          //Winner!
          return buildPath(node);
        }

        if(current == null) {
          current = node;
          currentGScore = 0;
          currentHScore = node.hScore(target);
        }
        else {
          var testGScore = node.gScore(node._pathfindingParent);
          var testHScore = node.hScore(target);

          if((currentGScore + currentHScore) > (testGScore + testHScore)) {
            current = node;
            currentGScore = testGScore;
            currentHScore = testHScore;
          }
        }
      }

      if(current == null) {
        return null;
      }

      openSet.remove(current);
      closedSet.add(current);
      for(var sibling in current.siblingNodes(nodes)) {
        if(closedSet.contains(sibling)) {
          continue;
        }
        sibling._pathfindingParent = current;

        if(!openSet.contains(sibling)) {
          openSet.add(sibling);
        }

      }

    }

    return null;
  }

  List<MapNode> buildPath(MapNode node) {
    if(node._pathfindingParent == null) {
      return [node];
    }

    var path = buildPath(node._pathfindingParent!);
    path.add(node);
    return path;

  }
}