import 'dart:async';
import 'package:flutter/material.dart';
import 'channelprovider.dart';
import 'statechannel.dart';
import 'channelsignal.dart';

/// [ChannelBuilder<C>] handles building a widget in response to new [ChannelSignal] broadcasting from [ChannelProvider<C>] on an .
/// simple usage:
///
///
/// ```dart
/// ChannelBuilder<MyChannel,MyChannelSignal>(
///   condition: (channel,signal) =>signal is CounterStateSignal,
///   builder:(BuildContext context, channel, child) =>
///    channel.counterState.busy ? CircularProgressIndicator() : !channel.counterState.success ? Text( channel.counterState.error) :
///    Row( children: <Widget> [ Te xt( channel.counterState.count.toString()), child ] ),
///    child: OtherChildWidget(),
///    ),
///
/// or
///
/// /// ChannelBuilder<MyChannel,MyChannelSignal>(
///   condition: (channel,signal) =>signal is CounterStateSignal,
///   builder:(BuildContext context, channel, _ ) =>
///    channel.counterState.busy ? CircularProgressIndicator() : !channel.counterState.success ? Text( channel.counterState.error) :
///    Text( channel.counterState.count.toString(), ),
///  )
/// ```

class ChannelBuilder<C extends StateChannel<S>, S extends ChannelSignal> extends StatefulWidget {
  const ChannelBuilder({Key? key, this.condition, required this.builder, this.child}) : super(key: key);

  /// When the channel broadcasts a [ChannelSignal], the [condition] function is called.
  /// The [condition] must be returned a [bool] which determines whether or not the [builder] function will be invoked.
  /// [condition] is optional and if it isn't implemented, it will default to `true`.
  final bool Function(C channel, S signal)? condition;
  final Widget Function(BuildContext context, C channel, Widget? child) builder;
  final Widget Function()? child;

  @override
  State<ChannelBuilder<C, S>> createState() => _ChannelBuilderState<C, S>();
}

class _ChannelBuilderState<C extends StateChannel<S>, S extends ChannelSignal> extends State<ChannelBuilder<C, S>> {
  late final StreamSubscription<S> _subscription;
  Widget? child;

  @override
  void initState() {
    super.initState();
    child = widget.child?.call();
    final channel = ChannelProvider.of<C>(context);
    _subscription = channel.stream.listen((signal) {
      if (widget.condition?.call(channel, signal) ?? true) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, ChannelProvider.of<C>(context), child);
}
