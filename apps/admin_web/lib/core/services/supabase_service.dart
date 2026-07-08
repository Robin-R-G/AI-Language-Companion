import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
  User? get currentUser => auth.currentUser;
  String? get userId => currentUser?.id;
  String? get userEmail => currentUser?.email;
  bool get isAuthenticated => currentUser != null;

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (userId == null) return null;
    try {
      final res = await client
          .from('user_profiles')
          .select()
          .eq('auth_user_id', userId!)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<String> getUserRole() async {
    final profile = await getUserProfile();
    return profile?['role'] ?? 'user';
  }

  Future<List<Map<String, dynamic>>> query({
    required String table,
    String? select,
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
    String? orderBy,
    bool ascending = false,
  }) async {
    var filterBuilder = client.from(table).select(select ?? '*');

    if (filters != null) {
      for (final entry in filters.entries) {
        filterBuilder = filterBuilder.eq(entry.key, entry.value);
      }
    }

    if (orderBy != null && offset != null) {
      return await filterBuilder
          .order(orderBy, ascending: ascending)
          .range(offset, offset + (limit ?? 50) - 1);
    } else if (orderBy != null) {
      return await filterBuilder.order(orderBy, ascending: ascending);
    } else if (offset != null) {
      return await filterBuilder.range(offset, offset + (limit ?? 50) - 1);
    } else if (limit != null) {
      return await filterBuilder.limit(limit);
    }

    return await filterBuilder;
  }

  Future<Map<String, dynamic>?> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    return await client.from(table).insert(data).select().single();
  }

  Future<Map<String, dynamic>?> update({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return await client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
  }

  Future<void> delete({
    required String table,
    required String id,
  }) async {
    await client.from(table).delete().eq('id', id);
  }

  Future<dynamic> invokeFunction({
    required String name,
    HttpMethod method = HttpMethod.post,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final res = await client.functions.invoke(
      name,
      method: method,
      body: body,
      headers: headers,
    );
    return res.data;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
