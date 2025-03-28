import 'dart:async';

import 'package:dart_things/src/_foundation.dart';
import 'package:meta/meta.dart';

final _disposedObjects = Expando<bool>('_disposedObjects');

/// Something disposable.
///
/// Use [disposeObject] to dispose this.
/// Use [checkObjectDisposed] as guard to throw if object was disposed.
abstract class Disposable {
  /// Marks a [disposable] as disposed.
  @protected
  static void disposeObject(Disposable disposable) {
    _disposedObjects[disposable] = true;
  }

  /// It throws [DisposedException] if [disposable] was disposed.
  ///
  /// [DisposedException] will be with [methodName] if it is not null.
  @protected
  @visibleForTesting
  static bool checkObjectDisposed(Disposable disposable, [String? methodName]) {
    if (_disposedObjects[disposable] ?? false) {
      throw DisposedException(describeIdentity(disposable), methodName);
    }
    return true;
  }

  /// Should dispose this using [Disposable.disposeObject].
  ///
  /// In public methods, to check whether this is disposed, use
  /// [Disposable.checkObjectDisposed] with this as first argument.
  /// For better release builds use [assert]:
  /// ```dart
  /// assert(Disposable.checkDisposed(this, 'myLovelyMethod'))
  /// ```
  @mustCallSuper
  void dispose() {
    Disposable.disposeObject(this);
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
  static const _uninitializedState = 0;
  static const _initializingState = 1;
  static const _initializedState = 2;

  Completer<void>? _completer;

  int _state = _uninitializedState;

  bool _isInitializingAssertionDisabled = false;

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
  Future<void> ensureInitialized() async {
    if (_state == _initializedState) {
      return;
    }

    if (_state == _initializingState) {
      return _completer!.future;
    }

    bool resetDoNotAssert() {
      _isInitializingAssertionDisabled = false;
      return true;
    }

    _completer = Completer<void>();

    assert(() {
      _isInitializingAssertionDisabled = true;
      return true;
    }());

    try {
      _state = _initializingState;
      await initialize();
      _state = _initializedState;
      _completer!.complete();
      _completer = null;
    } catch (e) {
      _state = _uninitializedState;
      _completer!.completeError(e);
      _completer = null;
      rethrow;
    } finally {
      assert(resetDoNotAssert());
    }
  }

  /// Initializes something here.
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
    assert((){
      if (_isInitializingAssertionDisabled) {
        _isInitializingAssertionDisabled = false;
        return true;
      }
      return _state != _initializingState;
    }(),
      'There is already initialization in progress',
    );
    assert(
        _state != _initializedState,
        '$_className has been initialized already. '
        'Use $_className.ensureInitialized to initialize it safely.');
  }

  /// Check whether this has been initialized.
  ///
  /// Throws [StateError] if not.
  ///
  /// Wrap in [assert] to exclude this method from code.
  /// Returns true for use within [assert] statement.
  @protected
  static bool checkInitialized(Initializer initializer, [String? methodName]) {
    if (initializer._state != _initializedState) {
      final beforeUsingMethod =
          methodName == null ? '' : ' before using $methodName';
      throw StateError(
          '${initializer._className} has not been initialized$beforeUsingMethod '
          'Use ${initializer._className}.ensureInitialized.');
    }
    return true;
  }
}

/// A wrapper for [Completer] to expose only [future] and [isCompleted].
///
/// It might be needed to expose completion of a [Completer] and to restrict
/// possibility of external [Completer.complete] and [Completer.completeError]
/// calls.
final class ReadOnlyCompleter<T> {
  /// Main ctor.
  ///
  /// Wraps [base] into [ReadOnlyCompleter].
  ReadOnlyCompleter(Completer<T> base) : _base = base;

  final Completer<T> _base;

  /// Future of original completer.
  Future<T> get future => _base.future;

  /// Whether original completer is completed.
  bool get isCompleted => _base.isCompleted;
}

/// As it names says: [start] and [stop] provides a standardized way to
/// start and stop something.
///
/// The [stop] should gratefully stop something when force is false.
abstract mixin class StarterStopperAsync {
  ReadOnlyCompleter<void>? _starterCompleter;

  /// Is some operation is running now?
  ///
  /// For more control over current running status use [currentWorkCompleter].
  bool get isRunning => !(_starterCompleter?.isCompleted ?? true);

  /// Completer, which completes when current work will be stopped.
  ///
  /// Returns null, if there is no running operation.
  ///
  /// @throws [StopForcedException], so be aware of this.
  ReadOnlyCompleter<void>? get currentWorkCompleter => _starterCompleter;

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
        StopForcedException._(describeIdentity(this), forceReason),
      );
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
