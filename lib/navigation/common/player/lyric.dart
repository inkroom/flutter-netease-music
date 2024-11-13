import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';

import '../../../repository.dart';

const _kEnablePaintDebug = false;

class Lyric extends StatefulWidget {
  Lyric({
    required this.lyric,
    this.lyricLineStyle,
    this.position,
    this.textAlign = TextAlign.center,
    this.highlight = Colors.red,
    required this.size,
    this.onTap,
    required this.playing,
  }) : assert(lyric.size > 0);

  final TextStyle? lyricLineStyle;

  final LyricContent lyric;

  final TextAlign textAlign;

  final int? position;

  final Color? highlight;

  final Size size;

  final VoidCallback? onTap;

  /// player is playing
  final bool playing;

  @override
  State<StatefulWidget> createState() => LyricState();
}

class LyricState extends State<Lyric> with TickerProviderStateMixin {
  LyricPainter? lyricPainter;

  AnimationController? _flingController;

  AnimationController? _lineController;

  //歌词色彩渐变动画
  AnimationController? _gradientController;

  @override
  void initState() {
    super.initState();
    lyricPainter = LyricPainter(
      widget.lyricLineStyle!,
      widget.lyric,
      textAlign: widget.textAlign,
      highlight: widget.highlight,
    );
    _scrollToCurrentPosition(widget.position);
  }

  @override
  void didUpdateWidget(Lyric oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyric != oldWidget.lyric) {
      lyricPainter = LyricPainter(
        widget.lyricLineStyle!,
        widget.lyric,
        textAlign: widget.textAlign,
        highlight: widget.highlight,
      );
    }
    if (widget.position != oldWidget.position) {
      _scrollToCurrentPosition(widget.position);
    }

    if (widget.playing != oldWidget.playing) {
      if (!widget.playing) {
        _gradientController?.stop();
      } else {
        _gradientController?.forward();
      }
    }
  }

  /// scroll lyric to current playing position
  void _scrollToCurrentPosition(int? milliseconds, {bool animate = true}) {
    if (lyricPainter!.height == -1) {
      WidgetsBinding.instance?.addPostFrameCallback((d) {
//        debugPrint("try to init scroll to position ${widget.position.value},"
//            "but lyricPainter is unavaiable, so scroll(without animate) on next frame $d");
        //TODO maybe cause bad performance
        if (mounted) _scrollToCurrentPosition(milliseconds, animate: false);
      });
      return;
    }

    final int line = widget.lyric
        .findLineByTimeStamp(milliseconds!, lyricPainter!.currentLine);

    if (lyricPainter!.currentLine != line && !dragging) {
      final double offset = lyricPainter!.computeScrollTo(line);

      if (animate) {
        _lineController?.dispose();
        _lineController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _lineController!.dispose();
              _lineController = null;
            }
          });
        final Animation<double> animation = Tween<double>(
                begin: lyricPainter!.offsetScroll,
                end: lyricPainter!.offsetScroll + offset)
            .chain(CurveTween(curve: Curves.easeInOut))
            .animate(_lineController!);
        animation.addListener(() {
          lyricPainter!.offsetScroll = animation.value;
        });
        _lineController!.forward();
      } else {
        lyricPainter!.offsetScroll += offset;
      }

      _gradientController?.dispose();
      final entry = widget.lyric[line];
      final startPercent = (milliseconds - entry.position) / entry.duration;
      _gradientController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: (entry.duration * (1 - startPercent)).toInt()),
      );
      _gradientController!.addListener(() {
        lyricPainter!.lineGradientPercent = _gradientController!.value;
      });
      if (widget.playing) {
        _gradientController!.forward(from: startPercent);
      } else {
        _gradientController!.value = startPercent;
      }
    }
    lyricPainter!.currentLine = line;
  }

  bool dragging = false;

  bool _consumeTap = false;

  @override
  void dispose() {
    _flingController?.dispose();
    _flingController = null;
    _lineController?.dispose();
    _lineController = null;
    _gradientController?.dispose();
    _gradientController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, minHeight: 120),
      child: _ScrollerListener(
        onScroll: (delta) {
          lyricPainter!.offsetScroll += -delta;
        },
        child: GestureDetector(
          onTap: () {
            if (!_consumeTap && widget.onTap != null) {
              widget.onTap!();
            } else {
              _consumeTap = false;
            }
          },
          onTapDown: (details) {
            if (dragging) {
              _consumeTap = true;

              dragging = false;
              _flingController?.dispose();
              _flingController = null;
            }
          },
          onVerticalDragStart: (details) {
            dragging = true;
            _flingController?.dispose();
            _flingController = null;
          },
          onVerticalDragUpdate: (details) {
            lyricPainter!.offsetScroll += details.primaryDelta!;
          },
          onVerticalDragEnd: (details) {
            _flingController = AnimationController.unbounded(
              vsync: this,
              duration: const Duration(milliseconds: 300),
            )
              ..addListener(() {
                double value = _flingController!.value;

                if (value < -lyricPainter!.height || value >= 0) {
                  _flingController!.dispose();
                  _flingController = null;
                  dragging = false;
                  value = value.clamp(-lyricPainter!.height, 0.0);
                }
                lyricPainter!.offsetScroll = value;
                lyricPainter!.repaint();
              })
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  dragging = false;
                  _flingController?.dispose();
                  _flingController = null;
                }
              })
              ..animateWith(ClampingScrollSimulation(
                  position: lyricPainter!.offsetScroll,
                  velocity: details.primaryVelocity!));
          },
          child: CustomPaint(
            size: widget.size,
            painter: lyricPainter,
          ),
        ),
      ),
    );
  }
}

class _ScrollerListener extends StatefulWidget {
  const _ScrollerListener({
    Key? key,
    required this.child,
    required this.onScroll,
    this.axisDirection = AxisDirection.down,
  }) : super(key: key);

  final Widget child;

  final void Function(double offset) onScroll;

  final AxisDirection axisDirection;

  @override
  State<_ScrollerListener> createState() => _ScrollerListenerState();
}

class _ScrollerListenerState extends State<_ScrollerListener> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _receivedPointerSignal,
      child: widget.child,
    );
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (_pointerSignalEventDelta(event) != 0.0) {
        GestureBinding.instance?.pointerSignalResolver
            .register(event, _handlePointerScroll);
      }
    }
  }

  void _handlePointerScroll(PointerEvent event) {
    assert(event is PointerScrollEvent);
    final double delta = _pointerSignalEventDelta(event as PointerScrollEvent);
    final double scrollerScale;
    if (defaultTargetPlatform == TargetPlatform.windows) {
      scrollerScale = window.devicePixelRatio * 2;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      scrollerScale = window.devicePixelRatio;
    } else {
      scrollerScale = 1;
    }
    widget.onScroll(delta * scrollerScale);
  }

  // Returns the delta that should result from applying [event] with axis and
  // direction taken into account.
  double _pointerSignalEventDelta(PointerScrollEvent event) {
    double delta = event.scrollDelta.dy;

    if (axisDirectionIsReversed(widget.axisDirection)) {
      delta *= -1;
    }
    return delta;
  }
}

class LyricPainter extends ChangeNotifier implements CustomPainter {
  ///param lyric must not be null
  LyricPainter(
    TextStyle style,
    this.lyric, {
    this.textAlign = TextAlign.center,
    Color? highlight = Colors.red,
  }) {
    lyricPainters = [];
    for (int i = 0; i < lyric.size; i++) {
      final painter = TextPainter(
          text: TextSpan(style: style, text: lyric[i].line),
          textAlign: textAlign);
      painter.textDirection = TextDirection.ltr;
//      painter.layout();//layout first, to get the height
      lyricPainters.add(painter);
    }
    _styleHighlight = style.copyWith(color: highlight);
  }

  LyricContent lyric;
  late List<TextPainter> lyricPainters;

  final TextPainter _highlightPainter =
      TextPainter(textDirection: TextDirection.ltr);

  double _offsetScroll = 0;

  double get offsetScroll => _offsetScroll;

  double _lineGradientPercent = -1;

  double get lineGradientPercent {
    if (_lineGradientPercent == -1) return 1.0;
    return _lineGradientPercent.clamp(0.0, 1.0);
  }

  ///音乐播放时间,毫秒
  set lineGradientPercent(double percent) {
    _lineGradientPercent = percent;
    repaint();
  }

  set offsetScroll(double value) {
    if (height == -1) {
      // do not change offset when height is not available.
      return;
    }
    _offsetScroll = value.clamp(-height, 0.0);
    repaint();
  }

  int currentLine = 0;

  TextAlign textAlign;

  TextStyle? _styleHighlight;

  void repaint() {
    notifyListeners();
  }

  double get height => _height;
  double _height = -1;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    _layoutPainterList(size);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    //当offsetScroll为0时,第一行绘制在正中央
    double dy = offsetScroll + size.height / 2 - lyricPainters[0].height / 2;

    for (int line = 0; line < lyricPainters.length; line++) {
      final TextPainter painter = lyricPainters[line];

      if (line == currentLine) {
        _paintCurrentLine(canvas, painter, dy, size);
      } else {
        drawLine(canvas, painter, dy, size);
      }
      dy += painter.height;
    }
  }

  //绘制当前播放中的歌词
  void _paintCurrentLine(
      ui.Canvas canvas, TextPainter painter, double dy, ui.Size size) {
    if (dy > size.height || dy < 0 - painter.height) {
      return;
    }

    //for current highlight line, draw background text first
    drawLine(canvas, painter, dy, size);

    _highlightPainter
      ..text = TextSpan(
          text: (painter.text as TextSpan?)?.text, style: _styleHighlight)
      ..textAlign = textAlign;

    _highlightPainter.layout(); //layout with unbound width

    double lineWidth = _highlightPainter.width;
    double gradientWidth = _highlightPainter.width * lineGradientPercent;
    final double lineHeight = _highlightPainter.height;

    _highlightPainter.layout(maxWidth: size.width);

    final highlightRegion = Path();
    double lineDy = 0;
    while (gradientWidth > 0) {
      double dx = 0;
      if (lineWidth < size.width) {
        dx = (size.width - lineWidth) / 2;
      }
      highlightRegion.addRect(
          Rect.fromLTWH(0, dy + lineDy, dx + gradientWidth, lineHeight));
      lineWidth -= _highlightPainter.width;
      gradientWidth -= _highlightPainter.width;
      lineDy += lineHeight;
    }

    canvas.save();
    canvas.clipPath(highlightRegion);

    drawLine(canvas, _highlightPainter, dy, size);
    canvas.restore();

    assert(() {
      if (_kEnablePaintDebug) {
        final painter = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawPath(highlightRegion, painter);
      }
      return true;
    }());
  }

  ///draw a lyric line
  void drawLine(
      ui.Canvas canvas, TextPainter painter, double dy, ui.Size size) {
    if (dy > size.height || dy < 0 - painter.height) {
      return;
    }
    canvas.save();
    canvas.translate(_calculateAlignOffset(painter, size), dy);

    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  double _calculateAlignOffset(TextPainter painter, ui.Size size) {
    if (textAlign == TextAlign.center) {
      return (size.width - painter.width) / 2;
    }
    return 0;
  }

  @override
  bool shouldRepaint(LyricPainter oldDelegate) {
    return true;
  }

  void _layoutPainterList(ui.Size size) {
    _height = 0;
    for (final p in lyricPainters) {
      p.layout(maxWidth: size.width);
      _height += p.height;
    }
  }

  //compute the offset current offset to destination line
  double computeScrollTo(int destination) {
    if (lyricPainters.isEmpty || this.height == 0) {
      return 0;
    }

    double height = -lyricPainters[0].height / 2;
    for (int i = 0; i < lyricPainters.length; i++) {
      if (i == destination) {
        height += lyricPainters[i].height / 2;
        break;
      }
      height += lyricPainters[i].height;
    }
    return -(height + offsetScroll);
  }

  @override
  bool? hitTest(ui.Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) =>
      shouldRepaint(oldDelegate as LyricPainter);
}
