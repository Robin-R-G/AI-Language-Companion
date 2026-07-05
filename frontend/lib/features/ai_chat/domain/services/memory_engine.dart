// lib/features/ai_chat/domain/services/memory_engine.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'memory_engine.g.dart';

class MemoryEntry {
  final String id;
  final String userId;
  final String type; // 'vocabulary', 'grammar', 'conversation', 'preference'
  final String key;
  final dynamic value;
  final int strength; // 0-100
  final DateTime lastAccessed;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  MemoryEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.key,
    required this.value,
    required this.strength,
    required this.lastAccessed,
    required this.createdAt,
    this.metadata,
  });
}

@riverpod
class MemoryEngine extends _$MemoryEngine {
  final Map<String, MemoryEntry> _memoryCache = {};
  final Uuid _uuid = const Uuid();

  @override
  Map<String, MemoryEntry> build() {
    return _memoryCache;
  }

  Future<void> loadMemories(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('ai_memory')
          .select()
          .eq('user_id', userId)
          .order('last_accessed', ascending: false)
          .limit(100);

      if (response != null) {
        for (final item in response) {
          final entry = MemoryEntry(
            id: item['id'],
            userId: item['user_id'],
            type: item['memory_type'],
            key: item['memory_key'],
            value: item['memory_value'],
            strength: item['strength'] ?? 50,
            lastAccessed: DateTime.parse(item['last_accessed']),
            createdAt: DateTime.parse(item['created_at']),
            metadata: item['metadata'],
          );
          _memoryCache[entry.key] = entry;
        }
        state = Map.from(_memoryCache);
      }
    } catch (e) {
      print('Error loading memories: $e');
    }
  }

  Future<void> storeMemory({
    required String userId,
    required String type,
    required String key,
    required dynamic value,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = MemoryEntry(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      key: key,
      value: value,
      strength: 50,
      lastAccessed: DateTime.now(),
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _memoryCache[key] = entry;
    state = Map.from(_memoryCache);

    // Persist to Supabase
    try {
      await Supabase.instance.client.from('ai_memory').insert({
        'id': entry.id,
        'user_id': userId,
        'memory_type': type,
        'memory_key': key,
        'memory_value': value,
        'strength': entry.strength,
        'metadata': metadata,
      });
    } catch (e) {
      print('Error storing memory: $e');
    }
  }

  Future<void> reinforceMemory(String key, {int amount = 10}) async {
    if (!_memoryCache.containsKey(key)) return;

    final entry = _memoryCache[key]!;
    final newStrength = (entry.strength + amount).clamp(0, 100);

    _memoryCache[key] = MemoryEntry(
      id: entry.id,
      userId: entry.userId,
      type: entry.type,
      key: entry.key,
      value: entry.value,
      strength: newStrength,
      lastAccessed: DateTime.now(),
      createdAt: entry.createdAt,
      metadata: entry.metadata,
    );

    state = Map.from(_memoryCache);

    // Update in Supabase
    try {
      await Supabase.instance.client
          .from('ai_memory')
          .update({
            'strength': newStrength,
            'last_accessed': DateTime.now().toIso8601String(),
          })
          .eq('id', entry.id);
    } catch (e) {
      print('Error reinforcing memory: $e');
    }
  }

  Future<void> forgetMemory(String key) async {
    if (!_memoryCache.containsKey(key)) return;

    final entry = _memoryCache[key]!;
    _memoryCache.remove(key);
    state = Map.from(_memoryCache);

    // Delete from Supabase
    try {
      await Supabase.instance.client
          .from('ai_memory')
          .delete()
          .eq('id', entry.id);
    } catch (e) {
      print('Error forgetting memory: $e');
    }
  }

  List<MemoryEntry> searchMemories(String query, {String? type}) {
    return _memoryCache.values.where((entry) {
      final matchesQuery = entry.key.toLowerCase().contains(query.toLowerCase()) ||
          entry.value.toString().toLowerCase().contains(query.toLowerCase());
      final matchesType = type == null || entry.type == type;
      return matchesQuery && matchesType;
    }).toList()
      ..sort((a, b) => b.strength.compareTo(a.strength));
  }

  List<MemoryEntry> getMemoriesByType(String type) {
    return _memoryCache.values
        .where((entry) => entry.type == type)
        .toList()
      ..sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
  }

  Map<String, int> getMemoryStats() {
    final stats = <String, int>{};
    for (final entry in _memoryCache.values) {
      stats[entry.type] = (stats[entry.type] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> cleanupOldMemories({int daysThreshold = 90}) async {
    final threshold = DateTime.now().subtract(Duration(days: daysThreshold));
    final oldMemories = _memoryCache.values
        .where((entry) =>
            entry.lastAccessed.isBefore(threshold) && entry.strength < 30)
        .toList();

    for (final entry in oldMemories) {
      await forgetMemory(entry.key);
    }
  }
}
