import 'dart:async';
import 'ChannelSignal.dart';

//Base class for multiple state management
/// This class must be inherited to create your own state channel.
///```dart
/// abstract class MyChannelSignal extends ChannelSignal{}
///
/// class MyChannel extends StateChannel<MyChannelSignal>{
///    ...
/// }
/// ```
abstract class StateChannel<S extends ChannelSignal> {
  ///A controller with the stream it controls.
  final StreamController<S> _streamController = StreamController<S>.broadcast();

  ///Stream as Broadcast Stream.
  Stream<S> get stream => _streamController.stream.asBroadcastStream();

//Sends a StateBroadcast to the state channel
  void add(S signal) {
    if (!_streamController.isClosed) _streamController.sink.add(signal);
  }

  initState() {}

  ///Closes the StateChannel.
  void dispose() {
    _streamController.close();
  }
}
