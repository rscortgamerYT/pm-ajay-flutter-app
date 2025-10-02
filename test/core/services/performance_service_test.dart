import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pm_ajay/core/services/performance_service.dart';

void main() {
  late PerformanceService performanceService;

  setUpAll(() async {
    await Hive.initFlutter();
  });

  setUp(() async {
    performanceService = PerformanceService();
    await performanceService.initialize();
  });

  tearDown(() async {
    await performanceService.clearAll();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('PerformanceService Cache Tests', () {
    test('should cache and retrieve data', () async {
      const testKey = 'test_key';
      const testValue = 'test_value';

      await performanceService.setCached(testKey, testValue);
      final cached = await performanceService.getCached<String>(testKey);

      expect(cached, testValue);
    });

    test('should return null for non-existent key', () async {
      final cached = await performanceService.getCached<String>('non_existent');
      expect(cached, isNull);
    });

    test('should expire cache after duration', () async {
      const testKey = 'expire_test';
      const testValue = 'expire_value';

      await performanceService.setCached(testKey, testValue);
      
      // Wait for cache to expire
      await Future.delayed(const Duration(milliseconds: 100));
      
      final cached = await performanceService.getCached<String>(
        testKey,
        maxAge: const Duration(milliseconds: 50),
      );

      expect(cached, isNull);
    });

    test('should clear specific cache entry', () async {
      const testKey = 'clear_test';
      const testValue = 'clear_value';

      await performanceService.setCached(testKey, testValue);
      await performanceService.clearCache(testKey);
      
      final cached = await performanceService.getCached<String>(testKey);
      expect(cached, isNull);
    });

    test('should clear all cache entries', () async {
      await performanceService.setCached('key1', 'value1');
      await performanceService.setCached('key2', 'value2');
      await performanceService.clearAll();

      final cached1 = await performanceService.getCached<String>('key1');
      final cached2 = await performanceService.getCached<String>('key2');

      expect(cached1, isNull);
      expect(cached2, isNull);
    });

    test('should get cache statistics', () {
      final stats = performanceService.getCacheStats();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('memoryCacheSize'), isTrue);
      expect(stats.containsKey('diskCacheSize'), isTrue);
    });

    test('should batch get multiple cached items', () async {
      await performanceService.setCached('batch1', 'value1');
      await performanceService.setCached('batch2', 'value2');

      final results = await performanceService.batchGet(['batch1', 'batch2']);

      expect(results.length, 2);
      expect(results['batch1'], 'value1');
      expect(results['batch2'], 'value2');
    });

    test('should batch set multiple cached items', () async {
      await performanceService.batchSet({
        'batch_set1': 'value1',
        'batch_set2': 'value2',
      });

      final cached1 = await performanceService.getCached<String>('batch_set1');
      final cached2 = await performanceService.getCached<String>('batch_set2');

      expect(cached1, 'value1');
      expect(cached2, 'value2');
    });
  });

  group('CacheMixin Tests', () {
    test('should cache data with mixin', () async {
      final testClass = _TestClassWithMixin();
      
      final data = await testClass.cachedData('mixin_test', () async {
        return 'mixin_value';
      });

      expect(data, 'mixin_value');

      // Verify it's cached
      final cached = await testClass.cachedData('mixin_test', () async {
        return 'new_value';
      });

      expect(cached, 'mixin_value'); // Should return cached value
    });

    test('should invalidate cache with mixin', () async {
      final testClass = _TestClassWithMixin();
      
      await testClass.cachedData('invalidate_test', () async {
        return 'old_value';
      });

      await testClass.invalidateCache('invalidate_test');

      final newData = await testClass.cachedData('invalidate_test', () async {
        return 'new_value';
      });

      expect(newData, 'new_value');
    });
  });
}

class _TestClassWithMixin with CacheMixin {
  Future<String> cachedData(
    String key,
    Future<String> Function() compute,
  ) {
    return cached(key, compute);
  }
}