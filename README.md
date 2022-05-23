<p align="center">
<img src="https://flutterdersleri.com/wp-content/uploads/2020/08/signal_logo.png" height="150" alt="Signal" />
</p>

# "signal" - Multiple state management in one channel

Stream-based multiple state management. Multiple state management in one channel. Similar to the bloc structure, but current states are always accessible.

## Usage

### Create channel and its signal.

``` 

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
  void dispose() {
    _counterState.dispose();
    _notificationState.dispose();
    super.dispose();
  }
}

```

### Create states and its signals

``` 

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

```

### ChannelProvider

Creates a channel, store it, and expose it to its descendants.
A ChannelProvider manages the lifecycle of the channel.

``` 
void main() => runApp(MyApp());

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


```

### ChannelBuilder

ChannelBuilder handles building a widget in response to new ChannelSignal broadcasting from ChannelProvider on an.

``` 
 
ChannelBuilder<MyChannel, MyChannelSignal>(
    condition: (channel, signal) => signal is CounterStateSignal,
    builder: (context, channel, _) => 
      channel.counterState.busy ? CircularProgressIndicator():
      !channel.counterState.success ? Text(channel.notificationState.error) :
      Text(channel.counterState.count.toString()),
  ),

```
  
that's all.

<p align="center">
<img src="https://flutterdersleri.com/wp-content/uploads/2021/04/signal2_5.gif"  alt="Signal Example" />
</p>
