import 'package:cloud_firestore/cloud_firestore.dart';

class Tracker {
  Tracker({
    this.id = '',
    required this.name,
    required this.med_ids,
    required this.med_names,
    required this.tracker_time
  });

  factory Tracker.fromDocument(DocumentSnapshot data) {
    return Tracker(
      id: data.id,
      name: data['name'],
      med_ids: List<String>.from(data['med_ids']),
      med_names: List<String>.from(data['med_names']),
      tracker_time: data['tracker_time'].toDate(),
    );
  }

  //TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);
  //factory Tracker.fromJson(Map<String, dynamic> json) => _$TrackerFromJson(json);

  //Map<String, dynamic> toJson() => Tracker(this);

  String id;
  String name;
  List<String> med_ids;
  List<String> med_names;
  DateTime tracker_time;
}
