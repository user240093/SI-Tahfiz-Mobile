// Models
class UserRole {
  static const String murobbi = 'Murobbi';
  static const String wali = 'Wali';
  static const String koordinator = 'Koordinator';
  static const String tu = 'TU';
  static const String kepalaSekolah = 'Kepala Sekolah';
}

class User {
  final String id;
  final String name;
  final String role;

  User({required this.id, required this.name, required this.role});
}

class Santri {
  final String id;
  final String nis;
  final String name;
  final String kelas;
  final String waliId;
  final String murobbiId;

  Santri({
    required this.id,
    required this.nis,
    required this.name,
    required this.kelas,
    required this.waliId,
    required this.murobbiId,
  });
}

class Setoran {
  final String id;
  final String santriId;
  final DateTime date;
  final String type; // Sabak, Sabki, Manzil
  final String surah;
  final int ayatStart;
  final int ayatEnd;
  final int kesalahan;
  final bool isValidatedByWali;
  final String? signatureData;

  Setoran({
    required this.id,
    required this.santriId,
    required this.date,
    required this.type,
    required this.surah,
    required this.ayatStart,
    required this.ayatEnd,
    this.kesalahan = 0,
    this.isValidatedByWali = false,
    this.signatureData,
  });

  Setoran copyWith({
    bool? isValidatedByWali,
    String? signatureData,
  }) {
    return Setoran(
      id: id,
      santriId: santriId,
      date: date,
      type: type,
      surah: surah,
      ayatStart: ayatStart,
      ayatEnd: ayatEnd,
      kesalahan: kesalahan,
      isValidatedByWali: isValidatedByWali ?? this.isValidatedByWali,
      signatureData: signatureData ?? this.signatureData,
    );
  }
}

class NilaiSemester {
  final String santriId;
  final double setoranPercent; // Maks 40
  final double uasPercent; // Maks 40
  final double akhlaqPercent; // Maks 10
  final double kehadiranPercent; // Maks 10

  NilaiSemester({
    required this.santriId,
    required this.setoranPercent,
    required this.uasPercent,
    required this.akhlaqPercent,
    required this.kehadiranPercent,
  });

  double get totalNilai => setoranPercent + uasPercent + akhlaqPercent + kehadiranPercent;
}

// NEW MODELS
class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String authorName;

  Announcement({required this.id, required this.title, required this.content, required this.date, required this.authorName});
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  ChatMessage({required this.id, required this.senderId, required this.receiverId, required this.text, required this.timestamp});
}

class IzinRecord {
  final String id;
  final String santriId;
  final DateTime date;
  final String reason; // Sakit, Izin
  final String description;
  final String status; // Pending, Approved, Rejected

  IzinRecord({required this.id, required this.santriId, required this.date, required this.reason, required this.description, this.status = 'Pending'});

  IzinRecord copyWith({String? status}) {
    return IzinRecord(id: id, santriId: santriId, date: date, reason: reason, description: description, status: status ?? this.status);
  }
}

class JournalEntry {
  final String id;
  final String santriId;
  final DateTime date;
  final String note;
  final int akhlaqScore; // 1-100

  JournalEntry({required this.id, required this.santriId, required this.date, required this.note, required this.akhlaqScore});
}

class SppRecord {
  final String id;
  final String santriId;
  final String monthYear; // e.g., "06-2026"
  final double amount;
  final DateTime paidDate;
  final String receivedBy; // TU User ID

  SppRecord({required this.id, required this.santriId, required this.monthYear, required this.amount, required this.paidDate, required this.receivedBy});
}

class UkjApproval {
  final String id;
  final String santriId;
  final String status; // Pending, Approved, Rejected
  final DateTime requestDate;

  UkjApproval({required this.id, required this.santriId, required this.status, required this.requestDate});

  UkjApproval copyWith({String? status}) {
    return UkjApproval(id: id, santriId: santriId, status: status ?? this.status, requestDate: requestDate);
  }
}

// Initial Mock Data
class MockData {
  static final List<User> users = [
    User(id: 'u1', name: 'Ustadz Ahmad', role: UserRole.murobbi),
    User(id: 'u2', name: 'Bapak Budi (Wali Zaid)', role: UserRole.wali),
    User(id: 'u3', name: 'Ustadz Farid (Koordinator)', role: UserRole.koordinator),
    User(id: 'u4', name: 'Admin TU', role: UserRole.tu),
    User(id: 'u5', name: 'Kepala Sekolah', role: UserRole.kepalaSekolah),
  ];

  static final List<Santri> santriList = [
    Santri(id: 's1', nis: '24001', name: 'Zaid bin Thabit', kelas: '7A', waliId: 'u2', murobbiId: 'u1'),
    Santri(id: 's2', nis: '24002', name: 'Anas bin Malik', kelas: '7A', waliId: 'u99', murobbiId: 'u1'),
  ];

  static final List<Setoran> setoranList = [
    Setoran(
      id: 'set1',
      santriId: 's1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Sabak',
      surah: 'Al-Baqarah',
      ayatStart: 1,
      ayatEnd: 5,
      kesalahan: 1,
    ),
    Setoran(
      id: 'set2',
      santriId: 's1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Sabki',
      surah: 'Al-Fatihah',
      ayatStart: 1,
      ayatEnd: 7,
      kesalahan: 0,
    ),
    Setoran(
      id: 'set3',
      santriId: 's1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Manzil',
      surah: 'An-Naba',
      ayatStart: 1,
      ayatEnd: 40,
      kesalahan: 4, // Trigger Tikrar
      isValidatedByWali: false,
    ),
  ];

  static final List<NilaiSemester> nilaiList = [
    NilaiSemester(santriId: 's1', setoranPercent: 35, uasPercent: 38, akhlaqPercent: 9, kehadiranPercent: 10),
    NilaiSemester(santriId: 's2', setoranPercent: 20, uasPercent: 30, akhlaqPercent: 8, kehadiranPercent: 8),
  ];

  static final List<Announcement> announcements = [
    Announcement(
      id: 'a1',
      title: 'Pendaftaran Ujian Kenaikan Juz (UKJ) Dibuka',
      content: 'Assalamu\'alaikum. Mengingatkan kepada seluruh santri dan wali bahwa pendaftaran UKJ telah dibuka hingga akhir pekan ini.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      authorName: 'Ustadz Farid (Koordinator)',
    ),
    Announcement(
      id: 'a2',
      title: 'Libur Idul Adha 1447 H',
      content: 'Kegiatan halaqoh tahfiz diliburkan selama 3 hari dalam rangka Hari Raya Idul Adha. Santri diharapkan tetap murojaah di rumah.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      authorName: 'Kepala Sekolah',
    ),
  ];

  static final List<ChatMessage> chatMessages = [
    ChatMessage(id: 'c1', senderId: 'u2', receiverId: 'u1', text: 'Assalamu\'alaikum Ustadz, bagaimana hafalan Zaid hari ini?', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    ChatMessage(id: 'c2', senderId: 'u1', receiverId: 'u2', text: 'Wa\'alaikumsalam Bapak. Alhamdulillah Zaid hari ini lancar Sabaknya, namun Manzilnya masih banyak tersendat.', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
  ];

  static final List<IzinRecord> izinRecords = [
    IzinRecord(id: 'i1', santriId: 's1', date: DateTime.now().add(const Duration(days: 1)), reason: 'Sakit', description: 'Demam sejak semalam, mohon izin tidak ikut halaqoh.', status: 'Pending'),
  ];

  static final List<JournalEntry> journals = [
    JournalEntry(id: 'j1', santriId: 's1', date: DateTime.now().subtract(const Duration(days: 1)), note: 'Masih sering terburu-buru saat ghunnah.', akhlaqScore: 85),
  ];

  static final List<SppRecord> sppRecords = [
    SppRecord(id: 'spp1', santriId: 's1', monthYear: '06-2026', amount: 250000, paidDate: DateTime.now().subtract(const Duration(days: 10)), receivedBy: 'u4'),
  ];

  static final List<UkjApproval> ukjApprovals = [
    UkjApproval(id: 'ukj1', santriId: 's1', status: 'Pending', requestDate: DateTime.now().subtract(const Duration(days: 2))),
  ];
}
