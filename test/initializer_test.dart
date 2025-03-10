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

class ImplementedDisposable implements Disposable {
  @override
  void dispose() {
    Disposable.disposeObject(this);
  }
}

void main() {
  test("Initializer ensureInitialized doesn't throw on repeated call",
      () async {
    final obj = _Initializer();

    await expectLater(
      () async {
        obj.ensureInitialized();
        await obj.ensureInitialized();
        await obj.ensureInitialized();
        await obj.ensureInitialized();
        await obj.ensureInitialized();
        await obj.ensureInitialized();
        await obj.ensureInitialized();
      }(),
      completes,
    );
  });

  final disposable = ImplementedDisposable();
  disposable.dispose();

  test('checkObjectDisposed throws on disposed object', () {
    expect(() {
      Disposable.checkObjectDisposed(disposable);
    }, throwsA(isA<DisposedException>()));
  });
}
