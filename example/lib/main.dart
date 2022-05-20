import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

void main() {
  runApp(MyApp());
}

abstract class MyChannelSignal extends ChannelSignal {}

class MyChannel extends StateChannel<MyChannelSignal> {
  MyChannel() {
    _counterState = CounterState(() => add(CounterStateSignal()));
    _notificationState = NotificationState(() => add(NotificationStateSignal()));
  }

//signal: CounterStateSignal
  late CounterState _counterState;
  CounterState get counterState => _counterState;

//signal: NotificationStateSignal
  late NotificationState _notificationState;
  NotificationState get notificationState => _notificationState;

  @override
  void initState() {
    _counterState.initState();
    _notificationState.initState();
  }

  @override
  afterInitState() {
    _counterState.afterInitState();
    _notificationState.afterInitState();
  }

  @override
  Future<void> dispose() async {
    _counterState.dispose();
    _notificationState.dispose();
    super.dispose();
  }
}

class CounterStateSignal extends MyChannelSignal {}

class CounterState extends BaseState {
  CounterState(void Function() onStateChanged) : super(onStateChanged);

  int _count = 0;
  int get count => _count;

  @override
  void initState() {
    wait(signal: false);
    _count = 0;
  }

  @override
  Future<void> afterInitState() async {
    await incrementFuture();
  }

  @override
  void dispose() {}

  void increment() {
    _count = _count + 1;
    doneSuccess();
  }

  void decrement() {
    _count = _count - 1;
    doneSuccess();
  }

  Future<void> incrementFuture() async {
    try {
      wait();
      await Future<void>.delayed(Duration(seconds: 5));
      _count = _count + 1;

      doneSuccess();
    } catch (e) {
      doneError(e.toString());
    }
  }

  Future<void> decrementFuture() async {
    try {
      wait();
      await Future<void>.delayed(Duration(seconds: 1));
      _count = _count - 1;

      doneSuccess();
    } catch (e) {
      doneError(e.toString());
    }
  }
}

class NotificationStateSignal extends MyChannelSignal {}

class NotificationState extends BaseState {
  NotificationState(void Function() onStateChanged) : super(onStateChanged);

  bool _isOpen = false;
  bool get isOpen => _isOpen;

  @override
  initState() {
    wait(signal: false);
    _isOpen = false;
  }

  @override
  Future<void> afterInitState() async => await changeFuture();

  @override
  dispose() {}

  change() {
    _isOpen = !_isOpen;
    doneSuccess();
  }

  Future<void> changeFuture() async {
    try {
      wait();
      await Future<void>.delayed(Duration(seconds: 1));
      _isOpen = !_isOpen;

      doneSuccess();
    } catch (e) {
      doneError(e.toString());
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChannelProvider<MyChannel>(
        channel: (context) => MyChannel(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ));
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Signal')),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 45,
            width: 45,
            child: ChannelBuilder<MyChannel, MyChannelSignal>(
              condition: (channel, signal) => signal is CounterStateSignal,
              builder: (context, channel, _) {
                final state = channel.counterState;

                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    !state.success ? Text(state.error) : Text(state.count.toString(), style: TextStyle(fontSize: 25)),
                    if (state.busy) CircularProgressIndicator(),
                  ],
                );
              },
            ),
          ),
          ChannelBuilder<MyChannel, MyChannelSignal>(
              condition: (channel, signal) => signal is NotificationStateSignal,
              builder: (context, channel, _) {
                final state = channel.notificationState;

                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    TextButton(
                      child: Text(state.isOpen ? 'Notification: On' : 'Notification: Off',
                          style: TextStyle(fontSize: 25, color: state.isOpen ? Colors.green : Colors.red)),
                      onPressed: state.busy ? null : () => state.change(),
                    ),
                    if (state.busy) CircularProgressIndicator(),
                  ],
                );
              }),
          SizedBox(
            height: 50,
          ),
          ChannelBuilder<MyChannel, MyChannelSignal>(
            condition: (channel, signal) => signal is CounterStateSignal || signal is NotificationStateSignal,
            builder: (context, channel, _) {
              final state = channel.counterState;
              return ElevatedButton(
                child: Text('CounterState: increment'),
                onPressed: channel.counterState.busy || channel.notificationState.busy ? null : () => state.increment(),
              );
            },
          ),
          ElevatedButton(
            child: Text('CounterState: decrementFuture'),
            onPressed: () => ChannelProvider.of<MyChannel>(context).counterState.decrementFuture(),
          ),
          ElevatedButton(
            child: Text('NotificationState: change'),
            onPressed: () => ChannelProvider.of<MyChannel>(context).notificationState.change(),
          ),
          ElevatedButton(
            child: Text('NotificationState: changeFuture'),
            onPressed: () => ChannelProvider.of<MyChannel>(context).notificationState.changeFuture(),
          ),
        ],
      ),
    );
  }
}
