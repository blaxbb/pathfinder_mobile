import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/map_node.dart';

class MapNavigateWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapNavigateWidgetState();

}

class MapNavigateWidgetState extends State<MapNavigateWidget> {

  String? location = "101";
  MapNavigatePainter? painter;
  final nodes = ValueNotifier<List<MapNode>>([]);

  Future<MapNavigatePainter?> loadMap(String map) async {
    var map = Image.asset("assets/map_level_2.png");
    var mapData = await rootBundle.loadString("assets/maps/map_level_2.json");

    var iter = jsonDecode(mapData) as List;
    var nodes = iter.map((e) => MapNode.fromJson(e)).toList();

    painter = MapNavigatePainter(repaint: this.nodes);
    this.nodes.value = nodes;
    painter!.nodes = nodes;

    return painter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigate"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: location,
              
              items: ["100", "101", "102"].map((e) => DropdownMenuItem(child: Text(e), value: e,)).toList(),
              onChanged: ((value) {setState(() {
                location = value;
                nodes.notifyListeners();
              });})
            ),
          ),
          FutureBuilder<MapNavigatePainter?>(
            future: loadMap("map_level_2"),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                  return CustomPaint(
                    foregroundPainter: painter,
                    child: Image.asset("assets/map_level_2.png"),
                  );
                }
                return const CircularProgressIndicator();
            },
          )
          
        ],
      )
    );
  }

}

class MapNavigatePainter extends CustomPainter {

  MapNavigatePainter({required Listenable repaint}) : super(repaint: repaint);

  var clickedPoints = <Offset>[

  ];

  var nodes = <MapNode>[];
  MapNode? start;
  MapNode? end;

  Offset? clickPos;
  Size? prevSize;

  @override
  void paint(Canvas canvas, Size size) {
    prevSize = size;


//draw all nodes
    // for (var i = 0; i < nodes.length; i++) {
    //   var n = nodes[i];

    //   for (var sIndex in n.siblings) {
    //     if(sIndex > i) {
    //       canvas.drawPoints(
    //         PointMode.polygon,
    //         [
    //           scale(n.location, size),
    //           scale(nodes[sIndex].location, size)
    //         ],
    //         Paint()
    //           ..color = Colors.green
    //           ..strokeWidth = 4
    //           ..strokeCap = StrokeCap.round
    //       );
    //     }
    //   }
    //   canvas.drawCircle(scale(n.location, size), 3, Paint());
    // }

    if(start != null && end != null) {
      var path = start!.path(nodes, end!);
      if(path != null)
      {
        canvas.drawPoints(PointMode.polygon, path.map((e) => scale(e.location, size)).toList(), Paint() ..color=Colors.red ..strokeWidth=8 ..strokeCap=StrokeCap.round);
      }
    }
    
    // int s = 0;
    // int f = 13;
    // if(nodes.isNotEmpty && nodes.length > s && nodes.length > f)
    // {
    //   var path = nodes[s].path(nodes, nodes[f]);
    //   if(path != null)
    //   {
    //     canvas.drawPoints(PointMode.polygon, path.map((e) => scale(e.location, size)).toList(), Paint() ..color=Colors.red ..strokeWidth=8 ..strokeCap=StrokeCap.round);
    //   }
    // }
  }

  Offset scale(Offset offset, Size size) => Offset(offset.dx * size.width, offset.dy * size.height);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}