 
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:signal/signal.dart';

abstract class MyChannelSignal extends ChannelSignal{}

class MyChannel extends StateChannel<MyChannelSignal>{

  MyChannel() {
    _counterState = CounterState(() => add(CounterStateSignal()));
    _notificationState = NotificationState(() => add(NotificationStateSignal()));
    _colorState = ColorState(() => add(ColorStateSignal()));
  }

//signal: CounterStateSignal
  CounterState _counterState;
  CounterState get counterState => _counterState;

//signal: NotificationStateSignal
  NotificationState _notificationState;
  NotificationState get notificationState => _notificationState;

//signal: ColorStateSignal
  ColorState _colorState;
  ColorState get colorState => _colorState;
  
@override
  initState() {
     super.initState();
     _counterState.initState();
  }

}


 


class CounterStateSignal extends MyChannelSignal{}

class CounterState extends BaseState{
  CounterState(void Function() onStateChanged) : super(onStateChanged);
  
 int _count;
 int get count => _count;

  @override
  initState() {
    _count=0;
    doneSucces(signal: false);
  }
 @override
  dispose() {
  }


  void increment() {
    _count = _count + 1;
    doneSucces();
  }

  void decrement() {
    _count = _count - 1;
     doneSucces();
  }

   incrementFuture() async {
    try {
       wait();

      await Future<void>.delayed(Duration(milliseconds: 800));
      _count = _count + 1;

     doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }

    decrementFuture() async {
    try {
     wait();

      await Future<void>.delayed(Duration(seconds: 2));
      _count = _count - 1;

      doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }

 
}



class NotificationStateSignal extends MyChannelSignal{}

class NotificationState extends BaseState{
  NotificationState(void Function() onStateChanged) : super(onStateChanged);
  
 bool _isOpen =false;
 bool get isOpen => _isOpen;

   change() {
    _isOpen = !_isOpen;
    doneSucces();
  }

   changeFuture() async {
    try {
       wait();

      await Future<void>.delayed(Duration(milliseconds: 500));
       _isOpen = !_isOpen;

     doneSucces();
    } catch (e) {
      doneError(e.toString());
    }
  }

  @override
  dispose() {
 
  }

  @override
  initState() {
 
  }

}



class ColorStateSignal extends MyChannelSignal{}

class ColorState extends BaseState{
  ColorState(void Function() onStateChanged) : super(onStateChanged);
  
 Color _color =Color(0xFFFFFFFF);
 Color get color => _color;
 
   void changeColor() {
   _change();
    doneSucces();
  }

   Future changeColorFuture() async {
    try {
       wait();

      await Future<void>.delayed(Duration(milliseconds: 2000)).then((value) 
      
      
      {
     _change();

     doneSucces();

      });

    } catch (e) {
      doneError(e.toString());
    }
  }


  void _change() {
      Random _random = Random();
      _color = Color.fromARGB(
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
  }

  @override
  dispose() {
 
  }

  @override
  initState() {
 
  }

}
