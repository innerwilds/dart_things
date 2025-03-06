import 'package:meta/meta.dart';

/// A result of something of type [T].
@immutable
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