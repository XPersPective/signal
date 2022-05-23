import 'dart:async';

abstract class BaseLifeCycle {
  void initState();
  void afterInitState();
  void dispose();
}

/// This class must be inherited to create a state.
abstract class BaseState extends _BaseStateCore implements BaseLifeCycle {
  BaseState(void Function() onStateChanged) : super(onStateChanged);
}

class StateHolder<T> extends _BaseStateCore {
  StateHolder({required void Function() onStateChanged, this.data}) : super(onStateChanged);
  T? data;
}

abstract class _BaseStateCore {
  _BaseStateCore(
    this._onStateChanged,
  );

  final void Function() _onStateChanged;

  bool _busy = false;
  bool _success = true;
  bool get busy => _busy;
  bool get success => _success;
  String _error = '';

  String get error {
    String msg = _error;
    _error = '';
    return msg;
  }

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

  void wait({bool signal = true}) {
    if (!_busy) {
      _busy = true;
      _error = '';

      if (signal) _onStateChanged.call();
    }
  }

  void doneSuccess({bool signal = true}) {
    _busy = false;
    _success = true;
    _error = '';
    if (signal) _onStateChanged.call();
  }

  void doneError(String error, {bool signal = true}) {
    _busy = false;
    _success = false;
    _error = error;
    if (signal) _onStateChanged.call();
  }

  void fromMap(Map<String, dynamic> map) {
    _busy = map['busy'];
    _success = map['success'];
    _error = map['error'];
  }

  Map<String, dynamic> toMap() => {'busy': _busy, 'success': _success, 'error': _error};

  @override
  String toString() => 'BaseState(busy: $_busy, success: $_success, error : $_error)';
}
