import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// ignore: constant_identifier_names
const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Future<Position>? _positionFuture;

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación fueron denegados');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _positionFuture = determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Position>(
        future: _positionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final myPosition =
                LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
            return FlutterMap(
                options: MapOptions(initialCenter: myPosition, initialZoom: 18, minZoom: 5, maxZoom: 25),

                children: [
                  // Usar OpenStreetMap para pruebas (no requiere token)
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.ejemplo.clase6',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: myPosition,
                        child: const Icon(
                              Icons.person_pin,
                              color: Colors.blueAccent,
                              size: 40,
                            ),
                      )
                    ],
                  )
                ]);
          } else {
            return const Center(child: Text('No se pudo obtener la ubicación.'));
          }
        },
      ),
    );
  }
}