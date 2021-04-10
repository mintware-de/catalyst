## 3.0.0
Null-Safety release

## 2.0.3
- Fix lib/container.dart. (-7.24 points)
  - line 14 col 36: Unnecessary new keyword.
  - line 17 col 42: Unnecessary new keyword.
  - line 20 col 38: Unnecessary new keyword.
  - line 28 col 13: Unnecessary new keyword.
  - line 54 col 13: Unnecessary new keyword.

- Fix lib/catalyst.dart. (-0.50 points): line 10 col 9: Name libraries using lowercase_with_underscores.
- Fix lib/service.dart. (-0.50 points): line 43 col 12: Unnecessary new keyword.

## 2.0.2
- Copyright updated
- Travis fixed
- Fix lib/container.dart. (-0.50 points): line 132 col 13: Don't explicitly initialize variables to null.
- Fix lib/service.dart. (-0.50 points): line 50 col 13: Use isNotEmpty instead of length
- `isInstanceOf<T>` replaced by `TypeMatcher<T>`
- `analysis_options.yaml` added

## 2.0.0 / 2.0.1
- SDK version constraint updated
- Test version updated

## 1.1.1

Tests fixed
- Using `Exception.toString()` instead of accessing the message property

## 1.1.0

Code refactored
- `Container.get()` method splitted into multiple methods
  - `_loadAndRetrieveService()`  loads the service and stores it in the `_loadedServices` property
  - `_injectServicesAndParameters()` fetches the `@foobar` services and `%foo_bar%` parameters and inject them
  - `_doAutoWire()` auto wires the injections
- `Service.getMetadata()` and `Service.targetMirror` added
  
## 1.0.0

- First Release
- Example code in /example added

## 0.0.2

- Auto wiring implemented (See "Service auto wiring" in the README)

## 0.0.1

- Initial release