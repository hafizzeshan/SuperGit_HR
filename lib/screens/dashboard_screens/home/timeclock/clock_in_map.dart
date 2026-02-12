import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supergithr/controllers/location_controller.dart';
import 'package:supergithr/screens/dashboard_screens/home/timeclock/savedJod.dart';
import 'package:supergithr/views/CustomButton.dart';
import 'package:supergithr/views/appBar.dart';
import 'package:supergithr/views/colors.dart';
import 'package:supergithr/translations/translations/translation_keys.dart';
import 'package:supergithr/views/customText.dart';

import 'package:supergithr/views/shimmer/map_shimmer.dart';

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
      appBar: appBarrWitoutAction(title: TranslationKeys.clockIn.tr),
      body: Obx(() {
        if (locationController.isLoading.value ||
            locationController.currentLatLng.value == null) {
          return const MapShimmer();
        }

        final LatLng coords = locationController.currentLatLng.value!;
        return _ClockInMapView(
          coords: coords,
          onConfirm: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              builder:
                  (_) => Container(
                    decoration: const BoxDecoration(
                      gradient: kMainBackgroundGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: SavedJobsSheet(
                      data: {
                        "method": "App",
                        "sourceDevice": "Mobile",
                        "remarks": locationController.address.value,
                        "coords": coords,
                      },
                    ),
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
  final LocationController locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    // Ensure address is fetched for the initial coordinates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locationController.address.value.isEmpty) {
        locationController.getAddressFromLatLng(widget.coords);
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _toggleMapType() {
    switch (_currentMapType.value) {
      case MapType.normal:
        _currentMapType.value = MapType.satellite;
        break;
      case MapType.satellite:
        _currentMapType.value =
            MapType
                .terrain; // Terrain is often standard in some maps packages or fallback
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

  void _recenterMap() {
    mapController.animateCamera(CameraUpdate.newLatLng(widget.coords));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          // 1. Google Map Base Layer
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.coords,
              zoom: 17.5,
            ),
            mapType: _currentMapType.value,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll add a custom one
            zoomControlsEnabled: false,
            compassEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                position: widget.coords,
                infoWindow: InfoWindow(title: TranslationKeys.youAreHere.tr),
              ),
            },
          ),

          // 2. Top Location Card (Glassmorphic)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: kPrimaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kText(
                          text: TranslationKeys.yourLocation.tr,
                          fSize: 12.0,
                          tColor: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => kText(
                            text:
                                locationController.address.value.isNotEmpty
                                    ? locationController.address.value
                                    : "${widget.coords.latitude.toStringAsFixed(4)}, ${widget.coords.longitude.toStringAsFixed(4)}",
                            fSize: 14.0,
                            fWeight: FontWeight.bold,
                            textoverflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Map Control Buttons (Map Type & Recenter)
          Positioned(
            top: 100,
            right: 20,
            child: Column(
              children: [
                _buildMapBtn(
                  icon: Icons.layers_outlined,
                  onTap: _toggleMapType,
                ),
                const SizedBox(height: 12),
                _buildMapBtn(
                  icon: Icons.gps_fixed_rounded,
                  onTap: _recenterMap,
                ),
              ],
            ),
          ),

          // 4. Bottom Confirm Button Area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: LoadingButton(
                      isLoading: false,
                      text: TranslationKeys.confirm.tr, // Using translation key
                      onTap: widget.onConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMapBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 24),
      ),
    );
  }
}
