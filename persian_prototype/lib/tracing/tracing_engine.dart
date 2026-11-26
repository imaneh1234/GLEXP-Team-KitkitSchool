import 'dart:math';
import 'dart:ui' show Offset;

/// Follows a child's finger along a letter's strokes, in the correct order.
///
/// Pure logic (no drawing), so it can be tested. All positions are in the
/// same 0–1 box as the letter data; the screen converts touches into it.
///
/// Rules, chosen for 4–8 year olds:
///  * Strokes must be done in writing order (body first, dots last).
///  * Within a stroke, the finger has to follow the direction of writing:
///    it can only "collect" the next few guide points, never jump ahead.
///  * Lifting the finger keeps the progress made so far (no punishment).
///  * After finishing a stroke, the finger must be lifted before the next
///    stroke starts. That teaches that a letter has separate parts.
class TracingEngine {
  TracingEngine(List<List<Offset>> strokes, {this.spacing = 0.025, this.lookahead = 4})
      : paths = [for (final s in strokes) resample(s, spacing)];

  /// Distance between guide points, in the 0–1 box.
  final double spacing;

  /// How many guide points ahead the finger may "reach" at once.
  final int lookahead;

  /// Each stroke, re-sampled into evenly spaced guide points.
  final List<List<Offset>> paths;

  int _stroke = 0;
  int _point = 0; // number of points already collected in the current stroke
  bool _needsLift = false;

  int get strokeIndex => _stroke;
  int get pointIndex => _point;
  bool get isComplete => _stroke >= paths.length;
  bool get waitingForLift => _needsLift;

  /// True when the current stroke is a dot (a single point to tap).
  bool get currentIsDot => !isComplete && paths[_stroke].length == 1;

  /// The point the child should touch next (the "bead" shown on screen).
  Offset? get nextTarget => isComplete ? null : paths[_stroke][_point];

  /// Fraction of the whole letter that is done, from 0 to 1.
  double get progress {
    final total = paths.fold<int>(0, (sum, p) => sum + p.length);
    var done = 0;
    for (var i = 0; i < min(_stroke, paths.length); i++) {
      done += paths[i].length;
    }
    if (!isComplete) done += _point;
    return total == 0 ? 1 : done / total;
  }

  void reset() {
    _stroke = 0;
    _point = 0;
    _needsLift = false;
  }

  /// Finger touches the screen. Returns true if it made progress.
  bool fingerDown(Offset p, double tolerance) {
    _needsLift = false;
    return _follow(p, tolerance);
  }

  /// Finger moves. Returns true if it made progress.
  bool fingerMove(Offset p, double tolerance) {
    if (_needsLift) return false;
    return _follow(p, tolerance);
  }

  void fingerUp() {
    _needsLift = false;
  }

  bool _follow(Offset p, double tolerance) {
    if (isComplete) return false;
    final path = paths[_stroke];
    var advanced = false;
    while (_point < path.length) {
      final end = min(path.length, _point + lookahead);
      int? reached;
      for (var i = _point; i < end; i++) {
        if ((path[i] - p).distance <= tolerance) reached = i;
      }
      if (reached == null) break;
      _point = reached + 1;
      advanced = true;
    }
    if (_point >= path.length) {
      _stroke++;
      _point = 0;
      _needsLift = true;
    }
    return advanced;
  }

  /// Turns a hand-drawn list of corner points into evenly spaced points,
  /// so a stroke is followed smoothly however it was authored.
  static List<Offset> resample(List<Offset> stroke, double spacing) {
    if (stroke.length < 2) return List.of(stroke);
    final result = <Offset>[stroke.first];
    var carried = 0.0;
    for (var i = 1; i < stroke.length; i++) {
      final a = stroke[i - 1];
      final b = stroke[i];
      final length = (b - a).distance;
      var d = spacing - carried;
      while (d <= length) {
        result.add(Offset.lerp(a, b, d / length)!);
        d += spacing;
      }
      carried = length - (d - spacing);
    }
    if ((result.last - stroke.last).distance > spacing * 0.3) result.add(stroke.last);
    return result;
  }
}
