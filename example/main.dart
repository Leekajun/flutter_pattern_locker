import 'package:flutter/material.dart';
import 'package:flutter_pattern_locker/flutter_pattern_locker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '九宫格解锁',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '九宫格解锁'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String tip = '请设置密码';
  String subTip = '';
  LockConfig config = LockConfig();
  String? pwd;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(tip, style: TextStyle(fontSize: 16)),
            Text(subTip),
            PatternLocker(
              config: config,
              style: LockStyle(
                  defaultColor: Colors.grey, selectedColor: Colors.blue),
              onStart: () {
                setState(() {
                  subTip = '';
                  config.isError = false;
                  config.isKeepTrackOnComplete = false;
                  if (tip == "再设置一次密码") {
                    config.isKeepTrackOnComplete = true;
                  }
                });
              },
              onComplete: (pwd, length) {
                if (this.pwd == null) {
                  if (length < 4) {
                    setState(() {
                      subTip = '密码至少连接4个点';
                      config.isError = true;
                      config.isKeepTrackOnComplete = true;
                    });
                  } else {
                    this.pwd = pwd;
                    setState(() {
                      tip = "再设置一次密码";
                    });
                  }
                } else {
                  if (this.pwd != pwd) {
                    setState(() {
                      config.isError = true;
                      subTip = '两次滑动的轨迹不一致';
                    });
                  } else {
                    setState(() {
                      subTip = '设置成功';
                      config.isKeepTrackOnComplete = false;
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
