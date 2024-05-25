import 'package:hive/hive.dart';

part 'busstopclass.g.dart';

@HiveType(typeId: 0)
class BusStopClass extends HiveObject {
  //data Type
  @HiveField(0)
  late String code;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late String road;
  @HiveField(3)
  late double lat;
  @HiveField(4)
  late double lng;
  @HiveField(5)
  late double distance;
// constructor
  BusStopClass({
    required this.code,
    required this.name,
    required this.road,
  });
  //method that assign values to respective datatype variables
  BusStopClass.fromJson(Map<String, dynamic> json) {
    code = json['BusStopCode'];
    name = json['Description'];
    road = json['RoadName'];
    lat = json['Latitude'];
    lng = json['Longitude'];
  }
}
