library signal;

import 'dart:async';
import 'package:async/async.dart' show StreamGroup;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Abstract base class for reactive Signals with automatic state management.
///
/// Provides busy/success/error states and Stream-based notifications.
///
/// ```dart
/// class CounterSignal extends Signal {
///   int _count = 0;
///   int get count => _count;
///
///   void increment() {
///     setState(() async => _count++);
///   }
/// }
/// ```
abstract class Signal {
  /// Broadcast StreamController to notify listeners about state changes.
  final StreamController<void> _controller = StreamController<void>.broadcast(sync: true);

  /// Stream of state change events.
  Stream<void> get _stream => _controller.stream;

  /// Holds subscriptions to parent signals.
  final List<StreamSubscription> _subscriptions = [];

  // Debug fields
  late final String _debugName;
  final List<String> _parentSignalTypes = [];
  final Stopwatch _operationStopwatch = Stopwatch();

  bool _disposed = false;

  bool _busy = false;
  bool _success = true;
  String? _error;

  /// Constructor initializes debug name and registers signal.
  Signal() {
    _debugName = runtimeType.toString();
    if (SignalDebugConfig.enableLogging) {
      debugPrint('🔄 Signal[$_debugName] created');
    }
    SignalDebugRegistry.register(this);
  }

  /// Whether the signal is currently busy.
  bool get busy => _busy;

  /// Whether the last operation succeeded.
  bool get success => _success;

  /// Last error message, if any.
  String? get error => _error;

  /// Whether the signal is disposed.
  bool get isDisposed => _disposed;

  /// Notify listeners about a state change.
  void _emit() {
    if (SignalDebugConfig.enableStateTrace) {
      debugPrint('📡 Signal[$_debugName] emitting: busy=$_busy, success=$_success, error=$_error');
    }

    assert(() {
      if (_disposed) {
        debugPrint('⚠️ Signal[$_debugName] emitting from disposed signal!');
      }
      return true;
    }());

    if (!_disposed && !_controller.isClosed) {
      _controller.add(null);
    }
  }

  /// Sets the signal as busy and notifies listeners.
  ///
  /// ```dart
  /// void loadData() {
  ///   setBusy(); // Shows loading state
  ///   // ... async operation
  /// }
  /// ```
  void setBusy() {
    if (_disposed) return;
    if (!_busy) {
      _busy = true;
      _success = false;
      _error = null;
      _emit();
    }
  }

  /// Sets the signal as successful and notifies listeners.
  ///
  /// ```dart
  /// void loadData() async {
  ///   setBusy();
  ///   _data = await api.fetchData();
  ///   setSuccess(); // Shows success state
  /// }
  /// ```
  void setSuccess() {
    if (_disposed) return;
    _busy = false;
    _success = true;
    _error = null;
    _emit();
  }

  /// Sets the signal as errored with optional message.
  ///
  /// ```dart
  /// try {
  ///   await api.fetchData();
  /// } catch (e) {
  ///   setError('Failed to load: $e');
  /// }
  /// ```
  void setError(String? error) {
    if (_disposed) return;
    _busy = false;
    _success = false;
    _error = error;
    _emit();
  }

  /// Runs async operations with automatic state management.
  ///
  /// Automatically handles busy/success/error states.
  ///
  /// ```dart
  /// void loadUsers() {
  ///   setState(() async {
  ///     users = await api.fetchUsers();
  ///   });
  /// }
  /// ```
  Future<void> setState({
    required FutureOr<void> Function() apply,
    String Function(dynamic error)? onError,
  }) async {
    if (_disposed) return;

    if (SignalDebugConfig.enablePerformanceMonitoring) {
      _operationStopwatch.start();
    }

    try {
      setBusy();
      await apply();
      setSuccess();

      if (SignalDebugConfig.enablePerformanceMonitoring) {
        _operationStopwatch.stop();
        debugPrint('⏱️ Signal[$_debugName] operation took: ${_operationStopwatch.elapsedMilliseconds}ms');
        _operationStopwatch.reset();
      }
    } catch (e) {
      if (SignalDebugConfig.enableLogging) {
        debugPrint('❌ Signal[$_debugName] error: $e');
      }
      setError(onError?.call(e) ?? e.toString());
    }
  }

  /// Subscribe to parent Signal updates.
  ///
  /// Call in `initState()` to create reactive parent-child relationships.
  ///
  /// ```dart
  /// @override
  /// void initState(BuildContext context) {
  ///   super.initState(context);
  ///   subscribeToParent<UserSignal>(context, (user) {
  ///     if (user.userId != null) loadProfile(user.userId!);
  ///   });
  /// }
  /// ```
  void subscribeToParent<S extends Signal>(
    BuildContext context,
    void Function(S signal) onUpdate,
  ) {
    // Explicit type check
    if (S == dynamic) {
      throw ArgumentError('Signal type must be specified');
    }
    if (_disposed) return;

    if (SignalDebugConfig.enableParentChildTrace) {
      _parentSignalTypes.add(S.toString());
      debugPrint('🔗 Signal[$_debugName] subscribing to parent: ${S.toString()}');
    }

    try {
      final parentSignal = SignalProvider.of<S>(context);
      final subscription = parentSignal._stream.listen((_) {
        if (!_disposed) {
          onUpdate(parentSignal);
        }
      });
      _subscriptions.add(subscription);
    } catch (e) {
      debugPrint('⚠️ Signal[$_debugName] could not find parent signal of type $S in context');
    }
  }

  /// Override to initialize signals and subscriptions.
  ///
  /// ```dart
  /// @override
  /// void initState(BuildContext context) {
  ///   super.initState(context);
  ///   subscribeToParent<UserSignal>(context, (user) { /* ... */ });
  ///   loadInitialData();
  /// }
  /// ```
  void initState(BuildContext context) {}

  /// Clean up resources and subscriptions.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    if (SignalDebugConfig.enableLogging) {
      debugPrint('🗑️ Signal[$_debugName] disposing');
    }

    SignalDebugRegistry.unregister(this);

    for (final sub in _subscriptions) {
      await sub.cancel();
    }

    if (!_controller.isClosed) {
      await _controller.close();
    }
    _subscriptions.clear();
  }

  /// Debug information about this signal.
  ///
  /// Returns a map containing current state and debug info.
  /// Only available in debug mode.
  Map<String, dynamic> get debugInfo => {
        'name': _debugName,
        'disposed': _disposed,
        'busy': _busy,
        'success': _success,
        'error': _error,
        'parentSignals': _parentSignalTypes,
        'subscriptionCount': _subscriptions.length,
      };
}

/// Provides Signal instances to widget tree and manages lifecycle.
///
/// ```dart
/// SignalProvider<CounterSignal>(
///   signal: (context) => CounterSignal(),
///   child: MyApp(),
/// )
/// ```
class SignalProvider<S extends Signal> extends StatefulWidget {
  /// Factory function creating the Signal instance.
  final S Function(BuildContext context) signal;

  /// The widget subtree which can access the Signal.
  final Widget child;

  const SignalProvider({
    super.key,
    required this.signal,
    required this.child,
  });

  @override
  State<SignalProvider<S>> createState() => _SignalProviderState<S>();

  /// Retrieves Signal from nearest ancestor SignalProvider.
  ///
  /// ```dart
  /// final counter = SignalProvider.of<CounterSignal>(context);
  /// counter.increment();
  /// ```
  static S of<S extends Signal>(BuildContext context) {
    final provider = context.findAncestorWidgetOfExactType<_InheritedSignalProvider<S>>();

    if (provider == null) {
      throw FlutterError(
        'SignalProvider.of<$S>() called with a context that does not contain '
        'a SignalProvider of type $S.\n'
        'Make sure that SignalProvider<$S> is an ancestor of the widget '
        'that calls SignalProvider.of<$S>().',
      );
    }

    return provider.signal;
  }
}

class _SignalProviderState<S extends Signal> extends State<SignalProvider<S>> {
  late final S _signal;

  @override
  void initState() {
    super.initState();
    _signal = widget.signal(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_signal.isDisposed) {
        _signal.initState(context);
      }
    });
  }

  @override
  void dispose() {
    _signal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSignalProvider<S>(
      signal: _signal,
      child: widget.child,
    );
  }
}

class _InheritedSignalProvider<S extends Signal> extends InheritedWidget {
  final S signal;

  const _InheritedSignalProvider({
    required this.signal,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedSignalProvider<S> oldWidget) => false; // changes handled via streams
}

/// Type definition for SignalProvider factory function.
///
/// Similar to VoidCallback, this provides a clean type for signal factories.
typedef SignalFactory = Widget Function(Widget child);

/// Provides multiple signals efficiently with factory functions.
///
/// ```dart
/// MultiSignalProvider(
///   signals: [
///     signalItem<UserSignal>(() => UserSignal()),
///     signalItem<ProfileSignal>(() => ProfileSignal()),
///   ],
///   child: MyApp(),
/// )
/// ```
class MultiSignalProvider extends StatelessWidget {
  final List<SignalFactory> signals;
  final Widget child;

  const MultiSignalProvider({
    super.key,
    required this.signals,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget tree = child;

    // Build from inside out (reverse order)
    for (int i = signals.length - 1; i >= 0; i--) {
      tree = signals[i](tree);
    }

    return tree;
  }
}

/// Creates SignalProvider factory with minimal syntax.
///
/// ```dart
/// signalItem<CounterSignal>(() => CounterSignal())
/// ```
SignalFactory signalItem<S extends Signal>(S Function() create) {
  return (Widget child) => SignalProvider<S>(
        signal: (context) => create(),
        child: child,
      );
}

/// Listens to Signal changes and rebuilds UI automatically.
///
/// ```dart
/// SignalBuilder<CounterSignal>(
///   builder: (context, signal, child) {
///     return Column(
///       children: [
///         Text('Count: ${signal.count}'),
///         if (signal.busy) CircularProgressIndicator(),
///         if (signal.error != null) Text('Error: ${signal.error}'),
///       ],
///     );
///   },
/// )
/// ```
class SignalBuilder<S extends Signal> extends StatefulWidget {
  /// Builds widgets with the current signal and optional static child.
  final Widget Function(BuildContext context, S signal, Widget? child) builder;

  /// Optional static child widget.
  final Widget? child;

  const SignalBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  State<SignalBuilder<S>> createState() => _SignalBuilderState<S>();
}

class _SignalBuilderState<S extends Signal> extends State<SignalBuilder<S>> {
  StreamSubscription<void>? _subscription;
  S? _signal;

  @override
  void initState() {
    super.initState();
    _setupSignal();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupSignal();
  }

  void _setupSignal() {
    final signal = SignalProvider.of<S>(context);

    if (_signal != signal) {
      _subscription?.cancel();
      _signal = signal;

      _subscription = signal._stream.listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_signal == null) {
      return const SizedBox.shrink(); // Or loading widget
    }
    return widget.builder(context, _signal!, widget.child);
  }
}

/// ######################## Debug Support ########################
///
/// ```dart
/// SignalDebugConfig.enableLogging = true;
/// SignalDebugPanel(signals: SignalDebugRegistry.allSignals)
/// ```

/// Debug configuration for Signal development tools.
///
/// All debug features are automatically disabled in release mode.
class SignalDebugConfig {
  /// Enable general signal logging (creation, disposal, warnings).
  static bool enableLogging = kDebugMode;

  /// Enable state transition logging (busy/success/error changes).
  static bool enableStateTrace = kDebugMode;

  /// Enable parent-child relationship logging.
  static bool enableParentChildTrace = kDebugMode;

  /// Enable performance monitoring for setState operations.
  static bool enablePerformanceMonitoring = kDebugMode;
}

/// Global registry to track all active signals for debugging.
class SignalDebugRegistry {
  static final Map<String, Signal> _registry = {};

  /// Register a signal for debugging.
  static void register(Signal signal) {
    if (kDebugMode) {
      _registry[signal._debugName] = signal;
    }
  }

  /// Unregister a signal from debugging.
  static void unregister(Signal signal) {
    if (kDebugMode) {
      _registry.remove(signal._debugName);
    }
  }

  /// Get all currently active signals.
  static List<Signal> get allSignals => _registry.values.toList();

  /// Print debug info for all active signals to console.
  static void printAllSignals() {
    if (kDebugMode) {
      debugPrint('🔍 Active Signals (${_registry.length}):');
      for (final signal in _registry.values) {
        debugPrint('  - ${signal.debugInfo}');
      }
    }
  }
}

// /// Debug panel widget for visualizing signal states in development.
// ///
// /// ```dart
// /// if (kDebugMode)
// ///   SignalDebugPanel(signals: SignalDebugRegistry.allSignals),
// /// ```
// class SignalDebugPanel extends StatelessWidget {
//   /// List of signals to display in the debug panel.
//   final List<Signal> signals;

//   const SignalDebugPanel({super.key, required this.signals});

//   @override
//   Widget build(BuildContext context) {
//     if (!kDebugMode) return const SizedBox.shrink();

//     return Material(
//       child: ExpansionTile(
//         title: Text('🔍 Signal Debug Panel (${signals.length} signals)'),
//         children: signals.map((signal) {
//           final info = signal.debugInfo;
//           return ListTile(
//             title: Text(info['name']),
//             subtitle: Text('Busy: ${info['busy']}, Success: ${info['success']}, Error: ${info['error']?.toString() ?? 'None'}'),
//             trailing: info['busy']
//                 ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
//                 : info['error'] != null
//                     ? const Icon(Icons.error, color: Colors.red)
//                     : const Icon(Icons.check, color: Colors.green),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

/// Debug panel widget for visualizing signal states in development.
///
/// ```dart
/// if (kDebugMode)
///   SignalDebugPanel(signals: SignalDebugRegistry.allSignals),
/// ```
class SignalDebugPanel extends StatelessWidget {
  /// List of signals to display in the debug panel.
  final List<Signal> signals;

  const SignalDebugPanel({super.key, required this.signals});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    // Eğer signal listesi boşsa
    if (signals.isEmpty) {
      return const Material(
        child: ExpansionTile(
          title: Text('🔍 Signal Debug Panel (0 signals)'),
          children: [
            ListTile(
              title: Text('No signals registered'),
              leading: Icon(Icons.info_outline),
            ),
          ],
        ),
      );
    }
    // Tüm signal stream'lerini birleştir
    final combinedStream = StreamGroup.merge(signals.map((s) => s._stream));

    return StreamBuilder<void>(
      stream: combinedStream,
      builder: (context, snapshot) {
        return Material(
          child: ExpansionTile(
            title: Text('🔍 Signal Debug Panel (${signals.length} signals)'),
            children: signals.map((signal) {
              final info = signal.debugInfo;
              return ListTile(
                title: Text(info['name']),
                subtitle: Text('Busy: ${info['busy']}, Success: ${info['success']}, Error: ${info['error']?.toString() ?? 'None'}'),
                trailing: info['busy']
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator())
                    : info['error'] != null
                        ? const Icon(Icons.error, color: Colors.red)
                        : const Icon(Icons.check, color: Colors.green),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
