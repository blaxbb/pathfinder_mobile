import 'package:intl/intl.dart';

class Session {
  String? links;
  int? sessionTypeId;
  String? description;
  String? title;
  int? id;
  bool? enabled;
  Track? track;
  List<PropertyValues>? propertyValues;
  TimeSlot? timeSlot;
  Room? room;

  Session(
      {this.links,
      this.sessionTypeId,
      this.description,
      this.title,
      this.id,
      this.enabled,
      this.track,
      this.propertyValues,
      this.timeSlot,
      this.room});

  String format() => stringProp(99882);
  List<String> keywords() => listProp(99825);
  List<String> interestAreas() => listProp(99880);
  List<String> registrationLevels() => listProp(99881);

  PropertyValues? prop(int id) => propertyValues?.cast<PropertyValues?>().firstWhere((element) => element?.propertyMetadataId == id, orElse: () => null);

  String stringProp(int id) {
    return prop(id)?.value ?? "";
  }
  List<String> listProp(int id) {
    return prop(id)?.value?.split(",") ?? List.generate((0), (index) => "");
  }

  Session.fromJson(Map<String, dynamic> json) {
    links = json['Links'];
    sessionTypeId = json['SessionTypeId'];
    description = json['Description'];
    title = json['Title'];
    id = json['Id'];
    enabled = json['Enabled'];
    track = json['Track'] != null ? Track.fromJson(json['Track']) : null;
    if (json['PropertyValues'] != null) {
      propertyValues = <PropertyValues>[];
      json['PropertyValues'].forEach((v) {
        propertyValues!.add(PropertyValues.fromJson(v));
      });
    }
    timeSlot = json['TimeSlot'] != null
        ? TimeSlot.fromJson(json['TimeSlot'])
        : null;
    room = json['Room'] != null ? Room.fromJson(json['Room']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Links'] = links;
    data['SessionTypeId'] = sessionTypeId;
    data['Description'] = description;
    data['Title'] = title;
    data['Id'] = id;
    data['Enabled'] = enabled;
    if (track != null) {
      data['Track'] = track!.toJson();
    }
    if (propertyValues != null) {
      data['PropertyValues'] =
          propertyValues!.map((v) => v.toJson()).toList();
    }
    if (timeSlot != null) {
      data['TimeSlot'] = timeSlot!.toJson();
    }
    if (room != null) {
      data['Room'] = room!.toJson();
    }
    return data;
  }
}

class Track {
  int? id;
  String? title;
  String? description;
  int? numberOfSessions;

  Track({this.id, this.title, this.description, this.numberOfSessions});

  Track.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    description = json['Description'];
    numberOfSessions = json['NumberOfSessions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Title'] = title;
    data['Description'] = description;
    data['NumberOfSessions'] = numberOfSessions;
    return data;
  }
}

class PropertyValues {
  int? id;
  String? value;
  int? propertyMetadataId;
  int? sessionId;

  PropertyValues(
      {this.id, this.value, this.propertyMetadataId, this.sessionId});

  PropertyValues.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    value = json['Value'];
    propertyMetadataId = json['PropertyMetadataId'];
    sessionId = json['SessionId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Value'] = value;
    data['PropertyMetadataId'] = propertyMetadataId;
    data['SessionId'] = sessionId;
    return data;
  }
}

class TimeSlot {
  int? id;
  StartTime? startTime;
  StartTime? endTime;
  String? label;
  String? type;

  TimeSlot({this.id, this.startTime, this.endTime, this.label, this.type});

  TimeSlot.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    startTime = json['StartTime'] != null
        ? StartTime.fromJson(json['StartTime'])
        : null;
    endTime = json['EndTime'] != null
        ? StartTime.fromJson(json['EndTime'])
        : null;
    label = json['Label'];
    type = json['Type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    if (startTime != null) {
      data['StartTime'] = startTime!.toJson();
    }
    if (endTime != null) {
      data['EndTime'] = endTime!.toJson();
    }
    data['Label'] = label;
    data['Type'] = type;
    return data;
  }
}

class StartTime {
  DateTime? uTC;
  DateTime? eventTime;

  StartTime({this.uTC, this.eventTime});

  StartTime.fromJson(Map<String, dynamic> json) {
    uTC = DateTime.parse(json['UTC']);
    eventTime = DateTime.parse(json['EventTime']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UTC'] = uTC;
    data['EventTime'] = eventTime;
    return data;
  }

  String simpleTime() => DateFormat(DateFormat.HOUR_MINUTE).format(eventTime!.subtract(const Duration(hours: 7)));
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
