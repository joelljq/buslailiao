import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smrtbusapp/services/busarrival.dart';
import 'package:smrtbusapp/services/color_schemes.g.dart';

// void main() => runApp(BusArrival());

class BusArrival extends StatefulWidget {
  @override
  _BusArrivalState createState() => _BusArrivalState();
}

class _BusArrivalState extends State<BusArrival> {
  List<Services> _services = <Services>[];
  late String CurrentBS;
  late GoogleMapController mapController; //contrller for Google map
  late GoogleMapController mapController2;
  Set<Marker> markers = new Set();
  Set<Marker> markers2 = new Set();
  Set<Marker> markers3 = new Set();
  Set<Marker> markers4 = new Set();
  late BitmapDescriptor markerbitmap;
  late BitmapDescriptor busbitmap;
  Map BusStopData = {};

  Future<List<Services>> ReadJsonData() async {
    BusStopData = BusStopData.isEmpty
        ? ModalRoute.of(context)!.settings.arguments as Map
        : BusStopData;
    // read json file
    String Code = (BusStopData['BusStopCode']);
    var link = Uri.parse(
        'http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=$Code');
    var jsondata = await http.get(link, headers: {
      'AccountKey': 'dzaibfzPQueL5UOVMvqLGg==',
      'accept': 'application/json'
    });
    // final jsondata =
    //     await rootBundle.rootBundle.loadString('jsonfile/BusArrival.json');
    //decode json data as list
    Map<String, dynamic> busservices = jsonDecode(jsondata.body);
    var service = <Services>[];
    setState(() {
      for (var busservice in busservices["Services"]) {
        service.add(Services.fromJson(busservice));
      }
    });
    return service;
  }

  Future<void> newValue() async {
    _services = <Services>[];
    ReadJsonData().then((value) {
      setState(() {
        _services.addAll(value);
        print("Updated!");
      });
    });
  }

  Future<void> nearesttome() async {
    _services = <Services>[];
    ReadJsonData().then((value) {
      setState(() {
        _services.addAll(value);
      });
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      _services = <Services>[];
      ReadJsonData().then((value) {
        setState(() {
          _services.addAll(value);
        });
      });
    });
  }

  void updateInfoTime(index) async {
    Services instance = _services[index];
    // navigate to home screen
    dynamic result1 =
        await Navigator.pushNamed(context, '/servicelist', arguments: {
      'ServiceNo': instance.ServiceNo,
      'OriginCode': instance.OriginCode,
      'DestinationCode': instance.DestinationCode,
      'CurrentBSCode': BusStopData['BusStopCode'],
      'lat': BusStopData['lat'],
      'lng': BusStopData['lng'],
    });
    setState(() {
      BusStopData = {
        'BusStopCode': result1['code'],
        'name': result1['name'],
        'road': result1['road'],
        'lat': result1['lat'],
        'lng': result1['lng'],
      };
      newValue();
    });
  }

  late Timer timer;
  late String _mapStyle;

  @override
  void initState() {
    nearesttome();
    timer = new Timer.periodic(Duration(seconds: 60), (_) => newValue());
    super.initState();
    rootBundle.rootBundle.loadString('jsonfile/darkgoogle.json').then((string) {
      _mapStyle = string;
    });
    getmarkericon();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      theme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: Scaffold(
        // backgroundColor: Colors.grey[200],
        appBar: AppBar(
          // backgroundColor: Colors.deepPurple[50],
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              "jsonfile/busapplogo.png",
              alignment: Alignment.center,
            ),
          ),
          centerTitle: true,
          title: Row(
            children: [
              InkWell(
                onTap: () async {
                  dynamic result =
                      await Navigator.pushNamed(context, '/location');
                  setState(() {
                    BusStopData = {
                      'BusStopCode': result['code'],
                      'name': result['name'],
                      'road': result['road'],
                      'lat': result['lat'],
                      'lng': result['lng']
                    };
                    newValue();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff212121),
                      border: Border.all(color: Color(0xff000000)),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  height: 50.0,
                  width: 300.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: BusStopData.isEmpty
                        ? Center(
                            child: SpinKitDualRing(
                              color: Colors.purple,
                              size: 20.0,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                BusStopData['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    BusStopData['BusStopCode'],
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    BusStopData['road'],
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          )),
        ),
        body: BusStopData.isEmpty
            ? Center(
                child: SpinKitDualRing(
                  color: Colors.purple,
                  size: 30.0,
                ),
              )
            : _services.isEmpty
                ? Center(
                    child: Card(
                      child: Text("All Services are unavailable at the moment"),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 500, // or use fixed size like 200
                              height: 300,
                              child: GoogleMap(
                                onMapCreated: (controller) {
                                  //method called when map is created
                                  setState(() {
                                    mapController = controller;
                                    mapController.setMapStyle(_mapStyle);
                                  });
                                },
                                myLocationEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      BusStopData['lat'], BusStopData['lng']),
                                  zoom: 16,
                                ),
                                markers: getmarkers(),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              // add your floating action button
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: FloatingActionButton(
                                  backgroundColor: Colors.grey,
                                  mini: true,
                                  onPressed: () {
                                    setState(() {
                                      mapController.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                              LatLng(BusStopData['lat'],
                                                  BusStopData['lng']),
                                              16));
                                    });
                                  },
                                  child: Icon(
                                    Icons.map,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () {
                            return newValue();
                          },
                          child: ListView.builder(
                            // itemCount: locations.length,
                            itemBuilder: (context, index) {
                              return _listitems(index);
                            },
                            itemCount: _services.length,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  getmarkericon() async {
    markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "jsonfile/transport1.png",
    );
    busbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "jsonfile/bus.png",
    );
  }

  Set<Marker> getmarkers() {
    markers = new Set();
    setState(() {
      markers = new Set();
      markers.add(Marker(
          markerId: MarkerId(BusStopData['name']),
          position: LatLng(BusStopData['lat'], BusStopData['lng']),
          //position of marker
          infoWindow: InfoWindow(
              //popup info
              title: BusStopData['name'],
              snippet: "${BusStopData['BusStopCode']} ${BusStopData['road']}"),
          icon: markerbitmap,
          onTap: () {
            setState(() {
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(BusStopData['lat'], BusStopData['lng']), 18));
            });
          }));
    });
    return markers;
  }

  Set<Marker> getmarkers2(index) {
    markers2 = new Set();
    if (mounted) {
      setState(() {
        markers2 = new Set();
        markers2.add(Marker(
            markerId: MarkerId("nextbus1"),
            position: LatLng(_services[index].Lat1, _services[index].Lng1),
            //position of marker
            infoWindow: InfoWindow(
                //popup info
                title:
                    "Bus is Arriving in ${_services[index].nextBusTime} minutes",
                snippet:
                    "Service: ${_services[index].ServiceNo} Est Arrival: ${_services[index].startTime}"),
            icon: busbitmap,
            onTap: () {
              setState(() {
                mapController.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(BusStopData['lat'], BusStopData['lng']), 18));
              });
            }));
        markers2.add(Marker(
            markerId: MarkerId(BusStopData['name']),
            position: LatLng(BusStopData['lat'], BusStopData['lng']),
            //position of marker
            infoWindow: InfoWindow(
                //popup info
                title: BusStopData['name'],
                snippet:
                    "${BusStopData['BusStopCode']} ${BusStopData['road']}"),
            icon: markerbitmap,
            onTap: () {
              setState(() {
                mapController.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(BusStopData['lat'], BusStopData['lng']), 18));
              });
            }));
      });
    }

    return markers2;
  }

  Set<Marker> getmarkers3(index) {
    markers3 = new Set();
    setState(() {
      markers3 = new Set();
      markers3.add(Marker(
          markerId: MarkerId("nextbus2"),
          position: LatLng(_services[index].Lat2, _services[index].Lng2),
          //position of marker
          infoWindow: InfoWindow(
              //popup info
              title:
                  "Bus is Arriving in ${_services[index].nextBusTime2} minutes",
              snippet:
                  "Service: ${_services[index].ServiceNo} Est Arrival: ${_services[index].startTime2}"),
          icon: busbitmap,
          onTap: () {
            setState(() {
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(BusStopData['lat'], BusStopData['lng']), 16));
            });
          }));
      markers3.add(Marker(
          markerId: MarkerId(BusStopData['name']),
          position: LatLng(BusStopData['lat'], BusStopData['lng']),
          //position of marker
          infoWindow: InfoWindow(
              //popup info
              title: BusStopData['name'],
              snippet: "${BusStopData['BusStopCode']} ${BusStopData['road']}"),
          icon: markerbitmap,
          onTap: () {
            setState(() {
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(BusStopData['lat'], BusStopData['lng']), 18));
            });
          }));
    });
    return markers3;
  }

  _listitems(index) {
    Color bus1 = _services[index].Cap1 == 'SEA'
        ? Color(0xFF43A047)
        : _services[index].Cap1 == 'SDA'
            ? Color(0xFFFFEB3B)
            : Color(0xFFF44556);
    Color bus2 = _services[index].Cap2 == 'SEA'
        ? Color(0xFF43A047)
        : _services[index].Cap2 == 'SDA'
            ? Color(0xFFFFEB3B)
            : Color(0xFFF44556);
    Color bus3 = _services[index].Cap3 == 'SEA'
        ? Color(0xFF43A047)
        : _services[index].Cap3 == 'SDA'
            ? Color(0xFFFFEB3B)
            : Color(0xFFF44556);
    var percentage1 = _services[index].Cap1 == 'SEA'
        ? 0.2
        : _services[index].Cap1 == 'SDA'
            ? 0.6
            : 0.9;
    var percentage2 = _services[index].Cap2 == 'SEA'
        ? 0.2
        : _services[index].Cap2 == 'SDA'
            ? 0.6
            : 0.9;
    var percentage3 = _services[index].Cap3 == 'SEA'
        ? 0.2
        : _services[index].Cap3 == 'SDA'
            ? 0.6
            : 0.9;

    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // if you need this
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            InkWell(
              onTap: () async {
                updateInfoTime(index);
              },
              child: Container(
                decoration: BoxDecoration(
                    // color: Colors.purple[400],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                width: 70.0,
                height: 35.0,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    _services[index].ServiceNo.toString(),
                    style: TextStyle(
                      leadingDistribution: TextLeadingDistribution.even,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(width: 30),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        elevation: 10,
                        enableDrag: false,
                        backgroundColor: Colors.amber,
                        context: context,
                        builder: (context) {
                          return Column(
                            children: [
                              SizedBox(
                                width: 500, // or use fixed size like 200
                                height: 300,
                                child: GoogleMap(
                                  onMapCreated: (controller) {
                                    //method called when map is created
                                    setState(() {
                                      mapController2 = controller;
                                      mapController2.setMapStyle(_mapStyle);
                                    });
                                  },
                                  myLocationEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(_services[index].Lat1,
                                        _services[index].Lng1),
                                    zoom: 16,
                                  ),
                                  markers: getmarkers2(index),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Container(
                    width: 40.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _services[index].nextBusTime.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            // color: bus1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: 5),
                        Text(
                          _services[index].nextbusType1.toString(),
                          style:
                              TextStyle(color: Colors.grey[200], fontSize: 5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3),
                _services[index].nextBusTime.toString() == ''
                    ? SizedBox(height: 1)
                    : LinearPercentIndicator(
                        width: 50.0,
                        lineHeight: 3.0,
                        percent: percentage1,
                        backgroundColor: Colors.white,
                        progressColor: bus1,
                      )
              ],
            ),
            SizedBox(width: 20),
            Column(
              children: [
                Container(
                  width: 40.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _services[index].nextBusTime2.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          // color: bus2,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        _services[index].nextbusType2.toString(),
                        style: TextStyle(color: Colors.grey[200], fontSize: 5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                _services[index].nextBusTime2.toString() == ""
                    ? SizedBox(height: 1)
                    : LinearPercentIndicator(
                        width: 50.0,
                        lineHeight: 3.0,
                        percent: percentage2,
                        backgroundColor: Colors.white,
                        progressColor: bus2,
                      )
              ],
            ),
            SizedBox(width: 20),
            Column(
              children: [
                Container(
                  width: 40.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _services[index].nextBusTime3.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          // color: bus3,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        _services[index].nextbusType3.toString(),
                        style: TextStyle(color: Colors.grey[200], fontSize: 5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3),
                _services[index].nextBusTime3.toString() == ''
                    ? SizedBox(height: 1)
                    : LinearPercentIndicator(
                        width: 50.0,
                        lineHeight: 3.0,
                        percent: percentage3,
                        backgroundColor: Colors.white,
                        progressColor: bus3,
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
