import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smrtbusapp/services/busstopclass.dart';
import 'package:smrtbusapp/services/color_schemes.g.dart';

class NearBusStops extends StatefulWidget {
  const NearBusStops({Key? key}) : super(key: key);

  @override
  _BusStopsState createState() => _BusStopsState();
}

class _BusStopsState extends State<NearBusStops> {
  List<BusStopClass> _products = <BusStopClass>[];
  List<BusStopClass> _productsforDisplay = <BusStopClass>[];
  List<BusStopClass> destinationlist = <BusStopClass>[];
  List<BusStopClass> destinationlistt = <BusStopClass>[];
  List<BusStopClass> _destinationdisplay = <BusStopClass>[];
  List<BusStopClass> favouritelist = <BusStopClass>[];
  late GoogleMapController mapController; //contrller for Google map
  final Set<Marker> markers = new Set();
  late Position _currentPosition;
  late BitmapDescriptor markerbitmap;

  //GPS Location Handler
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<List<BusStopClass>> ReadJsonData() async {
    //read json file
    final jsondata =
        await rootBundle.rootBundle.loadString('jsonfile/BusStops.json');
    //decode json data as list
    var products = <BusStopClass>[];

    Map<String, dynamic> productsJson = json.decode(jsondata);
    for (var productJson in productsJson['value']) {
      products.add(BusStopClass.fromJson(productJson));
    }
    return products;
  }

  Future<void> _getCurrentLocation() async {
    destinationlistt = <BusStopClass>[];
    destinationlist = <BusStopClass>[];
    final hasPermission = await _handleLocationPermission();
    bool isnull = false;
    if (!hasPermission) return;
    while (isnull != true) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        distanceCalculation(position);
        setState(() => _currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });
      if (_currentPosition != null) {
        print('Success');
        print(_currentPosition?.latitude);
        isnull = true;
      } else {
        print('Failed');
      }
    }
  }

  //
  distanceCalculation(Position position) async {
    await ReadJsonData();
    for (var d in _products) {
      var m = Geolocator.distanceBetween(
          position.latitude, position.longitude, d.lat, d.lng);
      d.distance = m / 1000; //Append bus stops that are lesser than 1km
      if (d.distance < 1) {
        destinationlistt.add(d);
      }
    }

    setState(() {
      destinationlistt.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });
    });

    setState(() {
      if (destinationlistt.length > 12) {
        int count = 0;
        for (var destination in destinationlistt) {
          if (count != 12) {
            destinationlist.add(destination);
            count++;
          }
        }
      } else {
        destinationlistt = destinationlist;
      }
    });

    setState(() {
      destinationlist.sort((a, b) {
        return a.distance.compareTo(b.distance);
      });
      _destinationdisplay = destinationlist;
    });
  }

  late Timer timer;
  late String _mapStyle;

  @override
  void initState() {
    _getCurrentLocation();
    ReadJsonData().then((value) {
      setState(() {
        _products.addAll(value);
        _productsforDisplay = _products;
      });
    });
    super.initState();
    rootBundle.rootBundle.loadString('jsonfile/darkgoogle.json').then((string) {
      _mapStyle = string;
    });
    getmarkericon();
  }

  void updateInfoTime(index) async {
    BusStopClass instance = _productsforDisplay[index];

    print(_productsforDisplay[index].name);
    // navigate to home screen
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'BusStopCode': instance.code,
      'name': instance.name,
      'road': instance.road,
      'lat': instance.lat,
      'lng': instance.lng
    });
  }

  void updateInfoTime2(index) async {
    BusStopClass instance = _destinationdisplay[index];

    print(_destinationdisplay[index].name);
    // navigate to home screen
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'BusStopCode': instance.code,
      'name': instance.name,
      'road': instance.road,
      'lat': instance.lat,
      'lng': instance.lng
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        home: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            // backgroundColor: Colors.grey[200],
            appBar: AppBar(
              // backgroundColor: Colors.deepPurple[50],
              centerTitle: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              )),
              title: TabBar(
                // labelColor: Colors.redAccent,
                // unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: Colors.black38),
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("NEARBY"),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text("SEARCH"),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: _destinationdisplay.isEmpty
                      ? Center(
                          child: SpinKitDualRing(
                            color: Colors.purple,
                            size: 30.0,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () {
                            destinationlist = <BusStopClass>[];
                            return _getCurrentLocation();
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
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
                                    target: LatLng(_currentPosition.latitude,
                                        _currentPosition.longitude),
                                    zoom: 16,
                                  ),
                                  markers: getmarkers(),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  // itemCount: locations.length,
                                  itemBuilder: (context, index) {
                                    return _nearestlistitems(index);
                                  },
                                  itemCount: _destinationdisplay.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                RefreshIndicator(
                  onRefresh: () {
                    return _getCurrentLocation();
                  },
                  child: Center(
                    child: _products.isEmpty
                        ? Center(
                            child: SpinKitDualRing(
                              color: Colors.purple,
                              size: 30.0,
                            ),
                          )
                        : ListView.builder(
                            // itemCount: locations.length,
                            itemBuilder: (context, index) {
                              return index == 0
                                  ? _searchBar()
                                  : _listitems(index - 1);
                            },
                            itemCount: _productsforDisplay.length + 1,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getmarkericon() async {
    markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "jsonfile/transport1.png",
    );
  }

  Set<Marker> getmarkers() {
    setState(() {
      for (var destination in destinationlist) {
        markers.add(Marker(
            markerId: MarkerId(destination.name),
            position: LatLng(destination.lat, destination.lng),

            //position of marker
            infoWindow: InfoWindow(
              //popup info
              title: destination.name,
              snippet: "${destination.code} ${destination.road}",
              onTap: () {
                BusStopClass instance = destination;
                Navigator.pushReplacementNamed(context, '/home', arguments: {
                  'BusStopCode': instance.code,
                  'name': instance.name,
                  'road': instance.road,
                  'lat': instance.lat,
                  'lng': instance.lng
                });
              },
            ),
            icon: markerbitmap,
            onTap: () {
              setState(() {
                mapController.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng(destination.lat, destination.lng), 18));
              });
            }));
      }
    });
    return markers;
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
        decoration: BoxDecoration(
          color: Color(0xff101f27),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Color(0xff101f27)),
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: "Enter Here",
          ),
          onChanged: (text) {
            text = text.toLowerCase();
            setState(() {
              _productsforDisplay = _products.where((product) {
                var bsname = product.name!.toLowerCase();
                var bscode = product.code!;
                var bsroad = product.road!.toLowerCase();
                return bsname.contains(text) ||
                    bsroad.contains(text) ||
                    bscode.contains(text);
              }).toList();
            });
          },
        ),
      ),
    );
  }

  _listitems(index) {
    return InkWell(
      onTap: () {
        updateInfoTime(index);
      },
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // if you need this
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _productsforDisplay[index].name.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // color: Colors.red[400]
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _productsforDisplay[index].code.toString(),
                      style: TextStyle(
                        // color: Colors.purpleAccent[200],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      _productsforDisplay[index].road.toString(),
                      style: TextStyle(
                        // color: Colors.purpleAccent[200],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  _nearestlistitems(index) {
    return InkWell(
        onTap: () {
          updateInfoTime2(index);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80.0,
                    width: 300.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _destinationdisplay[index].code.toString(),
                          style: TextStyle(
                              fontSize: 15,
                              // color: Colors.purpleAccent[200],
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _destinationdisplay[index].name.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // color: Colors.red[400],
                          ),
                        ),
                        Text(
                          _destinationdisplay[index].road.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            // color: Colors.purpleAccent[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            mapController.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    LatLng(_destinationdisplay[index].lat,
                                        _destinationdisplay[index].lng),
                                    18));
                          });
                          mapController.showMarkerInfoWindow(
                              MarkerId(_destinationdisplay[index].name));
                        },
                        icon: Icon(Icons.location_on,
                            color: Colors.white, size: 30),
                      ),
                      Text(
                        '${_destinationdisplay[index].distance.toStringAsFixed(2)}km',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          // color: Colors.purpleAccent[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
