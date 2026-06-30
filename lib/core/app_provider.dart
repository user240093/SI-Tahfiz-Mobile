import 'package:flutter/material.dart';
import 'mock_data.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  
  // Data Lists
  final List<User> _users = MockData.users;
  final List<Santri> _santriList = MockData.santriList;
  final List<Setoran> _setoranList = MockData.setoranList;
  final List<NilaiSemester> _nilaiList = MockData.nilaiList;
  final List<Announcement> _announcements = MockData.announcements;
  final List<ChatMessage> _chatMessages = MockData.chatMessages;
  final List<IzinRecord> _izinRecords = MockData.izinRecords;
  final List<JournalEntry> _journals = MockData.journals;
  final List<SppRecord> _sppRecords = MockData.sppRecords;
  final List<UkjApproval> _ukjApprovals = MockData.ukjApprovals;

  User? get currentUser => _currentUser;
  List<Santri> get allSantri => _santriList;
  List<Setoran> get allSetoran => _setoranList;
  List<SppRecord> get allSpp => _sppRecords;
  List<UkjApproval> get allUkj => _ukjApprovals;
  List<Announcement> get allAnnouncements {
    var list = List<Announcement>.from(_announcements);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
  
  // --- AUTH ---
  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // --- SANTRI LOGIC ---
  List<Santri> getSantriForMurobbi(String murobbiId) {
    return _santriList.where((s) => s.murobbiId == murobbiId).toList();
  }

  List<Santri> getSantriForWali(String waliId) {
    return _santriList.where((s) => s.waliId == waliId).toList();
  }

  Santri? getSantriById(String id) {
    try {
      return _santriList.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- SETORAN & TIKRAR ---
  List<Setoran> getSetoranForSantri(String santriId) {
    var list = _setoranList.where((s) => s.santriId == santriId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  bool addSetoran(Setoran setoran) {
    bool isDuplicate = _setoranList.any((s) =>
        s.santriId == setoran.santriId &&
        s.type == setoran.type &&
        s.date.year == setoran.date.year &&
        s.date.month == setoran.date.month &&
        s.date.day == setoran.date.day);
    if (isDuplicate) return false;
    _setoranList.add(setoran);
    notifyListeners();
    return true;
  }

  void validateManzil(String setoranId, String signatureData) {
    final index = _setoranList.indexWhere((s) => s.id == setoranId);
    if (index != -1) {
      _setoranList[index] = _setoranList[index].copyWith(isValidatedByWali: true, signatureData: signatureData);
      notifyListeners();
    }
  }

  bool isSantriInTikrar(String santriId) {
    final setoranSantri = getSetoranForSantri(santriId);
    if (setoranSantri.isEmpty) return false;
    int totalKesalahan = 0;
    for (int i = 0; i < setoranSantri.length && i < 3; i++) {
      totalKesalahan += setoranSantri[i].kesalahan;
    }
    return totalKesalahan >= 3; 
  }

  NilaiSemester? getNilai(String santriId) {
    try {
      return _nilaiList.firstWhere((n) => n.santriId == santriId);
    } catch (e) {
      return null;
    }
  }

  // --- ANNOUNCEMENTS ---
  void addAnnouncement(String title, String content) {
    if (_currentUser == null) return;
    _announcements.add(Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      date: DateTime.now(),
      authorName: _currentUser!.name,
    ));
    notifyListeners();
  }

  // --- CHAT SYSTEM ---
  List<ChatMessage> getChatHistory(String peerId) {
    if (_currentUser == null) return [];
    final myId = _currentUser!.id;
    var list = _chatMessages.where((c) => 
      (c.senderId == myId && c.receiverId == peerId) || 
      (c.senderId == peerId && c.receiverId == myId)
    ).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  void sendMessage(String receiverId, String text) {
    if (_currentUser == null || text.trim().isEmpty) return;
    _chatMessages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUser!.id,
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // Get list of users to chat with (Murobbi sees Walis of their santri, Wali sees Murobbis of their children)
  List<User> getChatContacts() {
    if (_currentUser == null) return [];
    Set<String> contactIds = {};
    if (_currentUser!.role == UserRole.murobbi) {
      for (var s in getSantriForMurobbi(_currentUser!.id)) {
        contactIds.add(s.waliId);
      }
    } else if (_currentUser!.role == UserRole.wali) {
      for (var s in getSantriForWali(_currentUser!.id)) {
        contactIds.add(s.murobbiId);
      }
    }
    return _users.where((u) => contactIds.contains(u.id)).toList();
  }

  // --- IZIN SYSTEM ---
  List<IzinRecord> getIzinForSantri(String santriId) {
    var list = _izinRecords.where((i) => i.santriId == santriId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<IzinRecord> getAllPendingIzin() {
    var list = _izinRecords.where((i) => i.status == 'Pending').toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addIzin(String santriId, DateTime date, String reason, String description) {
    _izinRecords.add(IzinRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      santriId: santriId,
      date: date,
      reason: reason,
      description: description,
    ));
    notifyListeners();
  }

  void updateIzinStatus(String izinId, String newStatus) {
    final index = _izinRecords.indexWhere((i) => i.id == izinId);
    if (index != -1) {
      _izinRecords[index] = _izinRecords[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  // --- JOURNAL SYSTEM ---
  List<JournalEntry> getJournalForSantri(String santriId) {
    var list = _journals.where((j) => j.santriId == santriId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  void addJournal(String santriId, String note, int akhlaqScore) {
    _journals.add(JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      santriId: santriId,
      date: DateTime.now(),
      note: note,
      akhlaqScore: akhlaqScore,
    ));
    notifyListeners();
  }

  // --- TU SYSTEM ---
  void addSppPayment(String santriId, String monthYear, double amount) {
    if (_currentUser == null) return;
    _sppRecords.add(SppRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      santriId: santriId,
      monthYear: monthYear,
      amount: amount,
      paidDate: DateTime.now(),
      receivedBy: _currentUser!.id,
    ));
    notifyListeners();
  }

  void addSantri(Santri santri) {
    _santriList.add(santri);
    notifyListeners();
  }

  // --- KEPSEK SYSTEM ---
  void updateUkjStatus(String ukjId, String newStatus) {
    final index = _ukjApprovals.indexWhere((u) => u.id == ukjId);
    if (index != -1) {
      _ukjApprovals[index] = _ukjApprovals[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}
