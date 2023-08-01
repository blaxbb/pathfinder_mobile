import 'package:pathfinder_mobile/Data/session.dart';
import 'package:html/dom.dart';

class Presentation {
  TimeSlot? timeSlot;

  String? Title;
  List<Tag> registrationLevels() => Tags?["registration-category"] ?? [];
  List<Tag> keywords() => Tags?["keyword"] ?? [];
  List<Tag> interestAreas() => Tags?["interest-area"] ?? [];
  List<Tag> recordingStatus() => Tags?["recording"] ?? [];
  Map<String, List<Tag>>? Tags = {};

  List<String?> speakers = [];

  Presentation.FromElement(Element element) {

    Title = element.querySelector(".title-speakers-td > a")?.innerHtml ?? '';

    var start = element.querySelector(".start-time")?.attributes['utc_time'];
    var end = element.querySelector(".end-time")?.attributes['utc_time'];
    if (start != null && end != null) {
      timeSlot = TimeSlot(
          startTime: StartTime.fromUtc(DateTime.parse(start)),
          endTime: StartTime.fromUtc(DateTime.parse(end))
      );
    }
    else {
      timeSlot = TimeSlot();
    }

    var tagGroups = element.querySelectorAll('.tag-group-list');
    for(var group in tagGroups) {

      var groupName = group.classes.first;

      var tags = <Tag>[];
      var tagElements = group.querySelectorAll('.program-track');

      for(var tagElement in tagElements) {
        var tag = Tag.FromElement(tagElement);
        tags.add(tag);
      }

      speakers = element.querySelectorAll(".presenter-name a").map((e) => e.innerHtml).toList();

      Tags![groupName] = tags;
    }    
  }
}