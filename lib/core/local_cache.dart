import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lightweight in-memory cache with configurable TTL.
/// Used ONLY for non-sensitive data (products, public documents).
/// Medical / cycle data is NEVER cached here — it uses CycleProvider exclusively.
class LocalCache {
  LocalCache._();

  static final LocalCache _instance = LocalCache._();
  factory LocalCache() => _instance;

  final _store = <String, _CacheEntry>{};

  /// Store [value] under [key] for [ttl] duration.
  void set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    _store[key] = _CacheEntry(value: value, expiresAt: DateTime.now().add(ttl));
  }

  /// Retrieve cached value; returns null if missing or expired.
  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  /// Whether a non-expired entry exists for [key].
  bool has(String key) => get(key) != null;

  /// Remove a single key.
  void invalidate(String key) => _store.remove(key);

  /// Clear all cache entries (e.g., on logout).
  void clear() => _store.clear();

  /// Run a getter, falling back to [compute] and caching the result.
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final cached = get<T>(key);
    if (cached != null) return cached;
    final value = await compute();
    set(key, value, ttl: ttl);
    return value;
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  _CacheEntry({required this.value, required this.expiresAt});
}

// ── Connectivity helper ───────────────────────────────────────────────────────

/// Exponential-backoff retry for any async operation.
Future<T> retryWithBackoff<T>(
  Future<T> Function() op, {
  int maxRetries = 3,
  Duration baseDelay = const Duration(milliseconds: 500),
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await op().timeout(const Duration(seconds: 5));
    } catch (e) {
      attempt++;
      if (attempt >= maxRetries) rethrow;
      final delay = baseDelay * (1 << (attempt - 1)); // 500ms → 1s → 2s
      debugPrint(
        '[Retry] Attempt $attempt failed, waiting ${delay.inMilliseconds}ms…',
      );
      await Future<void>.delayed(delay);
    }
  }
}
