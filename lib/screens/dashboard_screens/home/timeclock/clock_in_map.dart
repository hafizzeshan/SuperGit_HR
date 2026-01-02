import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/savedJod.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';

class ClockInMapScreen extends StatefulWidget {
  const ClockInMapScreen({super.key});

  @override
  State<ClockInMapScreen> createState() => _ClockInMapScreenState();
}

class _ClockInMapScreenState extends State<ClockInMapScreen> {
  final LocationController locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();

    /// ✅ Fetch location only once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationController.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitoutAction(title: "Clock In"),
      body: Obx(() {
        if (locationController.isLoading.value ||
            locationController.currentLatLng.value == null) {
          return const Center(
            child: CupertinoActivityIndicator(color: kPrimaryColor, radius: 15),
          );
        }

        final LatLng coords = locationController.currentLatLng.value!;
        return _ClockInMapView(
          coords: coords,
          onConfirm: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              builder:
                  (_) => SavedJobsSheet(
                    data: {
                      "method": "App",
                      "sourceDevice": "Mobile",
                      "remarks": locationController.address.value,
                      "coords": coords,
                    },
                  ),
            );
          },
        );
      }),
    );
  }
}

class _ClockInMapView extends StatefulWidget {
  final LatLng coords;
  final VoidCallback onConfirm;

  const _ClockInMapView({required this.coords, required this.onConfirm});

  @override
  State<_ClockInMapView> createState() => _ClockInMapViewState();
}

class _ClockInMapViewState extends State<_ClockInMapView> {
  late GoogleMapController mapController;
  final Rx<MapType> _currentMapType = MapType.normal.obs;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _toggleMapType() {
    switch (_currentMapType.value) {
      case MapType.normal:
        _currentMapType.value = MapType.satellite;
        break;
      case MapType.satellite:
        _currentMapType.value = MapType.terrain;
        break;
      case MapType.terrain:
        _currentMapType.value = MapType.hybrid;
        break;
      case MapType.hybrid:
        _currentMapType.value = MapType.normal;
        break;
      default:
        _currentMapType.value = MapType.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.coords,
              zoom: 17.5,
            ),
            mapType: _currentMapType.value,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                position: widget.coords,
              ),
            },
          ),

          /// Map Type Button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "mapTypeBtn",
              backgroundColor: Colors.white,
              onPressed: _toggleMapType,
              child: const Icon(Icons.map, color: kPrimaryColor),
            ),
          ),

          /// Confirm Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: LoadingButton(
                  isLoading: false,
                  text: "Confirm",
                  onTap: widget.onConfirm,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
