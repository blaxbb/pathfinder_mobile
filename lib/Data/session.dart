import 'package:html/dom.dart' as html;

import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

class Session {
  String? links;
  int? sessionTypeId;
  String? description;
  String? title;
  String? id;
  bool? enabled;
  TimeSlot? timeSlot;

  Map<String, List<Tag>>? Tags = {};
  String? EventType;
  String? Location;

  List<Tag> registrationLevels() => Tags?["registration-category"] ?? [];
  List<Tag> keywords() => Tags?["keyword"] ?? [];
  List<Tag> interestAreas() => Tags?["interest-area"] ?? [];
  List<Tag> recordingStatus() => Tags?["recording"] ?? [];

  Session(
      {this.links,
      this.sessionTypeId,
      this.description,
      this.title,
      this.id,
      this.enabled,
      this.timeSlot,
      this.EventType,
      this.Location,
      this.Tags});

  Session.fromHtml(html.Element element) {
    title = element.querySelector(".agenda-item a")?.text ?? "";
    links = element.querySelector(".agenda-item a")?.attributes['href'] ?? "";
    id = element.attributes['psid'];
    if (element.attributes.containsKey('style') &&
        element.attributes['style']!.contains('display: none')) {
      enabled = false;
    } else {
      enabled = true;
    }

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


      Tags![groupName] = tags;
    }

    Location = element.querySelector(".presentation-location a")?.innerHtml;
    EventType = element.querySelector(".event-type-name")?.innerHtml;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Links'] = links;
    data['SessionTypeId'] = sessionTypeId;
    data['Description'] = description;
    data['Title'] = title;
    data['Id'] = id;
    data['Enabled'] = enabled;
    return data;
  }
}

class Tag {
  String? id;
  String? name;

  Tag({this.id, this.name});

  Tag.FromElement(html.Element element) {
    this.id = element.classes.last;
    this.name = element.innerHtml;
  }

}

class TimeSlot {
  StartTime? startTime;
  StartTime? endTime;

  TimeSlot({this.startTime, this.endTime});
}

class StartTime {
  DateTime? uTC;
  DateTime? eventTime;

  StartTime({this.uTC, this.eventTime});

  StartTime.fromJson(Map<String, dynamic> json) {
    uTC = DateTime.parse(json['UTC']);
    eventTime = DateTime.parse(json['EventTime']);
  }
  StartTime.fromUtc(DateTime utc) {
    uTC = utc;
    final timeZone = tz.getLocation('America/Los_Angeles');
    eventTime = tz.TZDateTime.from(utc, timeZone);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UTC'] = uTC;
    data['EventTime'] = eventTime;
    return data;
  }

  String simpleTime() => DateFormat(DateFormat.HOUR_MINUTE).format(eventTime!);
}

class Room {
  int? id;
  String? name;
  int? capacity;
  String? roomType;
  String? description;

  Room({this.id, this.name, this.capacity, this.roomType, this.description});

  Room.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    capacity = json['Capacity'];
    roomType = json['RoomType'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Name'] = name;
    data['Capacity'] = capacity;
    data['RoomType'] = roomType;
    data['Description'] = description;
    return data;
  }
}
