import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_widget/models/place.dart';


class MarkerService {

 bounds(Set<Marker> markers) {
    if (markers.isEmpty) return null;
    return createBounds(markers.map((m) => m.position).toList());
  }

  LatLngBounds createBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce((value, element) => value < element ? value : element); // smallest
    final southwestLon = positions.map((p) => p.longitude).reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce((value, element) => value > element ? value : element); // biggest
    final northeastLon = positions.map((p) => p.longitude).reduce((value, element) => value > element ? value : element);
    return LatLngBounds(
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon)
    );
  }

  Marker createMarkerFromPlace(Place place, bool center) {
    var markerId = place.name;
    if (center) markerId = 'center';
    var icon;
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(5,5)), "assets/marker.png").then((value) {
      icon = value;
    });
    return Marker(
        markerId: MarkerId(markerId),
        draggable: true,
        visible: true,
        infoWindow: InfoWindow(
            title: place.name, snippet: place.vicinity),
        position: LatLng(place.geometry.location.lat,
            place.geometry.location.lng),
        icon: icon,
    );
  }


}