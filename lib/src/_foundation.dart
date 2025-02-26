import 'package:meta/meta.dart';

@internal
String describeIdentity(Object? object) =>
    '${objectRuntimeType(object, '<optimized out>')}#${shortHash(object)}';

@internal
String objectRuntimeType(Object? object, String optimizedValue) {
  assert(() {
    optimizedValue = object.runtimeType.toString();
    return true;
  }());
  return optimizedValue;
}

@internal
String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}
