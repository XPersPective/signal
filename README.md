# 📡 Signal - Reactive State Management for Flutter

Signal is a modern reactive state management library for Flutter applications. It provides a simple yet powerful way to manage application state with automatic UI updates using Streams internally but exposing a clean API.

## ✨ Key Features

- ✅ **Automatic state management** (busy, success, error states)
- ✅ **Parent-child signal relationships** with automatic updates
- ✅ **Proper disposal and memory management**
- ✅ **Flutter integration** with Provider pattern
- ✅ **Type-safe signal subscription**
- ✅ **Debug tools** for development
- ✅ **Stream-based reactivity** with clean API

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  signal: ^3.0.0
```

Then import:

```dart
import 'package:signal/signal.dart';
```

## 🚀 Quick Start

### 1. Create a Signal class

```dart
class CounterSignal extends Signal {
  int _count = 0;
  int get count => _count;

  void increment() {
    setState(() async {
      _count++;
    });
  }
}
```

### 2. Provide the Signal

```dart
SignalProvider<CounterSignal>(
  signal: (context) => CounterSignal(),
  child: MyApp(),
)
```

### 3. Listen to Signal updates

```dart
SignalBuilder<CounterSignal>(
  builder: (context, signal, child) {
    return Column(
      children: [
        Text('Count: ${signal.count}'),
        if (signal.busy) CircularProgressIndicator(),
        if (signal.error != null) Text('Error: ${signal.error}'),
        ElevatedButton(
          onPressed: signal.increment,
          child: Text('Increment'),
        ),
      ],
    );
  },
)
```

## 🔄 Complete Example

Here's a complete working example that demonstrates the core features of Signal:

```dart
import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

void main() {
  runApp(const MyApp());
}

// 1. Create your Signal class
class CounterSignal extends Signal {
  int _count = 0;
  int get count => _count;

  void increment() {
    setState(() async {
      _count++;
    });
  }

  void decrement() {
    setState(() async {
      _count--;
    });
  }

  Future<void> loadData() async {
    setState(() async {
      // Simulate network request
      await Future.delayed(Duration(seconds: 2));
      _count = 100;
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signal Example',
      home: SignalProvider<CounterSignal>(
        signal: (context) => CounterSignal(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Counter'),
      ),
      body: SignalBuilder<CounterSignal>(
        builder: (context, signal, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (signal.busy)
                  const CircularProgressIndicator()
                else
                  Text(
                    'Count: ${signal.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                if (signal.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${signal.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: signal.decrement,
                      child: const Text('-'),
                    ),
                    ElevatedButton(
                      onPressed: signal.increment,
                      child: const Text('+'),
                    ),
                    ElevatedButton(
                      onPressed: signal.loadData,
                      child: const Text('Load Data'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## 🏗️ Advanced Usage

### Multiple Signals with MultiSignalProvider

```dart
MultiSignalProvider(
  signals: [
    signalItem<UserSignal>((context) => UserSignal()),
    signalItem<CounterSignal>((context) => CounterSignal()),
    signalItem<ThemeSignal>((context) => ThemeSignal()),
  ],
  child: MyApp(),
)
```

### Parent-Child Signal Relationships

```dart
class ParentSignal extends Signal {
  String _data = 'Initial Data';
  String get data => _data;

  void updateData(String newData) {
    setState(() async {
      _data = newData;
    });
  }
}

class ChildSignal extends Signal {
  String get parentData {
    // Automatically subscribes to ParentSignal updates
    final parent = subscribeToParent<ParentSignal>();
    return parent.data;
  }

  void processParentData() {
    setState(() async {
      final processed = 'Processed: ${parentData}';
      // Handle processed data
    });
  }
}
```

## 🐛 Debug Tools

Enable debug mode during development:

```dart
void main() {
  SignalDebugConfig.enabled = true;
  SignalDebugConfig.logLevel = SignalLogLevel.all;
  runApp(MyApp());
}
```

## 📚 API Reference

### Signal Class

The base class for all signals. Extend this class to create your reactive state:

```dart
abstract class Signal {
  // State management
  bool get busy;           // Loading state
  dynamic get error;       // Error state
  bool get success;        // Success state

  // Methods to override
  void setState(Future<void> Function() callback);
  T subscribeToParent<T extends Signal>();
}
```

### SignalProvider<S>

Provides a signal to the widget tree:

```dart
SignalProvider<MySignal>(
  signal: (context) => MySignal(),
  child: Widget,
)
```

### SignalBuilder<S>

Builds UI that automatically updates when the signal changes:

```dart
SignalBuilder<MySignal>(
  builder: (context, signal, child) {
    return Widget();
  },
)
```

### MultiSignalProvider

Provides multiple signals efficiently:

```dart
MultiSignalProvider(
  signals: [
    signalItem<Signal1>((context) => Signal1()),
    signalItem<Signal2>((context) => Signal2()),
  ],
  child: Widget,
)
```

## 🎯 Best Practices

### 1. Keep Signals Focused
```dart
// ✅ Good - Single responsibility
class UserSignal extends Signal {
  User? _user;
  User? get user => _user;

  Future<void> loadUser(String id) async {
    setState(() async {
      _user = await userRepository.getUser(id);
    });
  }
}

// ❌ Avoid - Too many responsibilities
class AppSignal extends Signal {
  // Don't put everything in one signal
}
```

### 2. Use setState for All Updates
```dart
// ✅ Good - Always use setState
void updateData() {
  setState(() async {
    _data = newData;
  });
}

// ❌ Avoid - Direct updates won't notify listeners
void updateData() {
  _data = newData; // UI won't update
}
```

### 3. Handle Errors Properly
```dart
void loadData() {
  setState(() async {
    try {
      _data = await api.getData();
    } catch (e) {
      // Error automatically handled by setState
      rethrow;
    }
  });
}
```

## 🧪 Testing

Signal is designed to be easily testable:

```dart
void main() {
  group('CounterSignal', () {
    late CounterSignal signal;

    setUp(() {
      signal = CounterSignal();
    });

    test('should increment count', () {
      expect(signal.count, 0);
      signal.increment();
      expect(signal.count, 1);
    });

    test('should handle async operations', () async {
      expect(signal.busy, false);
      
      final future = signal.loadData();
      expect(signal.busy, true);
      
      await future;
      expect(signal.busy, false);
      expect(signal.count, 100);
    });
  });
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

  @override
  Future<void> dispose() async {
    await super.dispose();
  }

  // Instant state change
  change() {
    _isOpen = !_isOpen;
    doneSuccess();
  }

  // Async state change with loading
  Future<void> changeFuture() async {
    try {
      wait(); // Show loading
      await Future<void>.delayed(const Duration(seconds: 1));
      _isOpen = !_isOpen;
      doneSuccess(); // Hide loading, show success
    } catch (e) {
      doneError(e.toString()); // Show error
    }
  }
}

// 2. Provide the Signal
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignalProvider<NotificationSignal>(
        signal: (context) => NotificationSignal(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomePage(),
        ));
  }
}

// 3. Use SignalBuilder to reactively update UI
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Signal Example')),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 50),
          SignalBuilder<NotificationSignal>(builder: (context, signal, _) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                TextButton(
                  onPressed: signal.busy ? null : () => signal.change(),
                  child: Text(
                    signal.isOpen ? 'Notification: On' : 'Notification: Off',
                    style: TextStyle(
                      fontSize: 25, 
                      color: signal.isOpen ? Colors.green : Colors.red
                    )
                  ),
                ),
                if (signal.busy) const CircularProgressIndicator(),
              ],
            );
          }),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () => SignalProvider.of<NotificationSignal>(context).change(),
            child: const Text('Toggle Notification State'),
          )
        ],
      ),
    );
  }
}
```

### Key Concepts Demonstrated

1. **Signal Creation**: Extend the `Signal` class and override lifecycle methods
2. **State Management**: Use `wait()`, `doneSuccess()`, and `doneError()` for state control
3. **Provider Pattern**: Wrap your app with `SignalProvider` to make signals available
4. **Reactive UI**: Use `SignalBuilder` to automatically rebuild when signal state changes
5. **Loading States**: The `busy` property automatically handles loading indicators
6. **Error Handling**: Built-in error state management

## Advanced Usage

### Using setState for Automatic State Management

```dart
class ApiSignal extends Signal {
  List<User> _users = [];
  List<User> get users => _users;

  Future<void> fetchUsers() async {
    await setState(() async {
      final response = await api.getUsers();
      _users = response;
    });
  }

  Future<void> saveUser(User user) async {
    await setState(
      () => api.saveUser(user),
      onDoneError: (e) => 'Failed to save user: ${e.toString()}',
    );
  }
}
```

### Performance Optimization with Child Widget

```dart
SignalBuilder<NotificationSignal>(
  child: () => ExpensiveWidget(), // This won't rebuild
  builder: (context, signal, child) {
    return Column(
      children: [
        Text('Status: ${signal.isOpen ? "On" : "Off"}'),
        child!, // Reuse the expensive widget
      ],
    );
  },
)
```

## API Reference

### Signal Class

**Properties:**
- `busy` - Whether an async operation is in progress
- `success` - Whether the last operation was successful
- `error` - Error message (cleared after being read)

**Methods:**
- `setState(operation)` - Manages async operations with automatic state handling
- `wait()` - Manually set loading state
- `doneSuccess()` - Manually set success state
- `doneError(message)` - Manually set error state
- `initState()` - Called when signal is first initialized
- `afterInitState()` - Called after signal is added to widget tree
- `dispose()` - Clean up resources

### SignalProvider

A StatefulWidget that provides Signal instances throughout the widget tree and manages their lifecycle.

**Constructor Parameters:**
- `signal` - Factory function that creates the signal instance
- `child` - Widget subtree that will have access to the signal

**Static Methods:**
- `SignalProvider.of<T>(context)` - Retrieves the nearest signal of type T

### SignalBuilder

A widget that rebuilds when a Signal's state changes.

**Constructor Parameters:**
- `builder` - Function called when signal state changes
- `child` - Optional child widget factory for performance optimization

## Best Practices

1. **Keep Signals Focused**: Each signal should manage a specific piece of state
2. **Use setState for Async Operations**: Let the framework handle loading and error states automatically
3. **Leverage Type Safety**: Use generic types to ensure type safety throughout your app
4. **Optimize with Child Widgets**: Use the child parameter in SignalBuilder for expensive widgets that don't need rebuilding
5. **Handle Lifecycle**: Always override `initState()` and `afterInitState()` when needed
6. **Clean Up Resources**: The framework automatically calls `dispose()`, but you can override it for custom cleanup

## Why Choose Signal?

- **🚀 Simple**: Minimal boilerplate, maximum productivity
- **⚡ Fast**: Efficient updates with automatic optimization
- **🔒 Type-Safe**: Full Dart type system support
- **🔄 Reactive**: Automatic UI updates when state changes
- **🛠 Flexible**: Works with any async operation or state pattern

## Contributing

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Support

If you find this package helpful, please give it a ⭐ on GitHub!

For issues and feature requests, please visit the [GitHub repository](https://github.com/XPersPective/signal).
