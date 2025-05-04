import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

class StationMapPage extends StatelessWidget {
  const StationMapPage({super.key});

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

  ///
  bool doSegmentsIntersect(LatLng p, LatLng q, LatLng r, LatLng s) {
    bool isSamePoint(LatLng a, LatLng b) => a.latitude == b.latitude && a.longitude == b.longitude;

    int orientation(LatLng a, LatLng b, LatLng c) {
      final double val =
          (b.longitude - a.longitude) * (c.latitude - b.latitude) -
          (b.latitude - a.latitude) * (c.longitude - b.longitude);
      if (val > 0) {
        return 1;
      }
      if (val < 0) {
        return 2;
      }
      return 0;
    }

    bool onSegment(LatLng a, LatLng b, LatLng c) {
      return b.longitude >= math.min(a.longitude, c.longitude) &&
          b.longitude <= math.max(a.longitude, c.longitude) &&
          b.latitude >= math.min(a.latitude, c.latitude) &&
          b.latitude <= math.max(a.latitude, c.latitude);
    }

    if (isSamePoint(p, r) || isSamePoint(p, s) || isSamePoint(q, r) || isSamePoint(q, s)) {
      return false;
    }

    final int o1 = orientation(p, q, r);
    final int o2 = orientation(p, q, s);
    final int o3 = orientation(r, s, p);
    final int o4 = orientation(r, s, q);

    if (o1 != o2 && o3 != o4) {
      return true;
    }
    if (o1 == 0 && onSegment(p, r, q)) {
      return true;
    }
    if (o2 == 0 && onSegment(p, s, q)) {
      return true;
    }
    if (o3 == 0 && onSegment(r, p, s)) {
      return true;
    }
    if (o4 == 0 && onSegment(r, q, s)) {
      return true;
    }

    return false;
  }

  ///
  int countOverlaps(List<LatLng> newSeg, List<List<LatLng>> others) {
    return others.where((List<LatLng> seg) => doSegmentsIntersect(newSeg[0], newSeg[1], seg[0], seg[1])).length;
  }

  ///
  Color getColorFromOverlap(int count, List<LatLng> newSeg, List<List<LatLng>> others, List<Color> colors) {
    // 通常の色分け
    if (count >= 3) {
      // 新たに intersect する segment の中に紫が含まれているかチェック
      for (int i = 0; i < others.length; i++) {
        if (doSegmentsIntersect(newSeg[0], newSeg[1], others[i][0], others[i][1]) && colors[i] == Colors.purple) {
          return Colors.orange;
        }
      }
      return Colors.purple;
    }
    if (count == 2) {
      return Colors.green;
    }
    if (count == 1) {
      return Colors.red;
    }
    return Colors.blue;
  }

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

    // ignore: always_specify_types
    final List<Polyline<Object>> polylines = <Polyline>[];
    final List<Color> colors = <Color>[];
    for (int i = 0; i < segments.length; i++) {
      final List<LatLng> seg = segments[i];
      final List<List<LatLng>> previous = segments.sublist(0, i);
      final int overlapCount = countOverlaps(seg, previous);
      final Color color = getColorFromOverlap(overlapCount, seg, previous, colors);
      colors.add(color);

      // ignore: always_specify_types
      polylines.add(Polyline(points: seg, color: color, strokeWidth: 6));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('線の重なり判定デモ（東京→原宿→浜松町）')),
      body: FlutterMap(
        options: MapOptions(initialCenter: tokyo, initialZoom: 11.5),
        children: <Widget>[
          TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
          // ignore: always_specify_types
          PolylineLayer(polylines: polylines),
          MarkerLayer(
            // ignore: always_specify_types
            markers: List.generate(points.length, (index) {
              return Marker(
                point: points[index],
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all()),
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
