# Signal - Reactive State Management for Flutter

Signal is a simple and efficient reactive state management library for Flutter applications. It provides an easy way to manage application state using signals and reactive patterns.

## Features

- **Reactive State Management**: Automatic UI updates through signals
- **Async Operation Support**: Built-in support for loading states, error handling, and success states
- **Easy Integration**: Seamless integration with Flutter widgets
- **Performance Focused**: Efficient updates with minimal overhead
- **Type-Safe**: Full utilization of Dart's strong type system

## Installation

Add to your pubspec.yaml:

```yaml
dependencies:
  signal: ^2.0.0
```

## Basic Usage

### Complete Example

Here's a complete working example that demonstrates the core features of Signal:

```dart
import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

void main() {
  runApp(const MyApp());
}

// 1. Create your Signal class
class NotificationSignal extends Signal {
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

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you find this package helpful, please give it a ⭐ on GitHub!

For issues and feature requests, please visit the [GitHub repository](https://github.com/XPersPective/signal).
