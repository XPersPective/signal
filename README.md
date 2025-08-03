# 📡 Signal - Modern State Management for Flutter

Signal is a modern library for reactive and automatic state management in Flutter applications. With its simple API, you can easily manage complex states.

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  signal: ^3.0.1
```

Then run:

```bash
flutter pub get
```

Import the package in your Dart files:

```dart
import 'package:signal/signal.dart';
```

## 🚀 Quick Start

### 1. Create a Signal Class

```dart
class AuthSignal extends Signal {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
}

class UserSignal extends Signal {
  String? _userName;
  String? get userName => _userName;
}
```

### 2. Providing Signal with SignalProvider

SignalProvider provides a Signal instance to the widget tree and manages its lifecycle.

```dart
SignalProvider<AuthSignal>(
  signal: (context) => AuthSignal(),
  child: SignalProvider<UserSignal>(
    signal: (context) => UserSignal(),
    child: MyApp(),
  ),
)
```

Or with multiple providers:

```dart
MultiSignalProvider(
  signals: [
    signalItem<AuthSignal>(() => AuthSignal()),
    signalItem<UserSignal>(() => UserSignal()),
  ],
  child: MyApp(),
)
```

### 3. Listening with SignalBuilder

SignalBuilder automatically rebuilds the UI when the related Signal changes.

```dart
SignalBuilder<AuthSignal>(
  builder: (context, signal, child) {
    return Column(
      children: [
        if (signal.busy) CircularProgressIndicator(),
        if (signal.error != null) Text('Error: ${signal.error}'),
        Text('Status: ${signal.isLoggedIn ? 'Logged In' : 'Logged Out'}'),
      ],
    );
  },
)

SignalBuilder<UserSignal>(
  builder: (context, signal, child) {
    return Column(
      children: [
        if (signal.busy) CircularProgressIndicator(),
        if (signal.error != null) Text('Error: ${signal.error}'),
        Text('User: ${signal.userName ?? 'None'}'),
      ],
    );
  },
)
```

## 🧩 Listening to Parent Providers from a Child Provider

```dart
MultiSignalProvider(
  signals: [
    signalItem<AuthSignal>(() => AuthSignal()),
    signalItem<UserSignal>(() => UserSignal()),
    signalItem<CounterSignal>(() => CounterSignal()),
  ],
  child: MaterialApp(
    home: HomePage(),
  ),
)
```

For example, to listen to AuthSignal inside UserSignal:

```dart
class UserSignal extends Signal {
  String? _userName;
  String? get userName => _userName;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    // Listening must be done inside initState!
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
}
```

**Note:** The `subscribeToParent` function must be called inside `initState`. This way, when the parent signal changes, the child signal is automatically updated.

---

## SignalProvider Overview

- A SignalProvider provides a specific signal to the widget tree.
- The provider's child can access and listen to this signal.
- Multiple providers can be chained together.

## SignalBuilder Overview

- SignalBuilder automatically rebuilds the UI when the related signal changes.
- The builder function receives the signal and child parameters.
- For performance, you can use the child parameter.

---

## Summary Flow

1. Provide the signal with SignalProvider
2. Listen and update the UI with SignalBuilder
3. For a child signal to listen to a parent signal, use subscribeToParent inside initState

---

## Best Practices

1. Each signal should manage a single piece of state
2. Use setState for async operations
3. Call subscribeToParent inside initState for listening
4. Build the widget chain with MultiSignalProvider
5. Use SignalBuilder for automatic UI updates

---

## 🐛 Debug Tools

To enable debug mode during development:

```dart
void main() {
  SignalDebugConfig.enableLogging = true;
  runApp(MyApp());
}
```