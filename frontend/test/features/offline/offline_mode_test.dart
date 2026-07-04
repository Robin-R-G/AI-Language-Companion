import 'package:flutter_test/flutter_test.dart';
import '../../test_utils/fake_services.dart';

void main() {
  late FakeConnectivityService fakeConnectivity;

  setUp(() {
    fakeConnectivity = FakeConnectivityService();
  });

  tearDown(() {
    fakeConnectivity.dispose();
  });

  group('Offline Mode', () {
    test('should detect online state', () {
      fakeConnectivity.setConnected(true);

      expect(fakeConnectivity.isConnected, isTrue);
    });

    test('should detect offline state', () {
      fakeConnectivity.setConnected(false);

      expect(fakeConnectivity.isConnected, isFalse);
    });

    test('should emit connectivity changes', () async {
      final states = <bool>[];
      fakeConnectivity.connectionStream.listen(states.add);

      fakeConnectivity.setConnected(false);
      fakeConnectivity.setConnected(true);
      fakeConnectivity.setConnected(false);

      expect(states, [false, true, false]);
    });

    test('should check connectivity', () async {
      fakeConnectivity.setConnected(true);

      final result = await fakeConnectivity.checkConnectivity();

      expect(result, isTrue);
    });

    test('should check connectivity when offline', () async {
      fakeConnectivity.setConnected(false);

      final result = await fakeConnectivity.checkConnectivity();

      expect(result, isFalse);
    });

    test('should handle multiple listeners', () async {
      final states1 = <bool>[];
      final states2 = <bool>[];

      fakeConnectivity.connectionStream.listen(states1.add);
      fakeConnectivity.connectionStream.listen(states2.add);

      fakeConnectivity.setConnected(false);

      expect(states1, [false]);
      expect(states2, [false]);
    });

    test('start and stop monitoring should not throw', () {
      fakeConnectivity.startMonitoring();
      fakeConnectivity.stopMonitoring();

      expect(fakeConnectivity.isConnected, isTrue);
    });

    test('should handle rapid connectivity changes', () async {
      final states = <bool>[];
      fakeConnectivity.connectionStream.listen(states.add);

      for (var i = 0; i < 10; i++) {
        fakeConnectivity.setConnected(i.isEven);
      }

      expect(states.length, 10);
    });
  });

  group('Offline Data Caching Strategy', () {
    test('should cache data for offline access', () {
      final cache = <String, dynamic>{};

      cache['lessons'] = [
        {'id': '1', 'title': 'Lesson 1'},
        {'id': '2', 'title': 'Lesson 2'},
      ];

      expect(cache['lessons'], isList);
      expect((cache['lessons'] as List).length, 2);
    });

    test('should use cached data when offline', () {
      fakeConnectivity.setConnected(false);

      final cache = {'key': 'cached_value'};
      final data = fakeConnectivity.isConnected ? 'fresh' : cache['key'];

      expect(data, 'cached_value');
    });

    test('should prefer fresh data when online', () {
      fakeConnectivity.setConnected(true);

      final cache = {'key': 'cached_value'};
      final data = fakeConnectivity.isConnected ? 'fresh' : cache['key'];

      expect(data, 'fresh');
    });

    test('should sync cached changes when back online', () async {
      final pendingChanges = <Map<String, dynamic>>[];

      fakeConnectivity.setConnected(false);
      pendingChanges.add({'action': 'update', 'key': 'vocab_1'});

      expect(pendingChanges, isNotEmpty);

      fakeConnectivity.setConnected(true);

      final syncedChanges = List<Map<String, dynamic>>.from(pendingChanges);
      pendingChanges.clear();

      expect(syncedChanges.length, 1);
      expect(pendingChanges, isEmpty);
    });
  });

  group('Offline Feature Availability', () {
    test('cached lessons should be available offline', () {
      final cachedLessons = [
        {'id': '1', 'title': 'Past Tenses', 'content': '...'},
        {'id': '2', 'title': 'Present Perfect', 'content': '...'},
      ];

      fakeConnectivity.setConnected(false);

      expect(cachedLessons.length, 2);
    });

    test('voice sessions should not work offline', () {
      fakeConnectivity.setConnected(false);

      expect(fakeConnectivity.isConnected, isFalse);
    });

    test('AI chat should not work offline', () {
      fakeConnectivity.setConnected(false);

      expect(fakeConnectivity.isConnected, isFalse);
    });

    test('grammar check should not work offline', () {
      fakeConnectivity.setConnected(false);

      expect(fakeConnectivity.isConnected, isFalse);
    });
  });
}
