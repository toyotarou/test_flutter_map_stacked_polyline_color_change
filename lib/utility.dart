import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Utility {
  ///
  int countOverlaps(List<LatLng> newSeg, List<List<LatLng>> others) {
    return others.where((List<LatLng> seg) => polylineOverlapCheck(newSeg[0], newSeg[1], seg[0], seg[1])).length;
  }

  ///
  Color getColorFromOverlap(int count, List<LatLng> newSeg, List<List<LatLng>> others, List<Color> colors) {
    // 通常の色分け
    if (count >= 3) {
      // 新たに intersect する segment の中に紫が含まれているかチェック
      for (int i = 0; i < others.length; i++) {
        if (polylineOverlapCheck(newSeg[0], newSeg[1], others[i][0], others[i][1]) && colors[i] == Colors.purple) {
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
  bool polylineOverlapCheck(LatLng p, LatLng q, LatLng r, LatLng s) {
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
}
