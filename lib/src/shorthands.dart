import 'package:dart_things/coliseum.dart';

/// Useful shorthand.
///
/// Cases: (add some later)
/// ```dart
/// Stream<int> ints = Stream<List<int>>().expand(itself);
/// ```
T itself<T>(T self) => self;

/// Useful shorthand for converting [self] to [String].
///
/// Cases: (add some later)
/// ```dart
/// listOfObjects.map(itselfToString).toList();
/// ```
String itselfToString<T>(T self) => self.toString();

/// Self trim.
///
/// When I first trim my own hair, I had to trim my hair bald...
String itselfTrim(String self) => self.trim();

/// Self trim left.
String itselfTrimLeft(String self) => self.trimLeft();

/// Self trim right.
String itselfTrimRight(String self) => self.trimRight();

/// Self to lower case.
String itselfLower(String self) => self.toLowerCase();

/// Self to upper case.
String itselfUpper(String self) => self.toUpperCase();

/// Self is not empty.
///
/// Works on anything with length property.
bool itselfNotEmpty<T extends dynamic>(T self) => self.length != 0;

/// Self is empty.
///
/// Works on anything with length property.
bool itselfEmpty<T extends dynamic>(T self) => self.length == 0;

/// Self is not null.
bool itselfNotNull<T extends Object?>(T self) => self != null;

/// Self is blank or empty.
bool itselfNotBlankOrEmpty(String self) => self.isNotBlankOrEmpty;
