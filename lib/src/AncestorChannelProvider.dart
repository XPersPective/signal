import 'package:flutter/material.dart';
import 'StateChannel.dart';

  /// Creates a channel, store it, and expose it to its descendants.
  /// A [AncestorChannelProvider] manages the lifecycle of the channel.
  /// 
  /// Exposing a channel 
  ///
  /// Correct usage:
  ///  create a [StateChannel] object and expose it to its descendants.
  ///  
  /// ```dart
  /// AncestorChannelProvider<MyChannel>(
  ///   channel: MyChannel(),
  ///    child:..
  ///   },
  /// )
  /// ```
class  AncestorChannelProvider<C extends StateChannel> extends StatefulWidget {
  
  const AncestorChannelProvider({
    Key key,
    @required this.channel,
    @required this.child,
  })  : assert(channel != null),
        assert(child != null),
        super(key: key);

///Channel that allows broadcasting about the status of state
  final C channel;

/// Child widget of this [AncestorChannelProvider<C>] widget
  final Widget child;

  @override
  _AncestorChannelProviderState<C> createState() => _AncestorChannelProviderState<C>();

//  Obtains the nearest [AncestorChannelProvider<C>] up its widget tree and returns its channel of the given type [C].
  static C of<C extends StateChannel>(BuildContext context) {
    return context.findAncestorWidgetOfExactType<AncestorChannelProvider<C>>().channel;
  }
}

class _AncestorChannelProviderState<C extends StateChannel> extends State<AncestorChannelProvider<C>> {
  C channel;

  @override
  void initState() {
    super.initState();
    channel = widget.channel;
  }

  @override
  void didUpdateWidget(AncestorChannelProvider<C> oldWidget) {
    if (oldWidget.channel != channel) {
      channel = widget.channel;
    }
    super.didUpdateWidget(oldWidget);
  }


  @override
  void dispose() {
    widget.channel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}