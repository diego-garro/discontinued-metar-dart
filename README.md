A library for Dart developers.

Inspired from python-metar to parse METAR data in Python Language

## Usage

A simple usage example:

```dart
import 'package:metar/metar.dart';

main() {
  String metarcode = 'METAR MROC 071200Z 10018KT 3000 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
  var metar = new Metar(metarcode);

  print(metar.getCode());
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/diegogarromolina/metart/issues
