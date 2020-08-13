import 'package:signal/src/BaseLifeCycle.dart';

/// Base class for a state to be used in [StateChannel]
/// This class must be inherited to create a state.
abstract class BaseState implements BaseLifeCycle {
  BaseState(this._onStateChanged);

  ///A callback that sends a [ChannelSignal] to the [StateChannel]
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

  void setState(
      {bool busy,
      bool success,
      String error,
      void Function() myOnStateChanged}) {
    _busy = busy ?? _busy;
    _success = success ?? _success;
    _error = error ?? _error;
    myOnStateChanged?.call();
  }

  void wait({signal = true}) {
    if (!_busy) {
      _busy = true;
      _error = '';

      if (signal) _onStateChanged?.call();
    }
  }

  void doneSucces({signal = true}) {
    _busy = false;
    _success = true;
    _error = '';
    if (signal) _onStateChanged?.call();
  }

  void doneError(String error, {signal = true}) {
    _busy = false;
    _success = false;
    _error = error;
    if (signal) _onStateChanged?.call();
  }

  void stateFromMap(Map<String, dynamic> map) {
    _busy = map['busy'];
    _success = map['success'];
    _error = map['error'];
  }

  Map<String, dynamic> stateToMap() {
    return <String, dynamic>{
      'busy': _busy,
      'success': _success,
      'error': _error
    };
  }

  @override
  String toString() => 'busy: $_busy, success: $_success, error : $_error';
}
