import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Signature extends StatefulWidget {
  final Color color;
  final double strokeWidth;
  final CustomPainter backgroundPainter;
  final Function onSign;

  Signature({
    this.color = Colors.black,
    this.strokeWidth = 5.0,
    this.backgroundPainter,
    this.onSign,
    Key key,
  }) : super(key: key);

  SignatureState createState() => SignatureState();

  static SignatureState of(BuildContext context) {
    return context.findAncestorStateOfType<SignatureState>();
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function onPanStart;
  final Function onPanUpdate;
  final Function onPanEnd;

  CustomPanGestureRecognizer(
      {@required this.onPanStart,
      @required this.onPanUpdate,
      @required this.onPanEnd});

  @override
  void addPointer(PointerEvent event) {
    onPanStart(event.position);
    startTrackingPointer(event.pointer);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}

class _SignaturePainter extends CustomPainter {
  // Size _lastSize;
  final double strokeWidth;
  final List<Offset> points;
  final Color strokeColor;
  Paint _linePaint;

  _SignaturePainter(
      {@required this.points,
      @required this.strokeColor,
      @required this.strokeWidth}) {
    _linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // _lastSize = size;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(points[i], points[i + 1], _linePaint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter other) =>
      (other.points != points) || (other.strokeColor != strokeColor);
}

class SignatureState extends State<Signature> {
  List<Offset> _points = <Offset>[];
  _SignaturePainter _painter;
  Size _lastSize;

  SignatureState();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
    _painter = _SignaturePainter(
        points: _points,
        strokeColor: widget.color,
        strokeWidth: widget.strokeWidth);
    return ClipRect(
      child: CustomPaint(
        painter: widget.backgroundPainter,
        foregroundPainter: _painter,
        child: RawGestureDetector(
          gestures: {
            CustomPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                CustomPanGestureRecognizer>(
              () => CustomPanGestureRecognizer(
                onPanStart: (position) {
                  RenderBox referenceBox = context.findRenderObject();
                  Offset localPostion = referenceBox.globalToLocal(position);
                  setState(() {
                    _points = List.from(_points)
                      ..add(localPostion)
                      ..add(localPostion);
                  });
                  return true;
                },
                onPanUpdate: (position) {
                  RenderBox referenceBox = context.findRenderObject();
                  Offset localPosition = referenceBox.globalToLocal(position);

                  setState(() {
                    _points = List.from(_points)..add(localPosition);
                    if (widget.onSign != null) {
                      widget.onSign();
                    }
                  });
                },
                onPanEnd: (position) {
                  _points.add(null);
                },
              ),
              (CustomPanGestureRecognizer instance) {},
            ),
          },
        ),
      ),
    );
  }

  Future<ui.Image> getData() {
    var recorder = ui.PictureRecorder();
    var origin = Offset(0.0, 0.0);
    var paintBounds = Rect.fromPoints(
        _lastSize.topLeft(origin), _lastSize.bottomRight(origin));
    var canvas = Canvas(recorder, paintBounds);
    if (widget.backgroundPainter != null) {
      widget.backgroundPainter.paint(canvas, _lastSize);
    }
    _painter.paint(canvas, _lastSize);
    var picture = recorder.endRecording();
    return picture.toImage(_lastSize.width.round(), _lastSize.height.round());
  }

  void clear() {
    setState(() {
      _points = [];
    });
  }

  bool get hasPoints => _points.length > 0;

  List<Offset> get points => _points;

  afterFirstLayout(BuildContext context) {
    _lastSize = context.size;
  }
}
