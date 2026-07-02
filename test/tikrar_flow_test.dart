import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tikrar Flow Logic Tests', () {
    test('Kesalahan limit calculation', () {
      // sabak/sabki: 2 kesalahan per halaman
      
      // Case 1: 1 page, 4 errors -> status should be 'mengulang'
      int halamanAwal1 = 1;
      int halamanAkhir1 = 1;
      int jumlahKesalahan1 = 5;
      
      int totalHalaman1 = halamanAkhir1 - halamanAwal1 + 1;
      int batasKesalahan1 = totalHalaman1 * 2;
      String status1 = jumlahKesalahan1 > batasKesalahan1 ? 'mengulang' : 'lulus';
      
      expect(batasKesalahan1, 2);
      expect(status1, 'mengulang');

      // Case 2: 3 pages, 5 errors -> status should be 'lulus'
      int halamanAwal2 = 1;
      int halamanAkhir2 = 3;
      int jumlahKesalahan2 = 5;
      
      int totalHalaman2 = halamanAkhir2 - halamanAwal2 + 1;
      int batasKesalahan2 = totalHalaman2 * 2;
      String status2 = jumlahKesalahan2 > batasKesalahan2 ? 'mengulang' : 'lulus';
      
      expect(batasKesalahan2, 6);
      expect(status2, 'lulus');
    });

    test('Linear Status Transition Definition', () {
      // wajib_sekolah -> selesai_sekolah -> wajib_rumah -> selesai_rumah
      final transitions = {
        'wajib_sekolah': 'selesai_sekolah',
        'selesai_sekolah': 'wajib_rumah',
        'wajib_rumah': 'selesai_rumah',
      };

      expect(transitions['wajib_sekolah'], 'selesai_sekolah');
      expect(transitions['selesai_sekolah'], 'wajib_rumah');
      expect(transitions['wajib_rumah'], 'selesai_rumah');
    });
  });
}
