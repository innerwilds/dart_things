import 'dart:math' show min;

import 'package:characters/characters.dart';

/// Useful things on [Iterable].
extension ColiseumIterable<E> on Iterable<E> {
  static bool _defaultEquals(dynamic a, dynamic b) {
    return a == b;
  }

  /// This iterable with [end] at the end.
  Iterable<E> withEnd(E end) sync* {
    for (final e in this) {
      yield e;
    }
    yield end;
  }

  /// This iterable with [start] at the start.
  Iterable<E> withStart(E start) sync* {
    yield start;
    for (final e in this) {
      yield e;
    }
  }

  /// This iterable without [something].
  Iterable<E> without(E something) sync* {
    for (final e in this) {
      if (something == e) continue;
      yield e;
    }
  }

  /// Whether [other] has the same elements as this iterable in order
  /// they are moved, and their length is the same.
  ///
  /// [1,2,3,4] will match [1,2,3,4]
  /// but [4,1,2,1] will not match [1,1,2,4].
  /// [1,2,3,4] will not match [1,2,3]
  /// [1,2,3,] will not match [1,2,3,4].
  ///
  /// So this matches identical iterables in meaning of their values, not a link
  /// in memory.
  ///
  /// If you need zero-difference, convert them to set and use
  /// [ColiseumSet.equalsTo].
  bool equals(Iterable<E>? other,
      [bool Function(E, E) equals = _defaultEquals]) {
    if (other == null) {
      return false;
    }

    final iter1 = iterator;
    final iter2 = other.iterator;

    while (true) {
      final iter1HasValue = iter1.moveNext();
      final iter2HasValue = iter2.moveNext();

      if (iter1HasValue != iter2HasValue) {
        return false;
      }

      if (iter1HasValue && iter2HasValue) {
        final iter1Value = iter1.current;
        final iter2Value = iter2.current;
        if (!equals(iter1Value, iter2Value)) {
          return false;
        }
        continue;
      }

      // both are false
      break;
    }

    return true;
  }

  /// Returns first non-null result of [predicateAndMap] or null if there
  /// is no non-null results for any item in this iterable.
  C? firstWhereOrNullMapped<C>(C? Function(E) predicateAndMap) {
    for (final item in this) {
      final mapped = predicateAndMap(item);
      if (mapped != null) {
        return mapped;
      }
    }
    return null;
  }
}

/// Useful things on [List].
extension ColiseumList<T> on List<T> {
  /// [map]s this to a not growable list.
  List<C> mapToReadOnlyList<C>(C Function(T) mapper) =>
      map(mapper).toList(growable: false);

  /// Regenerates a list to have provided [newLength].
  ///
  /// If current [length] is greather than [newLength] we remove last ones
  /// to match new length.
  /// Removed elements can be handled by [onRemove].
  /// If current [length] is lower than [newLength] we [generate] new ones
  /// to match new length.
  /// Matched lengths does nothing.
  void regenerate({
    required int newLength,
    required T Function(int) generate,
    void Function(T)? onRemove,
  }) {
    assert(newLength >= 0, "new length can't be lower than 0");

    final diff = length - newLength;

    if (diff == 0) return;

    if (diff > 0) {
      final toRemove = sublist(newLength);
      length = newLength;
      if (onRemove != null) {
        for (final removedItem in toRemove) {
          onRemove(removedItem);
        }
      }
    } else {
      for (var i = 0; i > diff; i--) {
        add(generate(length - i));
      }
    }
  }
}

/// Useful things on [Set].
extension ColiseumSet<T> on Set<T> {
  /// Whether current set equals to [other].
  bool equalsTo(Set<T>? other) {
    if (other == null || length != other.length) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    for (final value in this) {
      if (!other.contains(value)) {
        return false;
      }
    }
    return true;
  }

  /// Regenerates a set to have provided [newLength].
  ///
  /// If current [length] is greater than [newLength] it will remove last ones
  /// to match new length.
  /// Removed elements can be handled by [onRemove].
  /// If current [length] is lower than [newLength] we [generate] new ones
  /// to match new length.
  ///
  /// If length matches current, does nothing.
  void regenerate({
    required int newLength,
    required T Function(int) generate,
    void Function(T)? onRemove,
  }) {
    assert(newLength >= 0, "new length can't be lower than 0");

    final diff = length - newLength;

    if (diff == 0) return;

    if (diff > 0) {
      while (length > newLength) {
        final removedElement = first;
        remove(removedElement);
        onRemove?.call(removedElement);
      }
    } else {
      for (var i = 0; i > diff; i--) {
        add(generate(length - i));
      }
    }
  }
}

/// Kotlin-like useful things, if you love long-stacktrace.
extension ColiseumObject<C extends Object> on C {
  /// Executes [block] with this as argument.
  /// Returns what [block] returns.
  T let<T>(T Function(C) block) {
    return block(this);
  }
}

/// String useful things.
extension ColiseumString on String {
  static final _wordCharacterClasses = <String>{
    'Letter',
    'Mark',
    'Number',
  };

  /// Anything with word separation to lowerCamelCase.
  /// Example: Hello, Santiago! How are you? Are you 28 years old? Ya-Yo!
  /// Become: helloSantiagoHowAreYouAreYou28YearsOldYaYo
  ///
  /// But string hellosantiagohowareyou becomes itself, because no word
  /// separation present.
  String toLowerCamelCase() {
    final classes = _wordCharacterClasses.map((clas) => r'\p{' '$clas}').join();
    final nonLetterManyThenOneLetter = RegExp(
      '[^' '$classes]+[$classes]',
      unicode: true,
    );
    final firstLetter = RegExp(
      '^[ $classes]{1}',
      unicode: true,
    );
    final badEnd = RegExp(
      '[^ $classes' r']$',
      unicode: true,
    );

    return replaceAllMapped(nonLetterManyThenOneLetter, (match) {
      /// We found substring ending with a letter.
      final string = match.group(0)!;
      return string.characters.last.toUpperCase();
    })
        .replaceFirstMapped(
        firstLetter, (match) => match.group(0)!.toLowerCase())
        .replaceAll(badEnd, '');
  }

  /// Substring with safe end, so if end will be greater than [length],
  /// it will not throw.
  ///
  /// Start is not safe.
  String safeEndSubstring(int start, [int? end]) {
    return substring(start, end == null ? null : min(end, length));
  }
}
