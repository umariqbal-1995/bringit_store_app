import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class StoreLocationView extends StatefulWidget {
  const StoreLocationView({super.key});

  @override
  State<StoreLocationView> createState() => _StoreLocationViewState();
}

class _StoreLocationViewState extends State<StoreLocationView> {
  final MapController _mapCtrl = MapController();
  LatLng _pin = const LatLng(24.8607, 67.0011); // default Karachi
  bool _locating = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tryAutoLocate();
  }

  Future<void> _tryAutoLocate() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
    await _locateMe(silent: true);
  }

  Future<void> _locateMe({bool silent = false}) async {
    setState(() => _locating = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _pin = loc);
      _mapCtrl.move(loc, 15);
    } catch (e) {
      if (!silent) Get.snackbar('Location', 'Could not get location. Tap map to place pin.', snackPosition: SnackPosition.BOTTOM);
    }
    setState(() => _locating = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await DioClient.instance.put('/store/me', data: {
        'latitude': _pin.latitude,
        'longitude': _pin.longitude,
      });
      Get.offAllNamed(AppRoutes.storeBanner);
    } catch (_) {
      Get.snackbar('Error', 'Failed to save location', snackPosition: SnackPosition.BOTTOM);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _progressBar(step: 3),
                  const SizedBox(height: 20),
                  const Text('Where is your store?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Tap the map to pin your exact location, or use GPS.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _pin,
                      initialZoom: 14,
                      onTap: (_, latLng) => setState(() => _pin = latLng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.bringit.bringitStoreApp',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _pin,
                            width: 48,
                            height: 48,
                            child: const Icon(Icons.location_pin, color: AppColors.error, size: 48),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // GPS button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      onPressed: _locating ? null : _locateMe,
                      backgroundColor: AppColors.background,
                      child: _locating
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                          : const Icon(Icons.my_location_rounded, color: AppColors.primary),
                    ),
                  ),
                  // Coordinates chip
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${_pin.latitude.toStringAsFixed(5)}, ${_pin.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Confirm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar({required int step}) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        final done = n < step;
        final active = n == step;
        return Expanded(
          child: Row(
            children: [
              _dot(n, done: done, active: active),
              if (i < 4) Expanded(child: Container(height: 2, color: done ? AppColors.primary : AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4))),
            ],
          ),
        );
      }),
    );
  }

  Widget _dot(int n, {bool done = false, bool active = false}) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: done ? AppColors.primary : active ? AppColors.primaryLight : AppColors.backgroundSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: done || active ? AppColors.primary : AppColors.border, width: 2),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text('$n', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.textTertiary)),
      ),
    );
  }
}
