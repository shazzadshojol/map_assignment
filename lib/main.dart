import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Location App',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LocationData currentLocation;
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  late Timer locationTimer;
  bool inProgress = false;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    currentLocation = LocationData.fromMap({
      "latitude": 0.0,
      "longitude": 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Visibility(
          visible: inProgress == false,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentLocation.latitude ?? 0.0,
                currentLocation.longitude ?? 0.0,
              ),
              zoom: 20,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            myLocationEnabled: true,
            padding:
                const EdgeInsets.only(left: 0, top: 600, right: 0, bottom: 0),
            markers: markers,
            polylines: {
              Polyline(
                polylineId: const PolylineId("polyline"),
                color: Colors.blue,
                points: polylineCoordinates,
              ),
            },
          ),
        ),
      ),
    );
  }

  // progress indicator working but very slow. Takes too much time. May be plugin issue.
  void _startLocationUpdates() {
    inProgress = true;
    setState(() {});
    locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      LocationData locationData = await Location().getLocation();

      currentLocation = locationData;
      inProgress = false;
      setState(() {});
      mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(
            currentLocation.latitude ?? 0, currentLocation.longitude ?? 0)),
      );
      _addMarker();
      _addPolyline();
    });
  }

  void _addMarker() {
    // markers.clear();
    final Marker marker = Marker(
      markerId: MarkerId("${polylineCoordinates.length}"),
      position: LatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0),
      infoWindow: InfoWindow(
        title: "My live location",
        snippet:
            "Lat: ${currentLocation.latitude}, Lng: ${currentLocation.longitude}",
      ),
    );
    markers.add(marker);
    setState(() {});
  }

  void _addPolyline() {
    polylineCoordinates.add(LatLng(
        currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0));
    setState(() {});
  }

  @override
  void dispose() {
    locationTimer.cancel();
    super.dispose();
  }
}
