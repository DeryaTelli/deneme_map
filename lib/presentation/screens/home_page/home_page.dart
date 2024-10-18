import 'dart:async';
import 'package:deneme_map/core/service/map_service/yandex_map_services.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initPermission().ignore();
  }

  List<MapObject> mapObject = [];
  AppLatLong currentLocation = UzbekistanLocation();

  final mapControllerCompleter = Completer<YandexMapController>();
  @override
  Widget build(BuildContext context) {
    addObject(appLatLong: currentLocation);
    return Scaffold(
        body: Stack(
      children: [
        YandexMap(
          mapObjects: mapObject,
          onMapTap: (point) {
            print(point.latitude);
            print(point.longitude);
          },
          onMapCreated: (controller) {
            mapControllerCompleter.complete(controller);
          },
        ),
        // Positioned(
        //   left: MediaQuery.of(context).size.width / 2,
        //    top: MediaQuery.of(context).size.height / 2,
        //  child: Image.asset("assets/images/mark.png")),
      ],
    ));
  }

  Future<void> _initPermission() async {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    AppLatLong location;
    //buradaki location degisecek
    const defLocation = UzbekistanLocation();
    try {
      location = await LocationService().getCurrentLocation();
      print(location.lat);
      print(location.long);
    } catch (_) {
      location = defLocation;
    }

    _moveToCurrentLocation(location);
  }

  Future<void> _moveToCurrentLocation(
    AppLatLong appLatLong,
  ) async {
    currentLocation = appLatLong;
    (await mapControllerCompleter.future).moveCamera(
        animation:
            const MapAnimation(type: MapAnimationType.smooth, duration: 5),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: appLatLong.lat,
              longitude: appLatLong.long,
            ),
            zoom: 15,
          ),
        ));
  }

  void addObject({required AppLatLong appLatLong}) {
    final myLocationMarker = PlacemarkMapObject(
      opacity: 1,
      mapId: MapObjectId('currentLocation'),
      point: Point(latitude: appLatLong.lat, longitude: appLatLong.long),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/images/mark.png'),
            scale: 0.1,
            rotationType: RotationType.noRotation),
      ),
    );
    print(appLatLong.lat);
    print(appLatLong.long);
    mapObject.add(myLocationMarker);
    print(mapObject);
  }
}
