import 'dart:async';
import 'package:flutter/material.dart';
import 'logger_service.dart';

/// Application lifecycle states.
enum AppState {
  /// App is in the foreground and active.
  active,

  /// App is in the background but not suspended.
  inactive,

  /// App is not visible and may be suspended (background).
  paused,

  /// App is being detached from the host view (rare).
  detached,
}

/// Callback type for lifecycle events.
typedef LifecycleCallback = void Function(AppState state);

/// Manages application lifecycle events.
///
/// Listens to [WidgetsBindingObserver] and provides callbacks
/// for state changes. Useful for pausing/resuming features
/// like voice calls, syncing data, or saving state.
class AppLifecycleService extends WidgetsBindingObserver {
  AppState _currentState = AppState.active;
  final List<LifecycleCallback> _listeners = [];
  final StreamController<AppState> _stateController =
      StreamController<AppState>.broadcast();

  /// Current application state.
  AppState get currentState => _currentState;

  /// Stream of state changes.
  Stream<AppState> get stateStream => _stateController.stream;

  /// Whether the app is currently in the foreground.
  bool get isActive => _currentState == AppState.active;

  /// Whether the app is currently paused/background.
  bool get isPaused =>
      _currentState == AppState.paused || _currentState == AppState.inactive;

  /// Initialize the lifecycle service.
  ///
  /// Call this once during app startup (e.g., in bootstrap).
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    Logger.info('App lifecycle service initialized');
  }

  /// Add a listener for lifecycle events.
  void addListener(LifecycleCallback callback) {
    _listeners.add(callback);
  }

  /// Remove a lifecycle listener.
  void removeListener(LifecycleCallback callback) {
    _listeners.remove(callback);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final newState = _mapLifecycleState(state);
    if (newState != _currentState) {
      _currentState = newState;
      _notifyListeners(newState);
      _stateController.add(newState);
      Logger.debug('App lifecycle state changed: ${newState.name}');
    }
  }

  @override
  void didChangeMetrics() {
    // Handle screen size/orientation changes if needed
  }

  @override
  void didHaveMemoryPressure() {
    Logger.warning('Memory pressure detected');
  }

  @override
  void didChangeAccessibilityFeatures() {
    // Handle accessibility changes if needed
  }

  /// Map Flutter's [AppLifecycleState] to our [AppState].
  AppState _mapLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return AppState.active;
      case AppLifecycleState.inactive:
        return AppState.inactive;
      case AppLifecycleState.paused:
        return AppState.paused;
      case AppLifecycleState.detached:
        return AppState.detached;
      case AppLifecycleState.hidden:
        return AppState.paused;
    }
  }

  /// Notify all listeners of a state change.
  void _notifyListeners(AppState state) {
    for (final listener in _listeners) {
      try {
        listener(state);
      } catch (e) {
        Logger.error('Error in lifecycle listener', e);
      }
    }
  }

  /// Clean up resources.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listeners.clear();
    _stateController.close();
    Logger.info('App lifecycle service disposed');
  }
}
