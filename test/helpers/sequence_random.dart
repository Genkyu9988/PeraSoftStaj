import 'dart:math';

// Controlled dependency, not a probabilistic assertion. Unexpected calls fail.
class SequenceRandom implements Random {
  SequenceRandom(this.values);

  final List<int> values;
  final bounds = <int>[];
  int _offset = 0;

  bool get exhausted => _offset == values.length;

  @override
  int nextInt(int max) {
    bounds.add(max);
    if (_offset >= values.length) throw StateError('Unexpected random call');
    final value = values[_offset++];
    if (value < 0 || value >= max) throw RangeError.range(value, 0, max - 1);
    return value;
  }

  @override
  bool nextBool() => throw UnsupportedError('Use nextInt');

  @override
  double nextDouble() => throw UnsupportedError('Use nextInt');
}
