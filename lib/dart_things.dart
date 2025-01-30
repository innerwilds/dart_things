library dart_things;

import 'dart:math';
import 'package:characters/characters.dart';

final newLineRegExp = RegExp('\r?\n');

/// A result of something of type [T].
///
/// Initially we can have no data or 
sealed class Result<T> {
  const factory Result([T? data]) = SuccessResult;
  const factory Result.error(Object error) = ErrorResult;
  const factory Result.success([T? data]) = SuccessResult;
  const factory Result.modifiedData([T? data]) = ModifiedResult;
  const factory Result.no() = NoResult;
  const factory Result.pending([T? data]) = PendingResult;

  /// Holds an data of [T].
  ///
  /// The [NoResult] throws an error when using this property.
  T? get data;
}

final class ErrorResult<T> implements Result<T> {
  const ErrorResult(this.error, [this.data]);

  final Object error;

  @override
  final T? data;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is ErrorResult<T> && other.data == data;
  }

  @override
  String toString() {
    return 'ErrorResult(error: $error, $data)';
  }
}

final class SuccessResult<T> implements Result<T> {
  const SuccessResult([this.data]);

  @override
  final T? data;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is SuccessResult<T> && other.data == data;
  }
}

final class ModifiedResult<T> implements Result<T> {
  const ModifiedResult([this.data]);

  @override
  final T? data;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is ModifiedResult<T> && other.data == data;
  }
}

final class NoResult<T> implements Result<T> {
  const NoResult();

  @override
  final T? data = null;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is NoResult<T>;
  }
}

/// Operation result is pending - it should be made in the future.
/// It is not 'promise'. It says "okay i understand you, but the operation will be
/// or not made in the future relative to some policy"
final class PendingResult<T> implements Result<T> {
  const PendingResult([this.data]);

  @override
  final T? data;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is PendingResult<T> && other.data == data;
  }
}

extension ResultExtensions<T> on Result<T> {
  PendingResult<T> asPending() => PendingResult(data);
  SuccessResult<T> asSuccess() => SuccessResult(data);
  SuccessResult<T> asSuccessWithData([T? data]) => SuccessResult(data);
  ErrorResult<T> asError(Object e) => ErrorResult(e, data);
}


T itself<T>(T self) => self;
String itselfToString<T>(T self) => self.toString();

String trimItself(String self) => self.trim();
String trimLeftItself(String self) => self.trimLeft();
String trimRightItself(String self) => self.trimRight();


extension ColliseumIterable<E> on Iterable<E> {
  static bool defaultEquals(dynamic a, dynamic b) {
    return a == b;
  }

  /// Whether [other] has the same elements as this iterable.
  ///
  /// Returns true if [other] has the same iterable items
  /// according to an [equals].
  bool equals(Iterable<E>? other, [bool Function(E, E) equals = defaultEquals]) {
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

extension ColliseumList<T> on List<T> {
  List<C> mapToReadOnlyList<C>(C Function(T) mapper) =>
      map(mapper).toList(growable: false);
}

extension ColliseumSet<T> on Set<T> {
  bool equalsTo(Set<T>? b) {
    if (b == null || length != b.length) {
      return false;
    }
    if (identical(this, b)) {
      return true;
    }
    for (final T value in this) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }
}

extension ColliseumObject<C extends Object> on C {
  T let<T>(T Function(C) block) {
    return block(this);
  }
}

extension ColliseumString<C extends String> on C {
  static final _wordCharacterClasses = <String>{
    "Letter",
    "Mark",
    "Number",
  };

  /// Anything with word separation to lowerCamelCase.
  /// Example: Hello, Santiago! How are you? Are you 28 years old? Ya-Yo!
  /// Become: helloSantiagoHowAreYouAreYou28YearsOldYaYo
  ///
  /// But string hellosantiagohowareyou becomes itself, because no word
  /// separation present.
  String toLowerCamelCase() {
    final classes = _wordCharacterClasses.map((clas) => r'\p{' '$clas}').join('');
    final nonLetterManyThenOneLetter = RegExp(
      r'[^' '$classes]+[$classes]',
      unicode: true,
      caseSensitive: true,
    );
    final firstLetter = RegExp(
      r'^[' '$classes]{1}',
      caseSensitive: true,
      unicode: true,
    );
    final badEnd = RegExp(r'[^' '$classes' r']$',
      caseSensitive: true,
      unicode: true,);

    return replaceAllMapped(nonLetterManyThenOneLetter, (match) {
      /// We found substring ending with a letter.
      final string = match.group(0)!;
      return string.characters.last.toUpperCase();
    }).replaceFirstMapped(firstLetter, (match) => match.group(0)!.toLowerCase())
      .replaceAll(badEnd, '');
  }

  String safeEndSubstring(int start, [int? end]) {
    return substring(start, end == null ? null : min(end, length));
  }
}
