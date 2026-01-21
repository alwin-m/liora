import 'cycle_state.dart';
import 'local_cycle_storage.dart';

/// ===================================================================
/// CYCLE STATE MANAGER - SINGLETON WITH LAZY LOADING
/// Ensures state is loaded ONCE and reused across the app
/// ===================================================================
class CycleStateManager {
  static final CycleStateManager _instance = CycleStateManager._internal();
  
  static CycleStateManager get instance => _instance;

  CycleStateManager._internal();

  CycleState? _cachedState;
  Future<CycleState>? _loadingFuture;
  bool _isInitialized = false;

  /// Check if state is already cached (instant access)
  bool get isCached => _cachedState != null;

  /// Get cached state synchronously (only if already loaded)
  CycleState? getCachedState() => _cachedState;

  /// Load state asynchronously (loads once, then caches)
  Future<CycleState> loadState() async {
    // If already loading, return the same future
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    // If already loaded, return immediately
    if (_isInitialized && _cachedState != null) {
      return _cachedState!;
    }

    // Start loading
    _loadingFuture = _performLoad();
    final state = await _loadingFuture!;
    _cachedState = state;
    _isInitialized = true;
    return state;
  }

  /// Internal load operation
  Future<CycleState> _performLoad() async {
    return await LocalCycleStorage.loadCycleState();
  }

  /// Update state and persist
  Future<void> updateState(CycleState newState) async {
    _cachedState = newState;
    await LocalCycleStorage.saveCycleState(newState);
  }

  /// Clear cache (for testing or logout)
  void clearCache() {
    _cachedState = null;
    _isInitialized = false;
    _loadingFuture = null;
  }
}
