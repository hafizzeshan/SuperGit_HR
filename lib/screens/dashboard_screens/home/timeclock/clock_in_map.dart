import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  /// Location milne tak baar baar try karne ke liye retry timer.
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();

    /// ✅ Location success hone tak baar baar fetch karo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUntilSuccess();
    });
  }

  /// 🔁 Location (coords) milne tak har 3 second fetch retry karta hai.
  /// Jaise hi coords mil jaate hain, loop band ho jata hai.
  void _fetchUntilSuccess() {
    _retryTimer?.cancel();

    // Pehla attempt foran.
    locationController.getCurrentLocation();

    _retryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // ✅ Location mil gayi → retry band.
      if (locationController.currentLatLng.value != null) {
        timer.cancel();
        return;
      }
      // Pehle se fetch chal rahi hai → is tick ko skip karo.
      if (locationController.isLoading.value) return;
      // Dobara try karo (service on/permission grant hote hi success ho jayega).
      locationController.getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  /// 👆 Chip tap: dobara location fetch karo. Agar system permission dialog
  /// aa sakta hai to woh dikhega; warna location/app settings screen kholo.
  Future<void> _onLocationChipTap() async {
    // 1️⃣ Location service (GPS) OFF → seedha device location settings kholo.
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      await Geolocator.openLocationSettings();
      locationController.getCurrentLocation();
      return;
    }

    // 2️⃣ Permission permanently denied → system dialog nahi aayega →
    // app settings kholo taaki user manually allow kar sake.
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      locationController.getCurrentLocation();
      return;
    }

    // 3️⃣ denied (request ho sakti hai) ya granted → getCurrentLocation khud
    // permission dialog dikhayega ya location fetch karega.
    locationController.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarrWitoutAction(title: TranslationKeys.clockIn.tr),
      body: Obx(() {
        // ✅ Location service (GPS) is OFF → show animated warning chip
        if (!locationController.isLocationServiceOn.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _LocationWarningChip(
                onRetry: _onLocationChipTap,
              ),
            ),
          );
        }

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

/// ⚠️ Animated chip shown when the device location service (GPS) is OFF.
/// Mimics the timer chip style and shows blinking dots to grab attention.
/// Tap to re-check the location status.
class _LocationWarningChip extends StatefulWidget {
  final VoidCallback onRetry;

  const _LocationWarningChip({required this.onRetry});

  @override
  State<_LocationWarningChip> createState() => _LocationWarningChipState();
}

class _LocationWarningChipState extends State<_LocationWarningChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Warning accent color (orange).
  static const Color _warn = Color(0xFFE8590C);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onRetry,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: _warn.withOpacity(0.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _warn.withOpacity(0.35), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off_rounded, color: _warn, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: kText(
                    text: TranslationKeys.locationOffProceedShifts.tr,
                    fSize: 13.5,
                    fWeight: FontWeight.w600,
                    tColor: _warn,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                ..._buildBlinkingDots(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Three dots that blink in a staggered sequence.
  List<Widget> _buildBlinkingDots() {
    return List.generate(3, (i) {
      // Offset each dot's phase so they pulse one after another.
      final double phase = (_controller.value + (i * 0.2)) % 1.0;
      // Triangular wave → smooth fade in/out between 0.25 and 1.0 opacity.
      final double wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
      final double opacity = 0.25 + (0.75 * wave);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _warn.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}
