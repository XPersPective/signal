import 'package:flutter/material.dart';
import 'statechannel.dart';

class ChannelProvider<C extends StateChannel> extends StatefulWidget {
  const ChannelProvider({
    Key? key,
    required this.channel,
    required this.child,
  }) : super(key: key);

  final C Function(BuildContext context) channel;

  final Widget child;

  @override
  State<ChannelProvider<C>> createState() => _ChannelProviderState<C>();

//  Obtains the nearest [ChannelProvider<C>] up its widget tree and returns its channel of the given type [C].
  static C of<C extends StateChannel>(BuildContext context) {
    final C? result = context.findAncestorWidgetOfExactType<InheritedChannelProvider<C>>()?.channel;
    assert(result != null, 'No Channel found in context');
    return result!;
  }
}

class _ChannelProviderState<C extends StateChannel> extends State<ChannelProvider<C>> {
  late final C channel;

  @override
  void initState() {
    super.initState();
    channel = widget.channel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => channel.afterInitState());
  }

  @override
  Future<void> dispose() async {
    await channel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InheritedChannelProvider(channel: channel, child: widget.child);
}

class InheritedChannelProvider<C extends StateChannel> extends InheritedWidget {
  const InheritedChannelProvider({
    Key? key,
    required this.channel,
    required Widget child,
  }) : super(key: key, child: child);

  final C channel;

  @override
  bool updateShouldNotify(covariant InheritedChannelProvider<C> oldWidget) => false;
}
