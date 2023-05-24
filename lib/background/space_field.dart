import 'dart:math' as math;

import 'package:animated_background/animated_background.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Holds the information of a star used in a [SpaceBehaviour].
class Star {
  /// The position of the star
  Offset? position;

  /// The target position of the star
  late Offset targetPosition;

  /// The distance of the start to the screen
  late double distance;
}

/// Renders a warp field on a [AnimatedBackground].
///
/// Code inspired by http://www.kevs3d.co.uk/dev/warpfield/
class SpaceBehaviour extends Behaviour {
  static math.Random random = math.Random();

  /// The center of the warp field.
  @protected
  Offset? center;

  /// The target center of the warp field.
  ///
  /// Changing this value will cause the [center] to animate to this value.
  @protected
  Offset? targetCenter;

  /// The list of stars spawned by the behaviour
  @protected
  List<Star>? stars;

  late Color _backgroundColor;

  SpaceBehaviour({
    Color backgroundColor = Colors.black,
  }) {
    _backgroundColor = backgroundColor;
  }

  @override
  void init() {
    center = Offset(size!.width / 2.0, size!.height / 2.0);
    targetCenter = center;
    stars = List<Star>.generate(1000, (_) {
      var star = Star();
      _initStar(star);
      return star;
    });
  }

  void _initStar(Star star) {
    star.targetPosition = Offset(
      (random.nextDouble() * size!.width - size!.width / 2) * 1000.0,
      (random.nextDouble() * size!.height - size!.height / 2) * 1000.0,
    );

    star.distance = random.nextDouble() * 1000.0;
    star.position = Offset(
      star.targetPosition.dx / star.distance,
      star.targetPosition.dy / star.distance,
    );
  }

  @override
  void initFrom(Behaviour oldBehaviour) {
    if (oldBehaviour is SpaceBehaviour) {
      stars = oldBehaviour.stars;
      center = oldBehaviour.center;
      targetCenter = oldBehaviour.targetCenter;
    }
  }

  @override
  bool get isInitialized => stars != null && center != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    var canvas = context.canvas;
    var paint = Paint()..style = PaintingStyle.fill;

    canvas.drawPaint(Paint()..color = _backgroundColor);

    canvas.translate(center!.dx, center!.dy);
    int i = 0;
    double time = DateTime.now().millisecondsSinceEpoch.toDouble() / 1000.0;
    for (Star star in stars!) {
      if (star.position!.dx == 0 || star.distance <= 0.0) continue;
      int calculateColorValue(double value) {
        int result = (math.sin(value) * 128 + 220).floor();
        return result.clamp(0, 255);
      }

      paint.color = Color.fromARGB(
        0xF0,
        calculateColorValue(0.3 * i + 0 + time),
        calculateColorValue(0.3 * i + 2 + time),
        calculateColorValue(0.3 * i + 4 + time),
      );

      var x = star.targetPosition.dx / star.distance * 1.02;
      var y = star.targetPosition.dy / star.distance * 1.02;
      double z = 2.0 / star.distance * 6.0 + 1.0;
      paint.strokeWidth = z;
      canvas.drawLine(
        Offset(x, y),
        star.position!,
        paint,
      );
      i++;
    }
    canvas.translate(-center!.dx, -center!.dy);
  }

  @override
  bool tick(double delta, Duration elapsed) {
    center = Offset.lerp(center, targetCenter, delta * 0.3);
    for (int i = stars!.length - 1; i >= 0; i--) {
      Star star = stars![i];
      star.position = Offset(
        star.targetPosition.dx / star.distance,
        star.targetPosition.dy / star.distance,
      );
      star.distance -= delta * 200;
      if (star.distance <= 0 ||
          star.position!.dx > size!.width ||
          star.position!.dy > size!.height) {
        stars!.removeAt(i);
        var newStar = Star();
        _initStar(newStar);
        stars!.add(newStar);
      }
    }
    return true;
  }

  @override
  Widget builder(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return MouseRegion(
        onHover: (PointerHoverEvent event) {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          var localPosition = renderBox.globalToLocal(event.position);
          final center = Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2,
          );
          if ((localPosition - center).distance <= 300.0) {
            _updateCenter(localPosition);
          }
        },
        child: super.builder(context, constraints, child));
  }

  void _updateCenter(Offset localPosition) {
    targetCenter = localPosition;
  }
}
