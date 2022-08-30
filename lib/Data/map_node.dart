import 'dart:ui';

class MapNode {
  Offset location;
  Set<int> siblings;
  Set<MapNode> siblingNodes(List<MapNode> nodes) => siblings.map<MapNode>((i) => nodes[i]).toSet();
  Set<String> names;

  MapNode? _pathfindingParent;
  
  MapNode(this.location, this.siblings, this.names);

  static List<String> allMaps() {
    return [
      "map_level_1",
      "map_level_2",
    ];
  }

  MapNode.fromJson(Map<String, dynamic> json)
    : location = Offset(json['x'], json['y']),
      siblings = (json['siblings'] as List).cast<int>().toSet(),
      names = json.containsKey('names') ? (json['names'] as List).cast<String>().toSet() : {};

  Map<String, dynamic> toJson() => {
    'x': location.dx,
    'y': location.dy,
    'siblings': siblings.toList(),
    'names': names.toList()
  };


  double _gScore(MapNode? other) {
    if(other == null) {
      return 0;
    }

    return _hScore(other);
  }

  double _hScore(MapNode target) {
    return (target.location.dx - location.dx).abs() + (target.location.dy - location.dy).abs();
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
          return buildPath(node);
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

  List<MapNode> buildPath(MapNode node) {
    if(node._pathfindingParent == null) {
      return [node];
    }

    var path = buildPath(node._pathfindingParent!);
    path.add(node);
    return path;

  }
}