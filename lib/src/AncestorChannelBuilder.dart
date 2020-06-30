import 'dart:async';
import 'package:flutter/material.dart';
import 'AncestorChannelProvider.dart';
import 'StateChannel.dart';
import 'ChannelSignal.dart';

/// [AncestorChannelBuilder<C>] handles building a widget in response to new [ChannelSignal] broadcasting from [AncestorChannelProvider<C>] on an ancestor.
/// simple usage:
///
///
/// ```dart
/// AncestorChannelBuilder<MyChannel,MyChannelSignal>(
///   condition: (channel,signal) =>signal is CounterStateSignal,
///   builder:(BuildContext context, channel) =>
///    channel.counterState.busy ? CircularProgressIndicator() : !channel.counterState.success ? Text( channel.counterState.error) :
///    Text( channel.counterState.count.toString(), ) ,
///  )
/// ```
class AncestorChannelBuilder<C extends StateChannel<S>, S extends ChannelSignal>
    extends StatefulWidget {
  const AncestorChannelBuilder({
    Key key,
    this.condition,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  /// When the channel broadcasts a [ChannelSignal], the [condition] function is called.
  /// The [condition] must be returned a [bool] which determines whether or not the [builder] function will be invoked.
  /// [condition] is optional and if it isn't implemented, it will default to `true`.
  final bool Function(C channel, S signal) condition;

  final Widget Function(BuildContext context, C channel) builder;

  @override
  _AncestorChannelBuilderState<C, S> createState() =>
      _AncestorChannelBuilderState<C, S>();
}

class _AncestorChannelBuilderState<C extends StateChannel<S>,
    S extends ChannelSignal> extends State<AncestorChannelBuilder<C, S>> {
  ///[channel] that allows broadcasting about the status of state
  C channel;
  StreamSubscription<S> _subscription;

  @override
  void initState() {
    super.initState();
    channel = AncestorChannelProvider.of<C>(context);
    _subscribe();
  }

  @override
  void didUpdateWidget(AncestorChannelBuilder<C, S> oldWidget) {
    if (oldWidget.condition != widget.condition) {
      _unsubscribe();
      channel = AncestorChannelProvider.of<C>(context);
      _subscribe();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _subscribe() {
    if (channel != null) {
      _subscription = channel.stream.listen((signal) {
        if (widget.condition?.call(channel, signal) ?? true) {
          if (mounted) {
            setState(() {});
          }
        }
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, channel);
  }
}
