import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/map_node.dart';

class MapEditWidget extends StatefulWidget {

  MapEditWidget({Key? key}) : super(key: key);  
  @override
  State<StatefulWidget> createState() => MapEditWidgetState();
}

class MapEditWidgetState extends State<MapEditWidget> {

  final clickPos = ValueNotifier<Offset?>(null);
  MapEditPainter? painter;

  Future<MapEditPainter?> loadMap(String map) async {
    var map = Image.asset("assets/map_level_2.png");
    var mapData = await rootBundle.loadString("assets/maps/map_level_2.json");

    var iter = jsonDecode(mapData) as List;
    var nodes = iter.map((e) => MapNode.fromJson(e)).toList();

    painter = MapEditPainter(repaint: clickPos);
    painter!.nodes = nodes;

    return painter;
  }

  Widget build(BuildContext context) {

    Image map = Image.asset("assets/map_level_2.png");

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
              var scaled = Offset(event.localPosition.dx / painter!.prevSize!.width, event.localPosition.dy / painter!.prevSize!.height);

              var copy = painter!.nodes.toList();
              copy.sort((a, b) => (scaled - a.location).distanceSquared.compareTo((scaled - b.location).distanceSquared));
              var nearest = copy.isEmpty ? null : copy.first;

              switch (event.buttons) {
                case 1:
                  _addNode(scaled);
                  break;
                case 2:
                  if(painter!.nodes.isNotEmpty && nearest != null) {
                    _removeNode(nearest);
                  }
                  break;
                case 4:
                  if(nearest != null) {
                    _selectNode(nearest);
                  }
                  break;
                case 16:
                  if(painter!.selectedNode != null && nearest != null) {
                    _addLink(nearest);
                  }
                  break;
                case 8:
                  if(painter!.selectedNode != null && nearest != null) {
                    _removeLink(nearest);
                  }
                  break;
              }
            },
            child: FutureBuilder<MapEditPainter?>(
              future: loadMap("map_level_2"),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return CustomPaint(
                    foregroundPainter: painter,
                    child: map,
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          )
      )
    );
  }

  void _addNode(Offset scaled) {
    var newNode = MapNode(scaled, {});
    
    if(painter!.selectedNode != null) {
      var parentIndex = painter!.nodes.indexOf(painter!.selectedNode!);
      newNode.siblings.add(parentIndex);
      painter!.selectedNode!.siblings.add(painter!.nodes.length);
    }
    
    painter!.nodes.add(newNode);
    painter!.selectedNode = newNode;
  }

  void _removeNode(MapNode nearest) {
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

  void _selectNode(MapNode nearest) {
    if(painter!.selectedNode == nearest) {
      debugPrint(jsonEncode(painter!.nodes));
      painter!.selectedNode = null;
    }
    else {
      painter!.selectedNode = nearest;
    }
  }

  void _addLink(MapNode nearest) {
    if(nearest != painter!.selectedNode)
    {
      var parentIndex = painter!.nodes.indexOf(painter!.selectedNode!);
      var nearIndex = painter!.nodes.indexOf(nearest);
      nearest.siblings.add(parentIndex);
      painter!.selectedNode!.siblings.add(nearIndex);
    }
  }

  void _removeLink(MapNode nearest) {
    if(nearest != painter!.selectedNode)
    {
      var parentIndex = painter!.nodes.indexOf(painter!.selectedNode!);
      var nearIndex = painter!.nodes.indexOf(nearest);
      nearest.siblings.remove(parentIndex);
      painter!.selectedNode!.siblings.remove(nearIndex);
    }
  }

}

class MapEditPainter extends CustomPainter {

  MapEditPainter({required Listenable repaint}) : super(repaint: repaint);

  var clickedPoints = <Offset>[

  ];

  MapNode? selectedNode;

  var nodes = <MapNode>[];

  Offset? clickPos;
  Size? prevSize;

  @override
  void paint(Canvas canvas, Size size) {
    prevSize = size;

    if(selectedNode != null) {
      canvas.drawCircle(scale(selectedNode!.location, size), 16, Paint() ..color=Colors.orange ..strokeWidth=4 ..style=PaintingStyle.stroke);
    }


//draw all nodes
    for (var i = 0; i < nodes.length; i++) {
      var n = nodes[i];

      for (var sIndex in n.siblings) {
        if(sIndex > i) {
          canvas.drawPoints(
            PointMode.polygon,
            [
              scale(n.location, size),
              scale(nodes[sIndex].location, size)
            ],
            Paint()
              ..color = Colors.green
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round
          );
        }
      }
      canvas.drawCircle(scale(n.location, size), 3, Paint());
    }
    
    // var path = nodes[0].Path(nodes, nodes[13]);
    // if(path != null)
    // {
    //   canvas.drawPoints(PointMode.polygon, path.map((e) => Scale(e.location, size)).toList(), Paint() ..color=Colors.red ..strokeWidth=8);
    // }
  }

  Offset scale(Offset offset, Size size) => Offset(offset.dx * size.width, offset.dy * size.height);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}