/// Dart things I miss in Dart.
library;

import 'dart:async';
import 'dart:math';

import 'package:characters/characters.dart';
import 'package:dart_things/src/_foundation.dart';
import 'package:meta/meta.dart';

/// Just a new line regex. Handles CRLF and LF.
RegExp get newLineRegExp => RegExp('\r?\n');

@immutable

/// A result of something of type [T].
sealed class Result<T> {
  /// {@template Result.Success}
  /// [SuccessResult] ctor.
  ///
  /// Use it for operations, just after [PendingResult].
  /// Or use [ErrorResult] if operation failed.
  /// {@endtemplate}
  const factory Result([T? data]) = SuccessResult;

  /// [ValueResult] ctor.
  ///
  /// Result of initial value, or just a result that saying
  /// that value is a [data]. [data] here always must be treated as provided.
  /// Null doesn't say it is not provided.
  ///
  /// Use [NoResult] if there is no result.
  const factory Result.value([T? data]) = ValueResult;

  /// [ErrorResult] if some operation failed.
  /// It is opposite of [SuccessResult].
  const factory Result.error(Object error) = ErrorResult;

  /// {@macro Result.Success}
  const factory Result.success([T? data]) = SuccessResult;

  /// [ModifiedResult] ctor.
  ///
  /// Says that either [SuccessResult] or [ValueResult] was modified.
  ///
  /// You can use it like you want, but it's purpose is for
  /// edited [SuccessResult] and [ValueResult].
  const factory Result.modifiedData([T? data]) = ModifiedResult;

  const factory Result.pending([T? data]) = PendingResult;

  /// Constant of [NoResult].
  /// Data will be null always.
  const factory Result.no() = NoResult;

  /// Holds an data of [T].
  ///
  /// The [NoResult] throws an error when using this property.
  T? get data;
}

/// Error result means 'Something operation failed'.
final class ErrorResult<T> implements Result<T> {
  /// Main ctor.
  const ErrorResult(this.error, [this.data, this.stacktrace]);

  /// Error.
  final Object error;

  /// Stacktrace of an [error].
  final StackTrace? stacktrace;

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

/// {@macro Result.Success}
final class SuccessResult<T> implements Result<T> {
  /// Main ctor.
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

/// Just a value of [data].
///
/// If [data] is null, it means a data is present and must be treated
/// as present.
final class ValueResult<T> implements Result<T> {
  /// Main ctor.
  const ValueResult([this.data]);

  @override
  final T? data;

  @override
  int get hashCode => data?.hashCode ?? 0;

  @override
  bool operator ==(Object other) {
    return other is SuccessResult<T> && other.data == data;
  }
}

/// Means 'there was a result with data, but now that data is modified'.
///
/// I don't find any useful case for this, but it will be here.
final class ModifiedResult<T> implements Result<T> {
  /// Main ctor.
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

/// Means 'there is no result for an operation'.
///
/// In dev meaning, it is useful when we create a widget without user-action
/// made before, which will produce a result only in future.
final class NoResult<T> implements Result<T> {
  /// Main ctor.
  const NoResult();

  @override
  // !
  // ignore: avoid_field_initializers_in_const_classes
  final T? data = null;

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) {
    return other is NoResult<T>;
  }
}

/// Operation result is pending - it should be made in the future.
/// It is not 'promise'. It says "okay i understand you, but the operation will be
/// or not made in the future relative to some policy"
final class PendingResult<T> implements Result<T> {
  /// Main ctor.
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

/// Useful things on [Result].
extension ColiseumResult<T> on Result<T> {
  /// This to pending, saving current [data].
  PendingResult<T> asPending() => PendingResult(data);
  /// This to success, saving current [data].
  SuccessResult<T> asSuccess() => SuccessResult(data);
  /// This to success with [data] or null.
  SuccessResult<T> asSuccessWithData([T? data]) => SuccessResult(data);
  /// This to [ErrorResult] with error [e] and current data.
  ErrorResult<T> asError(Object e) => ErrorResult(e, data);
}

/// Useful shorthand.
///
/// Cases: (add some later)
/// ```dart
/// Stream<int> ints = Stream<List<int>>().expand(itself);
/// ```
T itself<T>(T self) => self;

/// Useful shorthand for converting [self] to [String].
///
/// Cases: (add some later)
/// ```dart
/// listOfObjects.map(itselfToString).toList();
/// ```
String itselfToString<T>(T self) => self.toString();

/// Self trim.
///
/// When I first trim my own hair, I had to trim my hair bald...
String itselfTrim(String self) => self.trim();

/// Self trim left.
String itselfTrimLeft(String self) => self.trimLeft();

/// Self trim right.
String itselfTrimRight(String self) => self.trimRight();

/// Self to lower case.
String itselfLower(String self) => self.toLowerCase();

/// Self to upper case.
String itselfUpper(String self) => self.toUpperCase();

/// Self is not empty.
///
/// Works on anything with length property.
bool itselfNotEmpty<T extends dynamic>(T self) => self.length != 0;

/// Self is empty.
///
/// Works on anything with length property.
bool itselfEmpty<T extends dynamic>(T self) => self.length == 0;

/// Self is not null.
bool itselfNotNull<T extends Object?>(T self) => self != null;

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

/// Something disposable.
///
/// Provides protected [checkNotDisposed].
///
/// Doesn't checks itself for [Initializer],
/// because there is a cases when something disposable can be initialized in
/// ctor.
abstract mixin class Disposable {
  bool _disposed = false;

  /// Disposes object.
  ///
  /// Doesn't call FlutterMemoryAllocations, because it is for dart.
  ///
  /// After it calls the object must not be used. Guard public methods with:
  /// ```dart
  /// assert(checkNotDisposed('methodName'));
  /// ```
  @mustCallSuper
  void dispose() {
    _disposed = true;
  }

  /// It throws [DisposedException] if this was disposed.
  @protected
  void checkNotDisposed([String? methodName]) {
    if (_disposed) {
      throw DisposedException(describeIdentity(this), methodName);
    }
  }
}

/// Provides a standardized way to initialize something.
///
/// Override [initialize] to initialize internal things.
/// Call to [initialize] will be done in [ensureInitialized] once.
/// It is not safe to call [initialize] repeatedly as [ensureInitialized].
///
/// To initialize object use [ensureInitialized], because it returns
/// Future, which completes when initialization is completed or
/// future if it's already in initialization phase,
/// or nothing when it is already initialized. It is safe method.
///
/// [Initializer] also checks itself for extending [Disposable],
/// and guards [ensureInitialized] and [initialize].
abstract mixin class Initializer {
  Completer<void>? _completer;

  bool _initializing = false;
  bool _initialized = false;
  bool _doNotAssertInitializing = false;

  String get _className => describeIdentity(this);

  /// Ensures something was initialized or initializes it.
  ///
  /// If initialization was started before and it is not completed,
  /// returns future of it's ending.
  ///
  /// If [initialize] in it throws, then object is means to be uninitialized,
  /// and this method can be called again.
  /// The error of [initialize] will caught and rethrow.
  ///
  /// Returns future of initialization ending or nothing if initialized.
  FutureOr<void> ensureInitialized() async {
    if (_completer?.isCompleted ?? false) {
      return;
    }

    if (_initializing) {
      return _completer!.future;
    }

    bool resetDoNotAssert() {
      _doNotAssertInitializing = false;
      return true;
    }

    _completer = Completer<void>();
    assert(() {
      _doNotAssertInitializing = true;
      return true;
    }());

    try {
      _initializing = true;
      await initialize();
      assert(resetDoNotAssert());
      _initialized = true;
      _completer!.complete();
    } catch (e) {
      _initialized = false;
      _completer!.completeError(e);
      _completer = null;
      rethrow;
    } finally {
      assert(resetDoNotAssert());
      _initializing = false;
    }
  }

  /// Initialize something here.
  ///
  /// Will throw if there s already initialization in progress,
  /// or it was initialized using [ensureInitialized].
  ///
  /// There can be multiple [initialize] calls, but with awaiting completion of
  /// previous ones.
  ///
  /// To use it safely use [ensureInitialized].
  ///
  /// For protected use only.
  /// Must be not called directly from outside of an inheritor.
  /// The behaviour on external call is unknown.
  @protected
  @mustCallSuper
  FutureOr<void> initialize() {
    assert(_doNotAssertInitializing || !_initializing,
        'There is already initialization in progress');
    assert(
        !_initialized,
        '$_className has been initialized already. '
        'Use .ensureInitialized to initialize it safely.');
  }

  /// Check whether this has been initialized.
  ///
  /// Throws [AssertionError] if not.
  ///
  /// Return true for use within [assert] statement.
  @protected
  bool checkInitialized() {
    assert(
        _initialized,
        '$_className has not been initialized. '
        'Use ${describeIdentity(this)}.ensureInitialized.');
    return true;
  }
}

final class ReadOnlyCompleter<T> {
  ReadOnlyCompleter(this._base);

  final Completer<T> _base;

  Future<T> get future => _base.future;

  bool get isCompleted => _base.isCompleted;
}

/// As it names says: [start] and [stop] provides a standardized way to
/// start and stop something.
///
/// The [stop] should gratefully stop something when force is false.
abstract mixin class StarterStopperAsync {
  ReadOnlyCompleter<void>? _starterCompleter;

  /// Is some operation is running now?
  bool get isRunning => !(_starterCompleter?.isCompleted ?? true);

  /// Starts something.
  ///
  /// If it is called when [isRunning] is true it just returns future of
  /// a previous start.
  ///
  /// You can use returned future in your implementation of [start].
  /// The future will throw if stop is forced by setting force to true.
  /// The exception will be [StopForcedException].
  /// If force will be false, future just completes.
  /// After calling stop [isRunning] becomes false.
  @mustCallSuper
  ReadOnlyCompleter<void> start() {
    if (_starterCompleter != null) {
      return _starterCompleter!;
    }
    final completer = Completer<void>();
    _starterCompleter = ReadOnlyCompleter<void>(completer);
    return _starterCompleter!;
  }

  /// Stops what was started.
  ///
  /// Provide [forceReason] if [force] is true. There is not assertion for this.
  ///
  /// Override it or use [start] future.
  ///
  /// The future returned from [start] will throw if [force] is true.
  /// The exception will be [StopForcedException].
  @mustCallSuper
  void stop({
    bool force = false,
    String? forceReason,
  }) {
    assert(_starterCompleter != null, 'Not started to be stopped');
    if (force) {
      _starterCompleter!._base.completeError(
          StopForcedException._(describeIdentity(this), forceReason));
    } else {
      _starterCompleter!._base.complete();
    }
    _starterCompleter = null;
  }
}

/// Stop was forced.
final class StopForcedException implements Exception {
  /// Main ctor.
  StopForcedException._(this.objectName, this.reason);

  /// Object name or <optimized_out>#hash.
  final String objectName;

  /// Reason of why stop is force.
  final String? reason;

  @override
  String toString() {
    return '$objectName was stopped with force due to reason: $reason';
  }
}

/// Thrown when an object was disposed and can't be used anymore.
final class DisposedException implements Exception {
  /// Main ctor.
  ///
  /// [objectName] is required and for better debugging shouldn't be runtimeType
  /// toString representation.
  DisposedException(this.objectName, [this.methodName]);

  /// An object name.
  final String objectName;

  /// A method from which this exception was thrown.
  final String? methodName;

  @override
  String toString() {
    final cantUse = methodName == null ? '' : "Can't use $methodName. ";
    return '$cantUse${describeIdentity(this)} was disposed.';
  }
}
