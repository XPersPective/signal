import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

void main() {
  runApp(const MyApp());
}

class MySignal extends Signal {
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
  Future<void> dispose() async {
    await super.dispose();
  }

  change() {
    _isOpen = !_isOpen;
    doneSuccess();
  }

  Future<void> changeFuture() async {
    try {
      wait();
      await Future<void>.delayed(const Duration(seconds: 1));
      _isOpen = !_isOpen;

      doneSuccess();
    } catch (e) {
      doneError(e.toString());
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignalProvider<MySignal>(
        signal: (context) => MySignal(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Signal')),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 50),
          SignalBuilder<MySignal>(builder: (context, signal, _) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                TextButton(
                  onPressed: signal.busy ? null : () => signal.change(),
                  child: Text(
                      signal.isOpen ? 'Notification: On' : 'Notification: Off',
                      style: TextStyle(
                          fontSize: 25,
                          color: signal.isOpen ? Colors.green : Colors.red)),
                ),
                if (signal.busy) const CircularProgressIndicator(),
              ],
            );
          }),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => SignalProvider.of<MySignal>(context).change(),
            child: const Text('NotificationState: changed'),
          )
        ],
      ),
    );
  }
}
