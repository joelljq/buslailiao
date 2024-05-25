class Services {
  late String ServiceNo;
  late String nextBus;
  late String nextBus2;
  late String nextBus3;
  late String BusStopCode;
  late String Type1;
  late String Type2;
  late String Type3;
  late String Cap1;
  late String Cap2;
  late String Cap3;
  late String OriginCode;
  late String DestinationCode;
  late String lat1;
  late String lng1;
  late String lat2;
  late String lng2;
  late String lat3;
  late String lng3;

  Services({
    required this.ServiceNo,
    required this.nextBus,
    required this.nextBus2,
    required this.nextBus3,
    required this.BusStopCode,
    required this.Type1,
    required this.Type2,
    required this.Type3,
    required this.Cap1,
    required this.Cap2,
    required this.Cap3,
    required this.DestinationCode,
    required this.OriginCode,
    required this.lat1,
    required this.lng1,
    required this.lat2,
    required this.lng2,
    required this.lat3,
    required this.lng3,
  });

  Services.fromJson(Map<String, dynamic> json) {
    ServiceNo = json["ServiceNo"];
    nextBus = json["NextBus"]["EstimatedArrival"];
    nextBus2 = json["NextBus2"]["EstimatedArrival"];
    nextBus3 = json["NextBus3"]["EstimatedArrival"];
    Type1 = json["NextBus"]["Type"];
    Type2 = json["NextBus2"]["Type"];
    Type3 = json["NextBus3"]["Type"];
    lat1 = json["NextBus"]["Latitude"];
    lng1 = json["NextBus"]["Longitude"];
    lat2 = json["NextBus2"]["Latitude"];
    lng2 = json["NextBus2"]["Longitude"];
    lat3 = json["NextBus3"]["Latitude"];
    lng3 = json["NextBus3"]["Longitude"];
    Cap1 = json["NextBus"]["Load"];
    Cap2 = json["NextBus2"]["Load"];
    Cap3 = json["NextBus3"]["Load"];
    DestinationCode = json["NextBus"]["DestinationCode"];
    OriginCode = json["NextBus"]["OriginCode"];
  }
  late double Lat1 = lat1 != '' ? double.parse(lat1) : 0.0;
  late double Lng1 = lng1 != '' ? double.parse(lng1) : 0.0;
  late double Lat2 = lat2 != '' ? double.parse(lat2) : 0.0;
  late double Lng2 = lng2 != '' ? double.parse(lng2) : 0.0;
  late double Lat3 = lat3 != '' ? double.parse(lat3) : 0.0;
  late double Lng3 = lng3 != '' ? double.parse(lng3) : 0.0;
  late DateTime startTime = (nextBus == ""
      ? DateTime.parse("2029-10-09T22:17:30+08:00".substring(0, 19))
      : DateTime.parse(nextBus));
  late DateTime currentTime = DateTime.now();
  late int Time = startTime.difference(currentTime).inMinutes;
  late String nextBusTime = (Time <= 0
      ? 'Arr'
      : Time > 100
          ? ''
          : Time.toString());
  late DateTime startTime2 = (nextBus2 == ""
      ? DateTime.parse("2029-10-09T22:17:30+08:00".substring(0, 19))
      : DateTime.parse(nextBus2));
  late DateTime currentTime2 = DateTime.now();
  late int Time2 = startTime2.difference(currentTime2).inMinutes;
  late String nextBusTime2 = (Time2 <= 0
      ? 'Arr'
      : Time2 > 100
          ? ''
          : Time2.toString());
  late DateTime startTime3 = (nextBus3 == ""
      ? DateTime.parse("2029-10-09T22:17:30+08:00".substring(0, 19))
      : DateTime.parse(nextBus3));
  late DateTime currentTime3 = DateTime.now();
  late int Time3 = startTime3.difference(currentTime3).inMinutes;
  late String nextBusTime3 = (Time3 <= 0
      ? 'Arr'
      : Time3 > 100
          ? ''
          : Time3.toString());
  late String nextbusType1 = (Type1 == "SD"
      ? "■"
      : Type1 == ""
          ? ""
          : Type1 == "BD"
              ? "■■"
              : "▮");
  late String nextbusType2 = (Type2 == "SD"
      ? "■"
      : Type2 == ""
          ? ""
          : Type2 == "BD"
              ? "■■"
              : "▮");
  late String nextbusType3 = (Type3 == "SD"
      ? "■"
      : Type3 == ""
          ? ""
          : Type3 == "BD"
              ? "■■"
              : "▮");
}
