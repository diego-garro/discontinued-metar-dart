A library for Dart developers.

Inspired from python-metar to parse METAR data in Python Language

## Usage

A simple usage example:

```dart
import 'package:metar/metar.dart';

main() {
  String metarcode = 'METAR MROC 071200Z 10018KT 3000 R07/P2000N BR VV003 17/09 A2994 RESHRA NOSIG';
  var metar = new Metar(metarcode);

  print(metar.code);
  print(metar.month);
  print(metar.year);
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/diegogarromolina/metart/issues


## Special mentions

Thanks to the work made by [@yeradis][yeradis], who create the package
`units` for starting point of measurements in Dart. I took the files directly because they
have an issue in angle.dart that not resolved. Hope they do it soon.

[yeradis]: https://github.com/yeradis

The files are in lib/src/units/ folder:
  * angle.dart
  * length.dart
  * speed.dart
  * temperature.dart
