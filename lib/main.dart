import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Breath',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin{

  String state = 'await';

  int _breathDuration = 3;

  int _countDown = 3;

  int _index = 0;

  int _cycles = 25;

  int _counter = 0;

  Timer _timer;

  Animation<double> _animation;

  AnimationController controller;

  double val = 0.0;


  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration:Duration(seconds: _breathDuration), vsync: this);
    _animation = Tween(begin:0.0, end:1.0).animate(controller)
      ..addListener((){
        setState(() {
          val = _animation.value;
        });
      });
  }

  void _startHandler() {
    Vibration.vibrate(duration:100);
    setState(() {
      state = 'starting';
      _timer = new Timer(Duration(seconds:1), countDownHandler);
    });
  }

  void countDownHandler(){
    setState((){
      _countDown--;
      if(_countDown == 0){
        controller.forward(from:0.0);
        state = 'running';
        _index = 0;
        _counter = 0;
        _timer.cancel();
        _timer = new Timer(Duration(seconds:_breathDuration), cycleHandler);
      }else{
        _timer = new Timer(Duration(seconds:1), countDownHandler);
      }
    });
  }

  void cycleHandler(){
    setState((){
      _index++;
      switch(_index){
        case 2:
          controller.reverse(from:1.0);
          break;
        case 4:
          controller.forward(from:0.0);
          break;
      }
      _timer = new Timer(Duration(seconds:_breathDuration), cycleHandler);
      if(_index==4){
        _index = 0;
        _counter++;

        if(_counter == _cycles){
          state = 'await';
          _timer.cancel();
        }
      }
      Vibration.vibrate(duration:200);
    });
  }

  @override
  Widget build(BuildContext context) {

    var button;
    var message;

    var children = <Widget>[
    ];

    switch(state){
      case 'await':
        message = 'Commencer ?';
        button = FloatingActionButton(
          onPressed: _startHandler,
          tooltip: 'Commencer',
          child: Icon(Icons.arrow_forward),
        );
        children.add(Text(
          message,
          style: Theme.of(context).textTheme.display1,
        ));
        var p = new Padding(padding: EdgeInsets.only(top:10.0), child:button);
        children.add(p);
        break;
      case 'starting':
        children.add(Text(
          '$_countDown...',
            style: Theme.of(context).textTheme.display1,
        ));
        break;
      case 'running':
        children.add(Text(
          'Inspirer',
          style: _index==0?TextStyle(color:Color(0xff000000), fontSize: 40.0):Theme.of(context).textTheme.display1,
        ));
        children.add(Text(
          'Bloquer',
          style: _index==1?TextStyle(color:Color(0xff000000), fontSize: 40.0):Theme.of(context).textTheme.display1,
        ));
        children.add(Text(
          'Expirer',
          style: _index==2?TextStyle(color:Color(0xff000000), fontSize: 40.0):Theme.of(context).textTheme.display1,
        ));
        children.add(Text(
          'Bloquer',
          style: _index==3?TextStyle(color:Color(0xff000000), fontSize: 40.0):Theme.of(context).textTheme.display1,
        ));
        break;
    }

    return Scaffold(
      body: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter:BreathPainter(val),
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      )
    );
  }
}

class BreathPainter extends CustomPainter
{
  double value;

  BreathPainter(this.value);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = new Paint()
        ..color = Color(0xFFe7fcff)
        ..style = PaintingStyle.fill
        ..strokeWidth = 3.0
        ..isAntiAlias = true;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), ((size.width/2)-10) * this.value, paint);
  }
}
