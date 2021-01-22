library flutter_pattern_locker;

import 'dart:math';
import 'package:flutter/material.dart';

class PatternLocker extends InheritedWidget {
  final LockStyle style; //样式
  final LockConfig config; //配置
  final Function() onStart; //开始绘制
  final Function(String pwd, int length) onComplete; //绘制结束

  PatternLocker({
    this.config,
    this.style,
    this.onStart,
    this.onComplete,
  }) : super(child: Container(child: _PatternLockerLayout()));

  @override
  bool updateShouldNotify(covariant PatternLocker oldWidget) {
    return true;
  }

  static PatternLocker of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PatternLocker>();
}

class _PatternLockerLayout extends StatefulWidget {
  _PatternLockerLayout({key}) : super(key: key);

  @override
  _PatternLockerLayoutState createState() => _PatternLockerLayoutState();
}

class _PatternLockerLayoutState extends State<_PatternLockerLayout> {
  LockItemPoint markLockItemPoint;
  Offset currentPoint;
  LockStyle style;
  Function() onStart;
  Function(String pwd, int lenght) onComplete;
  LockConfig config;

  List<LockItemPoint> lockItemCenterPoints = [];

  Widget buildColumn(int rowCount) {
    List<Widget> widegtList = [];
    for (int i = 0; i < config.columns; i++) {
      LockItemPoint point;
      if (lockItemCenterPoints.length < config.rows * config.columns) {
        point = LockItemPoint(
            (i + config.columns * rowCount + 1).toString(),
            Offset(
              config.lockItemSize.width / 2 + config.lockItemSize.width * i,
              config.lockItemSize.height / 2 +
                  config.lockItemSize.height * rowCount,
            ),
            config.lockItemSize);
        lockItemCenterPoints.add(point);
      } else {
        point = lockItemCenterPoints[i + config.columns * rowCount];
      }

      widegtList.add(_PartternLockItem(
        point: point,
      ));
    }

    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widegtList);
  }

  List<Widget> buildRow() {
    List<Widget> widegtList = [];
    for (int i = 0; i < config.rows; i++) {
      widegtList.add(buildColumn(i));
    }
    return widegtList;
  }

  void onTouch(Offset offset) {
    setState(() {
      currentPoint = offset;
    });
    for (var point in lockItemCenterPoints) {
      if (point.onTouch(offset)) {
        if (markLockItemPoint == null) {
          markLockItemPoint = point;
        } else {
          findLastLockItemPoint().next = point;
        }
        point.isMark = true;
        setState(() {
          point.isMark = true;
        });

        return;
      }
    }
  }

  LockItemPoint findLastLockItemPoint() {
    LockItemPoint point = markLockItemPoint;
    while (point.next != null) {
      point = point.next;
    }
    return point;
  }

  Map<String, dynamic> getPassword() {
    String pwd = "";
    int length = 0;
    if (markLockItemPoint != null) {
      var point = markLockItemPoint;
      pwd = "$pwd${point.tag}";
      length++;
      while (point.next != null) {
        point = point.next;
        pwd = "$pwd${point.tag}";
        length++;
      }
    }

    return {'pwd': pwd, 'length': length};
  }

  void resetAllPointAndLine() {
    markLockItemPoint = null;
    lockItemCenterPoints.forEach((point) {
      point.next = null;
      point.isMark = false;
    });
  }

  void _init(BuildContext context) {
    var data = PatternLocker.of(context);
    config = data.config;
    if (config == null) {
      config = LockConfig();
    }
    style = data.style;
    if (style == null) {
      style = LockStyle();
    }
    onStart = data.onStart;
    onComplete = data.onComplete;
  }

  @override
  Widget build(BuildContext context) {
    _init(context);
    return Container(
      alignment: Alignment.center,
      width: config.lockItemSize.width * config.columns,
      height: config.lockItemSize.height * config.rows,
      child: GestureDetector(
        onPanDown: (details) {
          resetAllPointAndLine();
          if (onStart != null) {
            onStart();
          }
          onTouch(details.localPosition);
        },
        onPanUpdate: (details) {
          onTouch(details.localPosition);
        },
        onPanEnd: (details) {
          if (onComplete != null) {
            var result = getPassword();
            onComplete(result['pwd'], result['length']);
          }

          if (!config.isKeepTrackOnComplete) {
            resetAllPointAndLine();
          }
          setState(() {
            currentPoint = null;
          });
        },
        child: CustomPaint(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildRow(),
          ),
          painter: _PartternLockLinePainter(
              point: markLockItemPoint,
              currentPoint: currentPoint,
              style: style,
              isError: config.isError),
        ),
      ),
    );
  }
}

class _PartternLockItem extends StatelessWidget {
  final LockItemPoint point;

  const _PartternLockItem({this.point, Key key}) : super(key: key);

  double _caculateAngle(LockItemPoint point) {
    // print(point);
    if (point.next == null) return 0;
    var angle = atan2(point.next.center.dx - point.center.dx,
        point.next.center.dy - point.center.dy);
    return pi - angle;
  }

  @override
  Widget build(BuildContext context) {
    var data = PatternLocker.of(context);
    var config = data.config == null ? LockConfig() : data.config;
    var style = data.style;
    var isError = config.isError;
    return Container(
      width: point.size.width,
      height: point.size.height,
      child: Transform.rotate(
          angle: _caculateAngle(point),
          child: CustomPaint(
            painter: _PartternLockPainter(
              point,
              style: style,
              isError: isError,
            ),
          )),
    );
  }
}

class _PartternLockLinePainter extends CustomPainter {
  Paint _paint;
  LockItemPoint point;
  Offset currentPoint;
  LockStyle style;
  bool isError;
  _PartternLockLinePainter(
      {this.point, this.currentPoint, this.style, this.isError = false}) {
    _paint = Paint();

    _paint.strokeWidth = this.style.lineWidth;
  }
  @override
  void paint(Canvas canvas, Size size) {
    if (point == null) return;
    _paint.color = isError ? this.style.errorColor : this.style.selectedColor;
    Path path = Path();
    _paint.style = PaintingStyle.stroke;

    path.moveTo(point.center.dx, point.center.dy);
    while (point.next != null) {
      point = point.next;
      path.lineTo(point.center.dx, point.center.dy);
    }

    if (currentPoint != null) {
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _PartternLockPainter extends CustomPainter {
  Paint _paint;
  LockItemPoint point;
  LockStyle style;
  bool isError;

  _PartternLockPainter(this.point, {this.isError = false, this.style}) {
    // this.point = point;
    _paint = Paint();
    if (this.style == null) {
      this.style = LockStyle();
    }
    _paint.color = this.style.defaultColor;
    _paint.strokeWidth = this.style.borderWidth;
  }
  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = this.point.isMark
        ? (this.isError ? this.style.errorColor : this.style.selectedColor)
        : this.style.defaultColor;

    var center = Offset(point.size.width / 2, point.size.height / 2);
    _paint.style = PaintingStyle.stroke;
    Path path = Path();
    Rect rect = Rect.fromCircle(center: center, radius: point.radius);
    path.addArc(rect, 0, 360);
    canvas.drawPath(path, _paint);

    if (!this.point.isMark) return;

    path = Path();
    rect = Rect.fromCircle(center: center, radius: point.radius);
    path.addArc(rect, 0, 360);
    _paint.color =
        (this.isError ? this.style.errorColor : this.style.selectedColor)
            .withAlpha(0x20);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);

    path = Path();
    rect = Rect.fromCircle(center: center, radius: point.radius / 3.5);
    path.addArc(rect, 0, 360);
    _paint.color =
        (this.isError ? this.style.errorColor : this.style.selectedColor);
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);

    if (this.style.isShowArrow) {
      drawNextArrow(
          canvas, center, point.radius / 2.5, point.radius / 5, point.next);
    }
  }

  ///绘制箭头
  void drawNextArrow(Canvas canvas, Offset center, double arrowWidth,
      double arrowHeight, LockItemPoint nextPoint) {
    if (nextPoint == null) return;
    Path path = Path();
    _paint.style = PaintingStyle.fill;
    var startX = center.dx;
    var startY = center.dy - arrowHeight * 3;
    path.moveTo(startX, startY);
    path.lineTo(startX + arrowWidth / 2, startY + arrowHeight);
    path.lineTo(startX - arrowWidth / 2, startY + arrowHeight);
    path.lineTo(startX, startY);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LockStyle {
  final double lineWidth;
  final double borderWidth;
  final Color selectedColor;
  final Color errorColor;
  final Color defaultColor;
  final bool isShowArrow;

  LockStyle({
    this.isShowArrow = true,
    this.lineWidth = 3.0,
    this.borderWidth = 1.0,
    this.selectedColor = Colors.blue,
    this.defaultColor = Colors.grey,
    this.errorColor = Colors.red,
  });
}

class LockConfig {
  int rows; //行数
  int columns; //列数
  Size lockItemSize; //每个圆圈的大小
  bool isError; //是否显示错误
  bool isKeepTrackOnComplete; //是否在完成绘制的时候保持轨迹

  LockConfig({
    this.rows = 3,
    this.columns = 3,
    this.lockItemSize = const Size(100, 100),
    this.isError = false,
    this.isKeepTrackOnComplete = false,
  });
}

class LockItemPoint {
  String tag;
  Offset center;
  double radius;
  Size size;
  bool isMark = false;
  LockItemPoint next;

  LockItemPoint(this.tag, this.center, this.size) {
    radius = size.width * 0.4;
  }

  bool onTouch(Offset touch) {
    if (isMark) return false;
    var dx = (touch.dx - center.dx).abs();
    var dy = (touch.dy - center.dy).abs();
    var distance = sqrt(pow(dx, 2) + pow(dy, 2)); //获取touch点到圆心的距离
    if (distance <= radius) {
      return true;
    }
    return false;
  }
}
