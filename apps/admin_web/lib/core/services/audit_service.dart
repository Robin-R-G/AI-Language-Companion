import 'supabase_service.dart';

class AuditService {
  AuditService._();
  static final instance = AuditService._();

  final _supabase = SupabaseService.instance;

  Future<void> log({
    required String action,
    required String targetType,
    String? targetId,
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = _supabase.currentUser;
      if (user == null) return;

      await _supabase.insert(
        table: 'admin_audit_logs',
        data: {
          'admin_id': user.id,
          'admin_email': user.email ?? '',
          'action': action,
          'target_type': targetType,
          'target_id': targetId,
          'details': details,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getAuditLogs({
    int limit = 50,
    int offset = 0,
    String? action,
    String? targetType,
    String? adminId,
  }) async {
    var query = _supabase.client
        .from('admin_audit_logs')
        .select();

    if (action != null) {
      query = query.eq('action', action);
    }
    if (targetType != null) {
      query = query.eq('target_type', targetType);
    }
    if (adminId != null) {
      query = query.eq('admin_id', adminId);
    }

    final res = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<int> getAuditLogCount() async {
    final res = await _supabase.client
        .from('admin_audit_logs')
        .select('id')
        .count();
    return res.count;
  }
}
