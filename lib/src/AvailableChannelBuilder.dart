import 'dart:async';
import 'package:flutter/material.dart';
import 'ChannelSignal.dart';
import 'StateChannel.dart';

/// [AvailableChannelBuilder<C,S>]  handles building a widget in response to new [ChannelSignal]  broadcasting from existing in an Widget scope.
/// correct usage:
///
///
/// ```dart
///
/// ...
///
///  class _MyWidgetState extends State<MyWidget> {
///
///  MyChannel mychannel;
///
///  @override
///  void initState() {
///    super.initState();
///    mychannel =MyChannel();
///  }
///
///
///  @override
///  void dispose() {
///   mychannel.dispose();
///    super.dispose();
///  }
///
/// ...
///
///  @override
///  Widget build(BuildContext context) {
///   ...
///
///     AvailableChannelBuilder<MyChannel,MyChannelSignal>(
///       channel: mychannel,
///       condition: (channel, signal) =>signal is CounterStateSignal,
///       builder: (context, channel) => ....
/// ),
/// ...
///
/// ```

class AvailableChannelBuilder<C extends StateChannel<S>,
    S extends ChannelSignal> extends StatefulWidget {
  const AvailableChannelBuilder({
    Key key,
    @required this.channel,
    this.condition,
    @required this.builder,
  })  : assert(channel != null),
        assert(builder != null),
        super(key: key);

  ///[channel] that allows broadcasting about the status of state
  final C channel;
  final bool Function(C channel, S signal) condition;
  final Widget Function(BuildContext context, C channel) builder;

  @override
  _AvailableChannelBuilderState<C, S> createState() =>
      _AvailableChannelBuilderState<C, S>();
}

class _AvailableChannelBuilderState<C extends StateChannel<S>,
    S extends ChannelSignal> extends State<AvailableChannelBuilder<C, S>> {
  ///[channel] that allows broadcasting about the status of state
  C channel;
  StreamSubscription<S> _subscription;

  @override
  void initState() {
    super.initState();
    channel = widget.channel;
    _subscribe();
  }

  @override
  void didUpdateWidget(AvailableChannelBuilder<C, S> oldWidget) {
    final tempchannel = widget.channel;
    if (oldWidget.channel != tempchannel) {
      _unsubscribe();
      channel = widget.channel;
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
