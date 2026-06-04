import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationController extends GetxController {
  var isLoading = false.obs;
  var address = ''.obs;
  var currentLatLng = Rxn<LatLng>();

  /// ✅ Whether the device's location service (GPS) is currently turned ON
  var isLocationServiceOn = true.obs;

  /// 🗺️ Replace this with your actual API key
  final String googleApiKey = "AIzaSyA_y2gPOwCncoKN-MMK2zigootcYNpWZcg";

  /// ✅ Get device's current location
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      address.value = '';

      // ✅ Check if location service (GPS) is turned ON
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceOn.value = serviceEnabled;
      if (!serviceEnabled) {
        address.value = "Location services are off";
        return;
      }

      // ✅ Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          address.value = "Location permission denied";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        address.value =
            "Location permissions permanently denied. Enable from settings.";
        return;
      }

      // ✅ Quick fix from last known position (map jaldi dikhe).
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          currentLatLng.value = LatLng(last.latitude, last.longitude);
        }
      } catch (_) {}

      // ✅ Accurate fix WITH a hard timeout — taaki call hang na ho aur har
      // retry attempt complete ho jaye.
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
        currentLatLng.value = LatLng(position.latitude, position.longitude);
      } catch (e) {
        // Timed out / failed → last-known rakho agar mila tha, warna error.
        if (currentLatLng.value == null) rethrow;
      }

      // ✅ Fetch address for the resolved coordinates
      if (currentLatLng.value != null) {
        await getAddressFromLatLng(currentLatLng.value!);
      }
    } catch (e) {
      address.value = "Unable to fetch current location";
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Convert LatLng → Address (Using Google Geocoding API)
  Future<void> getAddressFromLatLng(LatLng coords) async {
    try {
      isLoading.value = true;
      address.value = '';

      final String languageCode = Get.locale?.languageCode ?? 'en';
      final url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${coords.latitude},${coords.longitude}&key=$googleApiKey&language=$languageCode";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          address.value = data['results'][0]['formatted_address'];
          print('🗺️ Google API Address: ${address.value}');
        } else {
          print("⚠️ Google API returned no results. Using local fallback...");
          await _getAddressFromGeocoding(coords);
        }
      } else {
        print(
          "⚠️ Google API failed (${response.statusCode}). Using fallback...",
        );
        await _getAddressFromGeocoding(coords);
      }
    } catch (e) {
      print("❌ Exception in Google API: $e");
      await _getAddressFromGeocoding(coords);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 Local fallback using device geocoding
  Future<void> _getAddressFromGeocoding(LatLng coords) async {
    try {
      final String languageCode = Get.locale?.languageCode ?? 'en';
      try {
        await setLocaleIdentifier(languageCode);
      } catch (e) {
        print("Set locale identifier failed: $e");
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address.value = [
          p.name,
          p.thoroughfare,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        print('📍 Local Geocoding Address: ${address.value}');
      } else {
        address.value = "Unknown location";
      }
    } catch (e) {
      address.value = "Unable to fetch address locally";
    }
  }
}
