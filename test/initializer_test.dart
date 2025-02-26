import 'package:dart_things/dart_things.dart';
import 'package:test/test.dart';

class _Initializer with Initializer {
  var a = 2;

  @override
  Future<void> initialize() async {
    super.initialize();
    await Future.delayed(const Duration(seconds: 1));
  }
}

void main() {
  test("Initializer ensureInitialized doesn't throw on repeated call",
          () async {
        final obj = _Initializer();

        await expectLater(() async {
          obj.ensureInitialized();
          await obj.ensureInitialized();
          await obj.ensureInitialized();
          await obj.ensureInitialized();
          await obj.ensureInitialized();
          await obj.ensureInitialized();
          await obj.ensureInitialized();
        }(), completes,);
      });
}
