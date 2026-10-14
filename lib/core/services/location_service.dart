import 'package:geolocator/geolocator.dart';

class LocationService {

  // 1. دالة للحصول على الموقع الحالي للمستخدم (دكتور أو طالب)
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التأكد من أن الـ GPS مفعل في الجهاز
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

     permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. We need it to mark attendance.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
       throw Exception('Location permissions are permanently denied, please enable them from settings.');
    }

     return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

   static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}