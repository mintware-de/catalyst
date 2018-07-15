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