<p align="center">
<img src="https://flutterdersleri.com/wp-content/uploads/2020/08/signal_logo.png" height="150" alt="Signal" />
</p>

# signal

Stream-based multiple state management. Multiple state management in one channel. Similar to the bloc structure, but current states are always accessible.

## Usage

### Create channel and its signal.

``` 
abstract class MyChannelSignal extends ChannelSignal{}

class MyChannel extends StateChannel<MyChannelSignal>{
 
}

```

### Create states and its signals

``` 
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
  afterInitState() {
   incrementFuture();
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

  incrementFuture() async {
    try {
      wait();

      await Future<void>.delayed(Duration(milliseconds: 500));
      _count = _count + 1;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }

  decrementFuture() async {
    try {
      wait();

      await Future<void>.delayed(Duration(milliseconds: 500));
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
  afterInitState() => changeFuture();

  @override
  dispose() {}

  change() {
    _isOpen = !_isOpen;
    doneSucces();
  }

  Future<void> changeFuture() async {
    try {
      wait();

      await Future<void>.delayed(Duration(milliseconds: 500));
      _isOpen = !_isOpen;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }
}

```

### Add states to the channel.

``` 
abstract class MyChannelSignal extends ChannelSignal {}

class MyChannel extends StateChannel<MyChannelSignal> {
  MyChannel() {
    _counterState = CounterState(() => add(CounterStateSignal()));
    _notificationState = NotificationState(() => add(NotificationStateSignal()));
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

```

### AncestorChannelProvider

Creates a channel, store it, and expose it to its descendants.
A AncestorChannelProvider manages the lifecycle of the channel.

``` 
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return AncestorChannelProvider<MyChannel>(
      channel: MyChannel()..initState(),
      child: MaterialApp(
        title: 'Signal State Management',
        home: MyHomePage(),
      ),

    );
  }
}

```

### AncestorChannelBuilder

AncestorChannelBuilder handles building a widget in response to new ChannelSignal broadcasting from AncestorChannelProvider on an ancestor.

``` 
@override
void initState() {
  super.initState();
 WidgetsBinding.instance.addPostFrameCallback((_) {   AncestorChannelProvider.of<MyChannel>(context).afterInitState();  });
}

AncestorChannelBuilder<MyChannel, MyChannelSignal>(
    condition: (channel, signal) => signal is CounterStateSignal,
    builder: (context, channel, _) => 
      channel.counterState.busy ? CircularProgressIndicator():
      !channel.counterState.success ? Text(channel.notificationState.error) :
      Text(channel.counterState.count.toString()),
  ),

```

### AvailableChannelBuilder

AvailableChannelBuilder handles building a widget in response to new ChannelSignal broadcasting from existing in an Widget scope.

``` 
class _MyHomePageState extends State<MyHomePage> {

  MyChannel availableMychannel;

@override
void initState() {
  super.initState();
  availableMychannel = MyChannel()..initState();
   WidgetsBinding.instance.addPostFrameCallback((_) {  availableMychannel.afterInitState();  });
}

@override
void dispose() {
 availableMychannel.dispose();
  super.dispose();
}
 
  @override
  Widget build(BuildContext context) {

 ...

     AvailableChannelBuilder<MyChannel,MyChannelSignal>(
        channel: availableMychannel,
        condition: (channel,signal) =>signal is CounterStateSignal,
        builder: (context, channel, _ ) =>
          channel.counterState.busy ? CircularProgressIndicator():
          !channel.counterState.success ? Text(channel.counterStateSignal.error) :
          Text(  channel.counterState.count.toString(),),
    ),
  
 ...
  }
}

```

### OwnChannelBuilder

OwnChannelBuilder creates a new Channel objec and handles building a widget in response to new StateSignal.
OwnChannelBuilder does not expose it to its descendants.

``` 
class OtherWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
   final mychannel = AncestorChannelProvider.of<MyChannel>(context);
 ...

   OwnChannelBuilder<MyChannel,MyChannelSignal>(
      channel: MyChannel()..initState(),
      condition: (channel,signal) =>signal is CounterStateSignal,
      builder: (context, channel, _) =>
       channel.counterState.busy ? CircularProgressIndicator():
      !channel.counterState.success ? Text(channel.counterStateSignal.error) :
      Text(  channel.counterState.count.toString(),),
  ),
  
 ...
  }
}

```

 
that's all.

<p align="center">
<img src="https://flutterdersleri.com/wp-content/uploads/2020/08/signal_example.gif"  alt="Signal Example" />
</p>
