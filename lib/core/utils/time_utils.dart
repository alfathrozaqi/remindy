import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class TimeUtils {
  // Inisialisasi data timezone
  static void init() {
    tz_data.initializeTimeZones();
  }

  // Mengambil lokasi timezone berdasarkan pilihan user
  // Default: WIB (Asia/Jakarta)
  static tz.Location getLocation(String region) {
    switch (region) {
      case 'WITA':
        return tz.getLocation('Asia/Makassar');
      case 'WIT':
        return tz.getLocation('Asia/Jayapura');
      case 'WIB':
      default:
        return tz.getLocation('Asia/Jakarta');
    }
  }

  // Konversi DateTime biasa ke TZDateTime (Waktu yang dimengerti sistem notifikasi)
  static tz.TZDateTime convertToTZ(DateTime dateTime, {String region = 'WIB'}) {
    final location = getLocation(region);
    return tz.TZDateTime.from(dateTime, location);
  }
}