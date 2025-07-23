/// A reactive state management library for Flutter applications.
///
/// This library provides a simple and efficient way to manage application state
/// using signals and reactive patterns. It includes providers and builders
/// for seamless integration with Flutter widgets.
library signal;

import 'dart:async';
import 'package:flutter/material.dart';

/// Abstract base class for all signal implementations.
///
/// A Signal represents a reactive state container that can notify listeners
/// when its state changes. It provides built-in support for async operations,
/// loading states, error handling, and success states.
abstract class Signal {
  /// Internal stream controller for broadcasting state changes to listeners.
  /// Internal stream controller for broadcasting state changes to listeners.
  final StreamController<StateSignal> _streamController =
      StreamController<StateSignal>.broadcast();
  bool _disposed = false;

  /// Adds a state change notification to the stream.
  void _add() {
    if (!_disposed && !_streamController.isClosed) {
      _streamController.sink.add(StateSignal());
    }
  }

  /// Called when the signal is first initialized.
  /// Override this method to perform initial setup.
  void initState();

  /// Called after the signal has been initialized and added to the widget tree.
  /// Override this method to perform operations that require context access.
  void afterInitState();

  /// Disposes of the signal and cleans up resources.
  /// This method closes the stream controller to prevent memory leaks.
  Future<void> dispose() async {
    _disposed = true;
    if (!_streamController.isClosed) await _streamController.close();
  }

  bool _busy = false;
  bool _success = true;

  /// Returns true if the signal is currently performing an async operation.
  bool get busy => _busy;

  /// Returns true if the last operation completed successfully.
  bool get success => _success;

  String _error = '';

  /// Returns the current error message and clears it.
  /// This getter automatically resets the error after being accessed.
  /// Returns the current error message and clears it.
  /// This getter automatically resets the error after being accessed.
  String get error {
    String msg = _error;
    _error = '';
    return msg;
  }

  /// Executes an async operation while managing the signal's state.
  ///
  /// This method automatically handles loading states, success states, and error handling.
  ///
  /// Parameters:
  /// - [op]: The async operation to execute
  /// - [waitSignal]: Whether to emit a signal when starting the operation (default: true)
  /// - [doneSuccessSignal]: Whether to emit a signal on successful completion (default: true)
  /// - [doneErrorSignal]: Whether to emit a signal on error (default: true)
  /// - [onDoneError]: Custom error message formatter (optional)
  Future<void> setState(FutureOr<void> Function()? op,
      {bool waitSignal = true,
      bool doneSuccessSignal = true,
      bool doneErrorSignal = true,
      String Function(dynamic e)? onDoneError}) async {
    try {
      wait(signal: waitSignal);
      await op?.call();
      doneSuccess(signal: doneSuccessSignal);
    } catch (e) {
      doneError(onDoneError?.call(e) ?? e.toString(), signal: doneErrorSignal);
    }
  }

  /// Sets the signal to a waiting/loading state.
  ///
  /// Parameters:
  /// - [signal]: Whether to emit a state change notification (default: true)
  void wait({bool signal = true}) {
    if (!_busy) {
      _busy = true;
      _error = '';

      if (signal) _add();
    }
  }

  /// Sets the signal to a successful completion state.
  ///
  /// Parameters:
  /// - [signal]: Whether to emit a state change notification (default: true)
  void doneSuccess({bool signal = true}) {
    _busy = false;
    _success = true;
    _error = '';
    if (signal) _add();
  }

  /// Sets the signal to an error state with the provided error message.
  ///
  /// Parameters:
  /// - [error]: The error message to set
  /// - [signal]: Whether to emit a state change notification (default: true)
  void doneError(String error, {bool signal = true}) {
    _busy = false;
    _success = false;
    _error = error;
    if (signal) _add();
  }
}

/// A StatefulWidget that provides a Signal instance to its child widgets.
///
/// This widget creates and manages the lifecycle of a Signal instance,
/// making it available to descendant widgets through the widget tree.
///
/// Example:
/// ```dart
/// SignalProvider<MySignal>(
///   signal: (context) => MySignal(),
///   child: MyApp(),
/// )
/// ```
class SignalProvider<S extends Signal> extends StatefulWidget {
  /// Creates a SignalProvider.
  ///
  /// The [signal] parameter is a factory function that creates the signal instance.
  /// The [child] parameter is the widget subtree that will have access to the signal.
  const SignalProvider({
    super.key,
    required this.signal,
    required this.child,
  });

  /// Factory function that creates the signal instance.
  /// The BuildContext is provided to allow context-dependent initialization.
  final S Function(BuildContext context) signal;

  /// The widget subtree that will have access to the signal.
  final Widget child;

  @override
  State<SignalProvider<S>> createState() => _SignalProviderState<S>();

  /// Retrieves the nearest Signal of type [S] from the widget tree.
  ///
  /// This method looks up the widget tree to find a SignalProvider that provides
  /// a signal of the specified type. Throws an assertion error if no matching
  /// signal is found.
  ///
  /// Example:
  /// ```dart
  /// final mySignal = SignalProvider.of<MySignal>(context);
  /// ```
  static S of<S extends Signal>(BuildContext context) {
    final S? result = context
        .findAncestorWidgetOfExactType<_InheritedSignalProvider<S>>()
        ?.signal;
    assert(result != null, 'No Signal found in context');
    return result!;
  }
}

/// Internal state management for SignalProvider.
///
/// This class handles the creation, initialization, and disposal of Signal instances.
class _SignalProviderState<S extends Signal> extends State<SignalProvider<S>> {
  /// The signal instance managed by this provider.
  late final S signal;

  @override
  void initState() {
    super.initState();
    signal = widget.signal(context);
    signal.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => signal.afterInitState());
  }

  @override
  void dispose() {
    signal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _InheritedSignalProvider(signal: signal, child: widget.child);
}

/// A widget that rebuilds when a Signal's state changes.
///
/// This widget listens to a Signal and rebuilds its children whenever
/// the signal emits a state change notification.
///
/// Example:
/// ```dart
/// SignalBuilder<MySignal>(
///   builder: (context, signal, child) {
///     return Text('Loading: ${signal.busy}');
///   },
/// )
/// ```
class SignalBuilder<S extends Signal> extends StatefulWidget {
  /// Creates a SignalBuilder.
  ///
  /// The [builder] function is called whenever the signal state changes.
  /// The optional [child] function can be used for performance optimization
  /// by providing a widget that doesn't need to rebuild.
  const SignalBuilder({super.key, required this.builder, this.child});

  /// The builder function that creates the widget tree.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [signal]: The signal instance
  /// - [child]: Optional child widget for optimization
  final Widget Function(BuildContext context, S signal, Widget? child) builder;

  /// Optional child widget factory for performance optimization.
  /// This widget will be passed to the builder function and won't rebuild
  /// when the signal changes.
  final Widget Function()? child;

  @override
  State<SignalBuilder<S>> createState() => _SignalBuilderState<S>();
}

/// Internal state management for SignalBuilder.
///
/// This class manages the subscription to signal changes and handles widget rebuilds.
class _SignalBuilderState<S extends Signal> extends State<SignalBuilder<S>> {
  /// Subscription to the signal's state changes.
  late final StreamSubscription<StateSignal> _subscription;

  /// Cached child widget for performance optimization.
  Widget? child;

  @override
  void initState() {
    super.initState();
    child = widget.child?.call();
    final signal = SignalProvider.of<S>(context);
    _subscription = signal._streamController.stream.listen((stateSignal) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, SignalProvider.of<S>(context), child);
}

/// Internal InheritedWidget for providing Signal instances down the widget tree.
///
/// This widget makes the signal available to descendant widgets without
/// requiring explicit parameter passing.
class _InheritedSignalProvider<S extends Signal> extends InheritedWidget {
  /// Creates an InheritedSignalProvider.
  const _InheritedSignalProvider({
    Key? key,
    required this.signal,
    required Widget child,
  }) : super(key: key, child: child);

  /// The signal instance to provide to descendant widgets.
  final S signal;

  @override
  bool updateShouldNotify(covariant _InheritedSignalProvider<S> oldWidget) =>
      false;
}

/// Event class for signal state changes.
///
/// This class represents a state change notification that is broadcast
/// to all listeners when a signal's state is modified.
class StateSignal {}
