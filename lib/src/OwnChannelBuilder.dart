import 'dart:async';
import 'package:flutter/material.dart';
import 'ChannelSignal.dart';
import 'StateChannel.dart';

/// [OwnChannelBuilder<C,S>] creates a new [StateChannel] objec and handles building a widget in response to new [StateSignal].
/// [OwnChannelBuilder<C,S>] does not expose it to its descendants .
/// correct usage:
///
/// ```dart
///
///     OwnChannelBuilder<MyChannel,MyChannelSignal>(
///       channel: MyChannel(),
///       condition: (channel,signal) =>signal is CounterStateSignal,
///       builder: (context, channel, child) => ....,
///       child:OtherChildWidget()
/// ),
///
/// ```
class OwnChannelBuilder<C extends StateChannel<S>, S extends ChannelSignal>
    extends StatefulWidget {
  const OwnChannelBuilder(
      {Key key,
      @required this.channel,
      this.condition,
      @required this.builder,
      this.child})
      : assert(builder != null),
        assert(channel != null),
        super(key: key);

  final C channel;
  final bool Function(C channel, S signal) condition;
  final Widget Function(BuildContext context, C channel, Widget child) builder;
  final Widget child;
  @override
  _OwnChannelBuilderState<C, S> createState() =>
      _OwnChannelBuilderState<C, S>();
}

class _OwnChannelBuilderState<C extends StateChannel<S>,
    S extends ChannelSignal> extends State<OwnChannelBuilder<C, S>> {
  ///[channel] that allows broadcasting about the status of state
  C channel;
  StreamSubscription<S> _subscription;
  Widget child;

  @override
  void initState() {
    super.initState();
    channel = widget.channel;
    child = widget.child;
    _subscribe();
  }

  @override
  void didUpdateWidget(OwnChannelBuilder<C, S> oldWidget) {
    final tempchannel = widget.channel;
    if (oldWidget.channel != tempchannel) {
      _unsubscribe();
      channel.dispose();
      channel = widget.channel;
      child = widget.child;
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
    widget.channel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, channel, child);
  }
}
