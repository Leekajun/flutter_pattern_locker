
# flutter_pattern_locker
九宫格解锁

example
```dart
class _MyHomePageState extends State<MyHomePage> {
  String tip = '请设置密码';
  String subTip = '';
  LockConfig config = LockConfig();
  String pwd;
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
```
### 可以显示错误轨迹

![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/gif1.gif)

### 在绘制完成之后不显示轨迹

![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/gif2.gif)

### 设置颜色和是否显示小箭头

![](https://raw.githubusercontent.com/lazyee/ImageHosting/master/img/gif3.gif)
