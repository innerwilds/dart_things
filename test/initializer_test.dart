import 'dart:async';

import 'package:dart_things/dart_things.dart';
import 'package:test/test.dart';

class _Initializer with Initializer {
  @override
  Future<void> initialize() async {
    super.initialize();
    await Future<void>.delayed(const Duration(seconds: 3));
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
            unawaited(obj.ensureInitialized());
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

  test('Initializer.initialize throws AssertionError while initialization in progress',
          () async {
        final obj = _Initializer();

        unawaited(obj.ensureInitialized());

        await expectLater(
          obj.initialize(),
          throwsA(isA<AssertionError>()),
        );
      });

  test('Initializer.initialize throws AssertionError after object become initialized',
          () async {
        final obj = _Initializer();
        await obj.ensureInitialized();
        await expectLater(
          obj.initialize(),
          throwsA(isA<AssertionError>()),
        );
      });

  final disposable = ImplementedDisposable()..dispose();

  test('checkObjectDisposed throws on disposed object', () {
    expect(
      () {
        Disposable.checkObjectDisposed(disposable);
      },
      throwsA(isA<DisposedException>()),
    );
  });
}
