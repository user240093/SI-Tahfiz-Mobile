import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase_client.dart';

class AuditTrailNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  AuditTrailNotifier() : super(const AsyncValue.loading()) {
    fetchAuditTrail();
  }

  Future<void> fetchAuditTrail() async {
    state = const AsyncValue.loading();
    try {
      final data = await supabase
          .from('audit_trail')
          .select('*, profiles!user_id(nama_lengkap, role)')
          .order('created_at', ascending: false);
      
      state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<int> deleteOldAuditTrail() async {
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final response = await supabase
        .from('audit_trail')
        .delete()
        .lt('created_at', threeMonthsAgo.toIso8601String())
        .select();
    
    final count = (response as List).length;
    await fetchAuditTrail();
    return count;
  }
}

final auditTrailProvider = StateNotifierProvider<AuditTrailNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return AuditTrailNotifier();
});
