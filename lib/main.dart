import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'utility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '線の重なり判定デモ（東京→原宿→浜松町）',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StationMapPage(),
    );
  }
}

class StationMapPage extends StatefulWidget {
  const StationMapPage({super.key});

  @override
  State<StationMapPage> createState() => _StationMapPageState();
}

class _StationMapPageState extends State<StationMapPage> {
  // ignore: avoid_field_initializers_in_const_classes
  final LatLng tokyo = const LatLng(35.681236, 139.767125);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng shinjuku = const LatLng(35.689634, 139.700553);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng ikebukuro = const LatLng(35.728926, 139.71038);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng tamachi = const LatLng(35.645736, 139.747575);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng shibuya = const LatLng(35.658034, 139.701636);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng sugamo = const LatLng(35.733234, 139.739077);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng uguisudani = const LatLng(35.721203, 139.778656);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng harajuku = const LatLng(35.670167, 139.702708);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng otsuka = const LatLng(35.731547, 139.728073);

  // ignore: avoid_field_initializers_in_const_classes
  final LatLng hamamatsucho = const LatLng(35.655646, 139.757101);

  // ignore: always_specify_types
  final List<Polyline<Object>> polylineList = <Polyline>[];

  final List<Color> colorList = <Color>[];

  List<Marker> markerList = <Marker>[];

  Utility utility = Utility();

  ///
  @override
  Widget build(BuildContext context) {
    final List<LatLng> points = <LatLng>[
      tokyo,
      shinjuku,
      ikebukuro,
      tamachi,
      shibuya,
      sugamo,
      uguisudani,
      harajuku,
      otsuka,
      hamamatsucho,
    ];

    final List<List<LatLng>> segments = <List<LatLng>>[];
    for (int i = 1; i < points.length; i++) {
      segments.add(<LatLng>[points[i - 1], points[i]]);
    }

    makePolylineList(segments: segments);

    makeMarkerList(points: points);

    return Scaffold(
      appBar: AppBar(title: const Text('線の重なり判定デモ（東京→原宿→浜松町）')),
      body: FlutterMap(
        options: MapOptions(initialCenter: tokyo, initialZoom: 11.5),
        children: <Widget>[
          TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
          // ignore: always_specify_types
          PolylineLayer(polylines: polylineList),
          MarkerLayer(markers: markerList),
        ],
      ),
    );
  }

  ///
  void makePolylineList({required List<List<LatLng>> segments}) {
    polylineList.clear();

    for (int i = 0; i < segments.length; i++) {
      final List<LatLng> seg = segments[i];
      final List<List<LatLng>> previous = segments.sublist(0, i);

      final int overlapCount = utility.countOverlaps(seg, previous);
      final Color color = utility.getColorFromOverlap(overlapCount, seg, previous, colorList);

      colorList.add(color);

      // ignore: always_specify_types
      polylineList.add(Polyline(points: seg, color: color, strokeWidth: 6));
    }
  }

  ///
  void makeMarkerList({required List<LatLng> points}) {
    markerList.clear();

    for (int i = 0; i < points.length; i++) {
      markerList.add(
        Marker(
          point: points[i],
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all()),
            child: Text('${i + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }
  }
}
