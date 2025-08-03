import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

void main() {
  runApp(const MyApp());
}

class CounterSignal extends Signal {
  int _count = 0;
  int get count => _count;

  void increment() {
    setState(apply: () async {
      _count++;
    });
  }

  void decrement() {
    setState(apply: () async {
      _count--;
    });
  }

  Future<void> loadData() async {
    setState(apply: () async {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      _count = 100;
    });
  }
}

class AuthSignal extends Signal {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login() async {
    setState(apply: () async {
      await Future.delayed(const Duration(seconds: 1));
      _isLoggedIn = true;
    });
  }

  Future<void> logout() async {
    setState(apply: () async {
      await Future.delayed(const Duration(seconds: 1));
      _isLoggedIn = false;
    });
  }
}

class UserSignal extends Signal {
  String? _userName;
  String? get userName => _userName;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    // Subscribe to AuthSignal changes
    subscribeToParent<AuthSignal>(context, (authSignal) {
      if (authSignal.busy) {
        setBusy();
        return;
      }

      if (authSignal.isLoggedIn) {
        _userName = "John Doe";
      } else {
        _userName = null;
      }
      setSuccess();
    });
  }

  void setUserName(String name) {
    setState(apply: () async {
      _userName = name;
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSignalProvider(
      signals: [
        signalItem<AuthSignal>(() => AuthSignal()),
        signalItem<UserSignal>(() => UserSignal()),
        signalItem<CounterSignal>(() => CounterSignal()),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

// Main homepage with interactive signal demo
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signal Example")),
      body: Column(
        children: [
          // Debug panel at top (development only)
          if (kDebugMode) SignalDebugPanel(signals: SignalDebugRegistry.allSignals),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SignalBuilder<AuthSignal>(
                      builder: (context, authSignal, _) {
                        return Column(
                          children: [
                            if (authSignal.busy)
                              const CircularProgressIndicator()
                            else
                              Text(
                                'Status: ${authSignal.isLoggedIn ? "Logged In" : "Logged Out"}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: authSignal.busy
                                  ? null
                                  : () {
                                      if (authSignal.isLoggedIn) {
                                        authSignal.logout();
                                      } else {
                                        authSignal.login();
                                      }
                                    },
                              child: Text(authSignal.isLoggedIn ? "Logout" : "Login"),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    SignalBuilder<UserSignal>(
                      builder: (context, userSignal, _) {
                        return Column(
                          children: [
                            if (userSignal.busy) const CircularProgressIndicator(),
                            Text(
                              "User: ${userSignal.userName ?? 'No user'}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => userSignal.setUserName("John Doe"),
                              child: const Text("Set User Name"),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    SignalBuilder<CounterSignal>(
                      builder: (context, counterSignal, _) {
                        return Column(
                          children: [
                            if (counterSignal.busy)
                              const CircularProgressIndicator()
                            else
                              Text(
                                'Count: ${counterSignal.count}',
                                style: const TextStyle(fontSize: 24),
                              ),
                            if (counterSignal.error != null)
                              Text(
                                'Error: ${counterSignal.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: counterSignal.decrement,
                                  child: const Text('-'),
                                ),
                                ElevatedButton(
                                  onPressed: counterSignal.increment,
                                  child: const Text('+'),
                                ),
                                ElevatedButton(
                                  onPressed: counterSignal.loadData,
                                  child: const Text('Load 100'),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
