import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smrtbusapp/InitialPage.dart';
import 'package:smrtbusapp/bus%20info.dart';
import 'package:smrtbusapp/chooselocation.dart';
import 'package:smrtbusapp/getserviceroute.dart';
import 'package:smrtbusapp/services/busstopclass.dart';

// import 'package:jsonlist/chooselocation.dart';
// import 'package:jsonlist/bus info.dart';
// import 'package:jsonlist/loading.dart';
Future<void> getbox() async {
  await Hive.initFlutter();
  Hive.registerAdapter(BusStopClassAdapter());
}

void main() {
  getbox();
  runApp(MaterialApp(
    initialRoute: '/splash',
    routes: {
      '/splash': (context) => NearBusStops(),
      '/location': (context) => BusStops(),
      '/home': (context) => BusArrival(),
      '/servicelist': (context) => ServiceList(),
    },
  ));
}
