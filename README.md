# signal

Stream-based multiple state management.

### Usage

###### Create your own channel and its signal.

```
abstract class MyChannelSignal extends ChannelSignal{}

class MyChannel extends StateChannel<MyChannelSignal>{
 
}
```

###### Create your own states and its signals

```
class CounterStateSignal extends MyChannelSignal{}

class CounterState extends BaseState{
  CounterState(void Function() onStateChanged) : super(onStateChanged);
 
 int _count =0;
 int get count => _count;

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

      await Future<void>.delayed(Duration(milliseconds: 400));
      _count = _count + 1;

     doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }

    decrementFuture() async {
    try {
     wait();

      await Future<void>.delayed(Duration(milliseconds: 400));
      _count = _count - 1;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }
}
 



class NotificationStateSignal extends MyChannelSignal{}

class NotificationState extends BaseState{
  NotificationState(void Function() onStateChanged) : super(onStateChanged);

....

}



class ColorStateSignal extends MyChannelSignal{}

class ColorState extends BaseState{
  ColorState(void Function() onStateChanged) : super(onStateChanged);
 
....

}

```

###### Add to your own the channel

```

abstract class MyChannelSignal extends ChannelSignal{}

class MyChannel extends StateChannel<MyChannelSignal>{

  MyChannel() {
    _counterState = CounterState(() => add(CounterStateSignal()));
    _notificationState = NotificationState(() => add(NotificationStateSignal()));
    _colorState = ColorState(() => add(ColorStateSignal()));
  }

//signal: CounterStateSignal
  CounterState _counterState;
  CounterState get counterState => _counterState;

//signal: NotificationStateSignal
  NotificationState _notificationState;
  NotificationState get notificationState => _notificationState;

//signal: ColorStateSignal
  ColorState _colorState;
  ColorState get colorState => _colorState;

}

```

###### AncestorChannelProvider

Creates a channel, store it, and expose it to its descendants.
A AncestorChannelProvider manages the lifecycle of the channel.

```

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return AncestorChannelProvider<MyChannel>(
      channel: MyChannel(),
      child: MaterialApp(
        title: 'Signal State Management',
        home: MyHomePage(),
      ),

    );
  }
}

```

###### AncestorChannelBuilder

AncestorChannelBuilder handles building a widget in response to new ChannelSignal broadcasting from AncestorChannelProvider on an ancestor.

```
AncestorChannelBuilder<MyChannel, MyChannelSignal>(
    condition: (channel, signal) => signal is CounterStateSignal,
    builder: (context, channel) => 
      channel.counterState.busy ? CircularProgressIndicator():
      !channel.counterState.success ? Text(channel.notificationState.error) :
      Text(channel.counterState.count.toString()),
  ),

```

###### OwnChannelBuilder

OwnChannelBuilder creates a new Channel objec and handles building a widget in response to new StateSignal.
OwnChannelBuilder does not expose it to its descendants.

```


class OtherWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
   final mychannel = AncestorChannelProvider.of<MyChannel>(context);
 ...

   OwnChannelBuilder<MyChannel,MyChannelSignal>(
      channel: MyChannel(),
      condition: (channel,signal) =>signal is CounterStateSignal,
      builder: (context, channel) =>
       channel.counterState.busy ? CircularProgressIndicator():
      !channel.counterState.success ? Text(channel.counterStateSignal.error) :
      Text(  channel.counterState.count.toString(),),
  ),
  
 ...
  }
}

```

###### AvailableChannelBuilder

AvailableChannelBuilder handles building a widget in response to new ChannelSignal broadcasting from existing in an Widget scope.

```

class _MyHomePageState extends State<MyHomePage> {

  MyChannel availableMychannel;

@override
void initState() {
  super.initState();
  availableMychannel =MyChannel();
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
        builder: (context, channel) =>
          channel.counterState.busy ? CircularProgressIndicator():
          !channel.counterState.success ? Text(channel.counterStateSignal.error) :
          Text(  channel.counterState.count.toString(),),
    ),
  
 ...
  }
}

```
