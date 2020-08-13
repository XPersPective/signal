import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AncestorChannelProvider<MyChannel>(
        channel: MyChannel()..initState(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AncestorChannelProvider.of<MyChannel>(context).afterInitState();
    });
  }

  @override
  void dispose() {
// The channel's dispose method is not called. Because the Channel(MyChannel) was started with an AncestorChannelProvider.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Signal State Management :Example for AncestorChannelBuilder',
            style: TextStyle(fontSize: 12)),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Center(
            child: AncestorChannelBuilder<MyChannel, MyChannelSignal>(
              condition: (channel, signal) => signal is CounterStateSignal,
              builder: (context, channel, _) {
                final state = channel.counterState;

                return state.busy
                    ? CircularProgressIndicator()
                    : !state.success
                        ? Text(state.error)
                        : Text(state.count.toString(),
                            style: TextStyle(fontSize: 25));
              },
            ),
          ),
          SizedBox(
            height: 50,
          ),
          AncestorChannelBuilder<MyChannel, MyChannelSignal>(
              condition: (channel, signal) => signal is NotificationStateSignal,
              builder: (context, channel, _) {
                final state = channel.notificationState;

                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(state.isOpen
                          ? 'Notification: on'
                          : 'Notification: off'),
                      onPressed: state.busy ? null : () => state.change(),
                    ),
                    if (state.busy) CircularProgressIndicator(),
                  ],
                );
              }),
          SizedBox(
            height: 50,
          ),
          RaisedButton(
            child: Text('CounterState: increment'),
            onPressed: () => AncestorChannelProvider.of<MyChannel>(context)
                .counterState
                .increment(),
          ),
          RaisedButton(
            child: Text('CounterState: decrementFuture'),
            onPressed: () => AncestorChannelProvider.of<MyChannel>(context)
                .counterState
                .decrementFuture(),
          ),
          RaisedButton(
            child: Text('NotificationState: change'),
            onPressed: () => AncestorChannelProvider.of<MyChannel>(context)
                .notificationState
                .change(),
          ),
          RaisedButton(
            child: Text('NotificationState: changeFuture'),
            onPressed: () => AncestorChannelProvider.of<MyChannel>(context)
                .notificationState
                .changeFuture(),
          ),
          RaisedButton(
            child: Text('go to the OtherPage'),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => OtherPage())),
          ),
        ],
      ),
    );
  }
}

class OtherPage extends StatefulWidget {
  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  MyChannel _myChannel;
  MyChannel get myChannel => _myChannel;

  @override
  void initState() {
    super.initState();
    _myChannel = MyChannel()..initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _myChannel.afterInitState();
    });
  }

  @override
  void dispose() {
//The channel's dispose method is called. Because the Channel(_myChannel) was not initialize with an AncestorChannelProvider.
    _myChannel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Signal State Management :Example for AvailableChannelBuilder',
              style: TextStyle(fontSize: 12))),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Center(
            child: AvailableChannelBuilder<MyChannel, MyChannelSignal>(
              channel: myChannel,
              condition: (channel, signal) => signal is CounterStateSignal,
              builder: (context, channel, _) {
                final state = channel.counterState;

                return state.busy
                    ? CircularProgressIndicator()
                    : !state.success
                        ? Text(state.error)
                        : Text(state.count.toString(),
                            style: TextStyle(fontSize: 25));
              },
            ),
          ),
          SizedBox(
            height: 50,
          ),
          AvailableChannelBuilder<MyChannel, MyChannelSignal>(
              channel: _myChannel,
              condition: (channel, signal) => signal is NotificationStateSignal,
              builder: (context, channel, _) {
                final state = channel.notificationState;

                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(state.isOpen
                          ? 'Notification: on'
                          : 'Notification: off'),
                      onPressed: state.busy ? null : () => state.change(),
                    ),
                    if (state.busy) CircularProgressIndicator(),
                  ],
                );
              }),
          SizedBox(
            height: 50,
          ),
          RaisedButton(
            child: Text('CounterState: increment'),
            onPressed: () => _myChannel.counterState.increment(),
          ),
          RaisedButton(
            child: Text('CounterState: decrementFuture'),
            onPressed: () => _myChannel.counterState.decrementFuture(),
          ),
          RaisedButton(
            child: Text('NotificationState: change'),
            onPressed: () => _myChannel.notificationState.change(),
          ),
          RaisedButton(
            child: Text('NotificationState: changeFuture'),
            onPressed: () => _myChannel.notificationState.changeFuture(),
          ),
        ],
      ),
    );
  }
}

abstract class MyChannelSignal extends ChannelSignal {}

class MyChannel extends StateChannel<MyChannelSignal> {
  MyChannel() {
    _counterState = CounterState(() => add(CounterStateSignal()));
    _notificationState =
        NotificationState(() => add(NotificationStateSignal()));
  }

//signal: CounterStateSignal
  CounterState _counterState;
  CounterState get counterState => _counterState;

//signal: NotificationStateSignal
  NotificationState _notificationState;
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
  void dispose() {
    _counterState.dispose();
    _notificationState.dispose();
    super.dispose();
  }
}

class CounterStateSignal extends MyChannelSignal {}

class CounterState extends BaseState {
  CounterState(void Function() onStateChanged) : super(onStateChanged);

  int _count;
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
    doneSucces();
  }

  void decrement() {
    _count = _count - 1;
    doneSucces();
  }

  Future<void> incrementFuture() async {
    try {
      wait();
      await Future<void>.delayed(Duration(seconds: 3));
      _count = _count + 1;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }

  Future<void> decrementFuture() async {
    try {
      wait();
      await Future<void>.delayed(Duration(seconds: 1));
      _count = _count - 1;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }
}

class NotificationStateSignal extends MyChannelSignal {}

class NotificationState extends BaseState {
  NotificationState(void Function() onStateChanged) : super(onStateChanged);

  bool _isOpen;
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
    doneSucces();
  }

  Future<void> changeFuture() async {
    try {
      wait();
      await Future<void>.delayed(Duration(seconds: 1));
      _isOpen = !_isOpen;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }
}
