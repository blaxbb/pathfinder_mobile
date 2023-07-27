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
  String nameValue = "";
  
  MapNode? selectedNode;
  List<MapNode>? nodes;

  String mapName = "map_level_1_2023";
  String? prevMap = null;

  Future<MapEditPainter?> loadMap(String map) async {
    var mapImage = Image.asset("assets/maps/$map.jpg");
    var mapData = await rootBundle.loadString("assets/maps/$map.json");

    if(nodes == null || mapName != prevMap) {
      var iter = jsonDecode(mapData) as List;
      var jsonNodes = iter.map((e) => MapNode.fromJson(e)).toList();
      nodes = jsonNodes;
    }

    prevMap = mapName;

    painter = MapEditPainter(repaint: clickPos);
    painter!.nodes = nodes!;
    painter!.selectedNode = selectedNode;

    return painter;
  }

  Widget build(BuildContext context) {

    Image map = Image.asset("assets/maps/$mapName.jpg");

    var connectMapController = TextEditingController(
      text: selectedNode?.connectMap
    );

    connectMapController.addListener(() {
      if(selectedNode != null) {
        selectedNode!.connectMap = connectMapController.text.isEmpty ? null : connectMapController.text;
        debugPrint(selectedNode!.connectMap);
      }
    });

    var connectNodeController = TextEditingController(
      text: selectedNode?.connectNode
    );

    connectNodeController.addListener(() {
      if(selectedNode != null) {
        selectedNode!.connectNode = connectNodeController.text.isEmpty ? null : connectNodeController.text;
        debugPrint(selectedNode!.connectNode);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: Center(
        child: 
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  items: MapNode.allMaps().map(
                    (e) => DropdownMenuItem(value: e, child: Text(e))
                  ).toList(),
                  onChanged: (value) => setState(() {
                    mapName = value!;
                    selectedNode = null;
                  }),
                  value: mapName,
                ),
              ),
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
                      if(selectedNode != null && nearest != null) {
                        _addLink(nearest);
                      }
                      break;
                    case 8:
                      if(selectedNode != null && nearest != null) {
                        _removeLink(nearest);
                      }
                      break;
                  }

                  setState(() {
                    
                  });
                },
                child: FutureBuilder<MapEditPainter?>(
                  future: loadMap(mapName),
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Connected Map"),
                    ),
                    Flexible(
                      child: TextField(
                        controller: connectMapController,
                      )
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Connected Node"),
                    ),
                    Flexible(
                      child: TextField(
                        controller: connectNodeController,
                      )
                    )
                  ],
                ),
              ),              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            nameValue = value;
                          });
                        }
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          selectedNode?.names.add(nameValue);
                        });
                      },
                    ),
                  ],
                ),
              ),
              Divider(),
              ...(selectedNode?.names.map((e) => 
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text(e)),
                          IconButton(
                            onPressed: (){
                              setState(() {
                               selectedNode!.names.remove(e);
                              });
                             },
                            icon: Icon(Icons.delete)
                          )
                        ]
                      ),
                    )
                  ) ?? [])
            ],
          )
      )
    );
  }

  void _addNode(Offset scaled) {
    var newNode = MapNode(scaled, {}, {});
    
    if(selectedNode != null) {
      var parentIndex = painter!.nodes.indexOf(selectedNode!);
      newNode.siblings.add(parentIndex);
      selectedNode!.siblings.add(painter!.nodes.length);
    }
    
    painter!.nodes.add(newNode);
    selectedNode = newNode;
    painter!.selectedNode = selectedNode;
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
    
    if(selectedNode == nearest) {
      selectedNode = null;
    }
    painter!.selectedNode = selectedNode;  
  }

  void _selectNode(MapNode nearest) {
    if(selectedNode == nearest) {
      debugPrint(jsonEncode(painter!.nodes));
      selectedNode = null;
    }
    else {
      selectedNode = nearest;
    }
    painter!.selectedNode = selectedNode;
  }


  void _addLink(MapNode nearest) {
    if(nearest != selectedNode)
    {
      var parentIndex = painter!.nodes.indexOf(selectedNode!);
      var nearIndex = painter!.nodes.indexOf(nearest);
      nearest.siblings.add(parentIndex);
      selectedNode!.siblings.add(nearIndex);
    }
    painter!.selectedNode = selectedNode;
  }

  void _removeLink(MapNode nearest) {
    if(nearest != selectedNode)
    {
      var parentIndex = painter!.nodes.indexOf(selectedNode!);
      var nearIndex = painter!.nodes.indexOf(nearest);
      nearest.siblings.remove(parentIndex);
      selectedNode!.siblings.remove(nearIndex);
    }
    painter!.selectedNode = selectedNode;
  }

}

class MapEditPainter extends CustomPainter {

  MapEditPainter({required Listenable repaint}) : super(repaint: repaint);

  MapNode? selectedNode;
  var clickedPoints = <Offset>[

  ];

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
    
    // var path = nodes[0].path(nodes, nodes[13]);
    // if(path != null)
    // {
    //   canvas.drawPoints(PointMode.polygon, path.map((e) => scale(e.location, size)).toList(), Paint() ..color=Colors.red ..strokeWidth=8);
    // }
  }

  Offset scale(Offset offset, Size size) => Offset(offset.dx * size.width, offset.dy * size.height);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}