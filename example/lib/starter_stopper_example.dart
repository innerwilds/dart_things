import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_things/dart_things.dart';

class MyController extends StarterStopperAsync with CheckedDisposableMixin implements Disposable {
  final StreamController<int> _controller = StreamController();
  Stream<int> get myInts => _controller.stream;

  ReadOnlyCompleter<void>? _futureStop;

  Future<void> _work() async {
    while (isRunning) {
      final myInt = await _getRandomNumberFromInternet(_futureStop!);
      _controller.add(myInt);
    }
  }

  /// This will produce an [HttpClient.close] related error when it stops with force.
  Future<int> _getRandomNumberFromInternet(ReadOnlyCompleter<void> interrupter) async {
    final client = HttpClient();

    interrupter.future.then(
      (_) {
        // Do nothing, because [isRunning] becomes false.
      },
      onError: (_, _) {
        // this will only happen on [StopForcedException].
        client.close(force: true);
      },
    );

    /// Simulate long operation.
    ///
    /// Try to move it before client declaration.
    await Future.delayed(Duration(seconds: 2));

    try {
      final request = await client.getUrl(
        Uri( // https://www.random.org/integers/?num=1&min=0&max=100000&col=1&base=10&format=plain&rnd=new
          scheme: 'https',
          host: 'www.random.org',
          path: 'integers',
          query: 'num=1&min=0&max=100000&col=1&base=10&format=plain&rnd=new'
        ),
      );
      final response = await request.close();
      final bytes = await response.expand(itself).toList();
      final string = utf8.decode(bytes);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('Response error: $string');
        return -1;
      }
      final myInt = int.parse(string);
      return myInt;
    } finally {
      // Just close it to free mem.
      client.close();
    }
  }

  @override
  ReadOnlyCompleter<void> start() {
    checkNotDisposed('start');
    _futureStop = super.start();
    unawaited(_work());
    return _futureStop!;
  }

  @override
  void dispose() {
    checkNotDisposed('dispose');
    stop(force: true);
  }
}
