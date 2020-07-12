import 'package:flutter/material.dart';
import 'package:signal/signal.dart';
import 'MyChannel.dart';

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyChannel availableMychannel;

  @override
  void initState() {
    super.initState();
    availableMychannel = MyChannel()..initState();
  }

  @override
  void dispose() {
    availableMychannel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mychannel = AncestorChannelProvider.of<MyChannel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Signal State Management"),
      ),
      body: ListView(shrinkWrap: true, children: <Widget>[
        AncestorChannelBuilder<MyChannel, MyChannelSignal>(
          condition: (channel, signal) =>
              signal is NotificationStateSignal || signal is ColorStateSignal,
          builder: (context, channel) => SwitchListTile(
            subtitle: Text('Subtitle Text color from ColorState',
                style:
                    TextStyle(color: channel.colorState.color.withAlpha(255))),
            secondary: Icon(channel.notificationState.isOpen
                ? Icons.notifications_active
                : Icons.notifications_off),
            title: channel.notificationState.busy
                ? LinearProgressIndicator()
                : !channel.notificationState.success
                    ? Text(channel.notificationState.error)
                    : Text(channel.notificationState.isOpen
                        ? 'Notification Open'
                        : 'Notification Closed'),
            value: channel.notificationState.isOpen,
            onChanged: (bool value) => channel.notificationState.change(),
          ),
        ),
        Container(
          alignment: Alignment.center,
          height: 50,
          child: AncestorChannelBuilder<MyChannel, MyChannelSignal>(
            condition: (channel, signal) => signal is CounterStateSignal,
            builder: (context, channel) => channel.counterState.busy
                ? Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))
                : !channel.counterState.success
                    ? Text(channel.notificationState.error)
                    : Text(channel.counterState.count.toString(),
                        style: TextStyle(fontSize: 25)),
          ),
        ),
        AncestorChannelBuilder<MyChannel, MyChannelSignal>(
          condition: (channel, signal) => signal is ColorStateSignal,
          builder: (context, channel) => Container(
            height: 20,
            alignment: Alignment.center,
            child: channel.colorState.busy
                ? LinearProgressIndicator()
                : !channel.colorState.success
                    ? Text(channel.notificationState.error)
                    : Text(channel.colorState.color.toString(),
                        style: TextStyle(fontSize: 20)),
          ),
        ),
        AvailableChannelBuilder<MyChannel, MyChannelSignal>(
          channel: availableMychannel,
          condition: (channel, signal) => signal is CounterStateSignal,
          builder: (context, channel) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: channel.counterState.busy
                    ? Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))
                    : !channel.counterState.success
                        ? Text(channel.notificationState.error)
                        : Text(channel.counterState.count.toString(),
                            style: TextStyle(fontSize: 25)),
              ),
              RaisedButton(
                  child: Text(
                      'AvailableChannelBuilder : CounterState : increment'),
                  onPressed: () => channel.counterState.increment()),
              RaisedButton(
                  child: Text(
                      'AvailableChannelBuilder : CounterState : decrementFuture'),
                  onPressed: () => channel.counterState.decrementFuture()),
            ],
          ),
        ),
        SizedBox(height: 10),
        OwnChannelBuilder<MyChannel, MyChannelSignal>(
          channel: MyChannel(),
          condition: (channel, signal) => signal is CounterStateSignal,
          builder: (context, channel) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                child: channel.counterState.busy
                    ? Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))
                    : !channel.counterState.success
                        ? Text(channel.counterState.error)
                        : Text(channel.counterState.count.toString(),
                            style: TextStyle(fontSize: 25)),
              ),
              RaisedButton(
                  child: Text('OwnChannelBuilder : CounterState : increment'),
                  onPressed: () => channel.counterState.increment()),
              RaisedButton(
                  child: Text(
                      'OwnChannelBuilder : CounterState : decrementFuture'),
                  onPressed: () => channel.counterState.decrementFuture()),
            ],
          ),
        ),
        RaisedButton(
            child: Text('NotificationState : change '),
            onPressed: () => mychannel.notificationState.change()),
        RaisedButton(
            child: Text('NotificationState : changeFuture '),
            onPressed: () => mychannel.notificationState.changeFuture()),
        RaisedButton(
            child: Text('CounterState : increment'),
            onPressed: () => mychannel.counterState.increment()),
        RaisedButton(
            child: Text('CounterState : decrementFuture'),
            onPressed: () => mychannel.counterState.decrementFuture()),
        RaisedButton(
            child: Text('ColorState : changeColor'),
            onPressed: () => mychannel.colorState.changeColor()),
        RaisedButton(
            child: Text('ColorState : changeColorFuture'),
            onPressed: () => mychannel.colorState.changeColorFuture()),
      ]),
    );
  }
}
