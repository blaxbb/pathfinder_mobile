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

class MapNavigateWidgetState extends State<MapNavigateWidget> {

  String target;
  String? location;
  final nodes = ValueNotifier<List<MapNode>>([]);
  var allLocations = <String>{};

  MapNavigateWidgetState(this.target);

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
      location = "West Building, West Entrance";
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
                    SizedBox(width: 8,),
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
                  child: CustomPaint(
                      foregroundPainter: MapNavigatePainter(path),
                      child: Image.asset("assets/maps/${path.first.map}.png"),
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

  MapNavigatePainter(this.path);

  List<MapNode>? path;
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

    //end = nodes.cast<MapNode?>().firstWhere((element) => element!.names.any((name)  => name.contains("208")), orElse: () => null);

    if(path != null)
    {
      canvas.drawPoints(PointMode.polygon, path!.map((e) => scale(e.location, size)).toList(), Paint() ..color=Colors.blue.shade400 ..strokeWidth=4 ..strokeCap=StrokeCap.round);
      var start = path!.first;
      var end = path!.last;

      canvas.drawCircle(scale(start.location, size), 6, Paint() ..color=Colors.green ..strokeWidth=4 ..style=PaintingStyle.stroke);
      canvas.drawCircle(scale(end.location, size), 6, Paint() ..color=Colors.red ..strokeWidth=4 ..style=PaintingStyle.stroke);
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
    return false;
  }

}