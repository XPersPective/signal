/// Base class for a state to be used in [StateChannel]
/// This class must be inherited to create a state.
abstract class BaseState {
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

  stateInitLoad(bool busy, {bool success, String error}) {
    _busy = busy;
    _success = success ?? _success;
    _error = error ?? _error;
  }

  _stateSet(bool busy, {bool success, String error}) {
    _busy = busy;
    _success = success ?? _success;
    _error = error ?? _error;
    _onStateChanged?.call();
  }

  void wait() {
    // if(!_busy)
    _stateSet(true);
  }

  doneSucces() {
    _stateSet(false, success: true, error: '');
  }

  doneError([String error = '']) {
    _stateSet(false, success: false, error: error);
  }

  stateFromMap(Map<String, dynamic> map) {
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
  String toString() {
    String str = 'busy: $_busy, success: $_success,  error : $_error';
    return str;
  }
}
