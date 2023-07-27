import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

class MapNode {
  Offset location;
  Set<int> siblings;
  Set<MapNode> siblingNodes(List<MapNode> nodes) {
    if(connectMap != null && connectMap!.isNotEmpty && connectNode != null && connectNode!.isNotEmpty) {
      var node = findNode(nodes, "$connectMap$connectNode");
      if(node != null) {
        return {
          ...siblings.map<MapNode>((i) => nodes[i]).toSet(),
          node
        };
      }
    }
    
    return {
      ...siblings.map<MapNode>((i) => nodes[i]).toSet()
    };
  }
  Set<String> names;

  String? connectMap;
  String? connectNode;

  String? map;

  MapNode? _pathfindingParent;
  
  MapNode(this.location, this.siblings, this.names);

  static List<String> allMaps() {
    return [
      "map_level_1_2023",
      "map_level_2_2023"
    ];
  }

  MapNode.fromJson(Map<String, dynamic> json)
    : location = Offset(json['x'], json['y']),
      siblings = (json['siblings'] as List).cast<int>().toSet(),
      names = json.containsKey('names') ? (json['names'] as List).cast<String>().toSet() : {},
      connectMap = json.containsKey('connectMap') ? json['connectMap'] as String? : null,
      connectNode = json.containsKey('connectNode') ? json['connectNode'] as String? : null;

  Map<String, dynamic> toJson() => {
    'x': location.dx,
    'y': location.dy,
    'siblings': siblings.toList(),
    'names': names.toList(),
    'connectMap': connectMap,
    'connectNode': connectNode
  };

  static MapNode? findNode(List<MapNode> nodes, String name) {
    return nodes.cast<MapNode?>().firstWhere((element) => element!.names.any((n)  => n.contains(name)), orElse: () => null);
  }

  static Future<List<MapNode>> load(String filename) async {
    var mapData = await rootBundle.loadString("assets/maps/$filename.json");

    var iter = jsonDecode(mapData) as List;
    return iter.map((e) => MapNode.fromJson(e) ..map = filename).toList();
  }

  double _gScore(MapNode? other) {
    if(other == null) {
      return 0;
    }

    return _hScore(other);
  }

  double _hScore(MapNode target) {
    if(target.map != map) {
      return 1;
    }
    return (target.location.dx - location.dx).abs() + (target.location.dy - location.dy).abs();
  }

  static List<MapNode>? buildPath(List<MapNode> nodes, String start, String end) {
    var startNode = MapNode.findNode(nodes, start);
    if(startNode == null) {
      return null;
    }

    var targetNode = MapNode.findNode(nodes, end);
    if(targetNode == null) {
      return null;
    }

    return startNode.path(nodes, targetNode);
  }

  static List<List<MapNode>> splitPath(List<MapNode> path) {
    var split = <List<MapNode>>[];
    var tmp = <MapNode>[];
    for(int i = 0; i + 1 < path.length; i++) {
      var current = path[i];
      var next = path[i + 1];
      
      tmp.add(current);

      if(current.connectMap == null || current.connectNode == null || next.names.isEmpty) {
        continue;
      }

      if("${current.connectMap}${current.connectNode}" == next.names.first) {
        //SPLIT
        split.add(tmp);
        tmp = [];
      }
    }

    tmp.add(path.last);

    split.add(tmp);

    return split;
  }

  List<MapNode>? path(List<MapNode> nodes, MapNode target) {

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
          return _buildPath(node);
        }

        if(current == null) {
          current = node;
          currentGScore = 0;
          currentHScore = node._hScore(target);
        }
        else {
          var testGScore = node._gScore(node._pathfindingParent);
          var testHScore = node._hScore(target);

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

  List<MapNode> _buildPath(MapNode node) {
    if(node._pathfindingParent == null) {
      return [node];
    }

    var path = _buildPath(node._pathfindingParent!);
    path.add(node);
    return path;

  }
}