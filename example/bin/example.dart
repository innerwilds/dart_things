import 'dart:io';

import 'package:example/starter_stopper_example.dart' as example;

void main(List<String> arguments) {
  print('Input STOP or FORCE and press enter to stop. It will produce only "Client is closed" Bad state exception when stopping with force.');

  final myInts = example.MyController();

  myInts.myInts.listen(print);

  stdin.listen((values) {
    final string = systemEncoding.decode(values);

    if (string.compareTo('STOP') == 1 || string.compareTo('STOP') == 0) {
      print('Stopping');
      myInts.stop(force: false);
    }
    else if (string.compareTo('FORCE') == 1 || string.compareTo('FORCE') == 0) {
      print('Stopping with force');
      myInts.stop(force: true);
    }
  });

  myInts.start().then((_) {
    print('Stopped. If the number appears after this line, this is because force was false.');
  }, onError: (_, _) {
    /// suppress StopForcedException.
  });
}
