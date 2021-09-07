import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_widget/blocs/application_bloc.dart';
import 'package:map_widget/screens/home_screen.dart';
import 'package:map_widget/models/place.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription locationSubscription;
  late StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);

    //Listen for selected Location
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _locationController.text = place.name;
        _goToPlace(place);
      } else
        _locationController.text = "";
    });

    applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.bounds.close();
    applicationBloc.selectedLocation.close();
    locationSubscription.cancel();
    applicationBloc.dispose();
    _locationController.dispose();
    boundsSubscription.cancel();
    super.dispose();
  }

  var _lastMapPosition;
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      body: (applicationBloc.currentLocation == null)
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  indoorViewEnabled: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: true,
                  padding: const EdgeInsets.only(top: 300),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(40.4637, -3.7492),
                    // LatLng(41.296065114430256, -4.055607886490811),
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  markers: Set<Marker>.of(applicationBloc.markers),
                  onCameraMove: _onCameraMove,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: Get.width * 0.9,
                    margin: const EdgeInsets.only(
                      top: 50.0,
                      left: 20,
                      right: 10,
                    ),
                    color: Colors.white,
                    child: Center(
                      child: TextFormField(
                        controller: _locationController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Type to Search',
                          isDense: true,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) =>
                            applicationBloc.searchPlaces(value),
                        onTap: () => applicationBloc.clearSelectedLocation(),
                      ),
                    ),
                  ),
                ),
                if (applicationBloc.searchResults != null &&
                    applicationBloc.searchResults!.length != 0)
                  Container(
                      height: 300.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.6),
                          backgroundBlendMode: BlendMode.darken)),
                if (applicationBloc.searchResults != null)
                  Container(
                    height: 300.0,
                    child: ListView.builder(
                        itemCount: applicationBloc.searchResults!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              applicationBloc.searchResults![index].description,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              applicationBloc.setSelectedLocation(
                                  applicationBloc
                                      .searchResults![index].placeId);
                            },
                          );
                        }),
                  ),
                if (_locationController.text != '' &&
                    applicationBloc.selectedLocationStatic != null)
                  Positioned(
                      bottom: 0,
                      child: Material(
                        elevation: 10,
                        shadowColor: Colors.black,
                        child: Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              applicationBloc.selectedLocationStatic!.name,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                            subtitle: Text(
                                '${applicationBloc.selectedLocationStatic!.geometry.location.lat}, ${applicationBloc.selectedLocationStatic!.geometry.location.lng}'),
                            trailing: FloatingActionButton(
                              onPressed: () {
                                var name = applicationBloc
                                          .selectedLocationStatic!.name;
                                Get.offAll(() => MyHomePage(
                                      location: name
                                    ));
                              },
                              backgroundColor: Colors.black,
                              child: Icon(Icons.arrow_forward),
                            ),
                          ),
                        ),
                      ))
              ],
            ),
    );
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
  }
}
