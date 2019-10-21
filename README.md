[![GitHub license](https://img.shields.io/github/license/Devtronic/catalyst.svg)](https://github.com/Devtronic/catalyst/blob/master/LICENSE)
[![Travis](https://img.shields.io/travis/Devtronic/catalyst.svg)](https://travis-ci.org/Devtronic/catalyst)
[![Pub](https://img.shields.io/pub/v/catalyst.svg)](https://pub.dartlang.org/packages/catalyst)
[![Coverage Status](https://coveralls.io/repos/github/Devtronic/catalyst/badge.svg?branch=master)](https://coveralls.io/github/Devtronic/catalyst?branch=master)

# Catalyst

Catalyst is a dependency injection container for the dart language.
It's fast, reliable and easy to understand.

## 📦 Installation
Add the following to your `pubspec.yaml`:
```yaml
dependencies:
  catalyst: ^2.0.2
```

Then run `pub get`

## ❤ Sponsors
No sponsors at the moment. [Become a sponsor](https://github.com/sponsors/devtronic)

## 💡 Usage

### Importing
```dart
import 'package:catalyst/catalyst.dart';
```

### Register Services
To register a service you have to call the `register`-method.

```
Container.register(String id, dynamic service, [List<dynamic> arguments])
```

|  Parameter | Description                                                                    | Example              |
|:-----------|:-------------------------------------------------------------------------------|:---------------------|
| id         | The unique id of the service                                                   | app.my_service       |
| service    | The service target                                                             | `(int a) => a * 2`   |
| arguments  | The arguments for the service. Entries with @-prefix are service references    | `[1, 'foo', bar]`    |

#### Register a service with static arguments
Since not all services need an service injection, the arguments array also supports static entries.

```dart
Container container = new Container();

container.register('app.my_service', (String name) {
  return 'Hello $name';
}, ['Your Name']);

var knownServices = container.registeredServices; // Contains the registered Service 
```

#### Register a service with a service dependency
In most cases you need another registered service in your service.
In that case you can pass the service name with a @-prefix to reference to it.
The (sub-) dependencies are solved recursively.

```dart
Container container = new Container();

container.register('app.another_service', () {
  return {'name': 'Jane', 'age': '24'};
});

container.register('app.my_service', (dynamic anotherService) {
return "Name: ${anotherService['name']}, Age: ${anotherService['age']}";
}, ['@app.another_service']);

print(container.get('app.my_service')); // Outputs "Name: Jane, Age: 24"
```

#### Register a class as a service
You can also register a class as a service. If the service is loaded, the constructor gets called with the dependencies.

```dart
main() {
  Container container = new Container();

  // Register the first service
  container.register('namer', () => 'John Doe');

  // Register the second service. The constructor will be called with the passed arguments
  container.register('greeter', Greeter, ['@namer']);

  // Retrieve the greeter
  var greeter = container.get('greeter');

  // Greet
  print(greeter.greet()); // Outputs "Hello, my Name is John Doe!"
}

class Greeter {
  String name;

  Greeter(this.name) {}

  String greet() {
    return "Hello, my Name is $name!";
  }
}
```

### Load a service
To load a service you have to call the `get`-method.  
Once a service is loaded, it remains in memory at runtime.
When the same service is loaded again, the first instance is returned.

```
Container.get(String id)
```
|  Parameter | Description                     | Example        |
|:-----------|:--------------------------------|:---------------|
| id         | The unique id of the service.   | app.my_service |


```dart
Container container = new Container();

// Register the first service
container.register('namer', () => 'Catalyst');

container.get('namer'); // returns "Catalyst"
```

### Add Parameters
The service container also supports static parameters.  
You can add a parameter using the `addParameter`-method
```
Container.addParameter(String name, dynamic value)
```
|  Parameter | Description                       | Example        |
|:-----------|:----------------------------------|:---------------|
| name       | The unique name of the parameter. | database.host  |
| value      | The parameter value               | localhost      |

To pass a parameter to a service, add before and after the name a '%': `%name.of.the.parameter%`
```dart
Container container = new Container();
container.addParameter('database.host', 'localhost');

container.register('db.context', (String hostname) {
return 'Connecting to $hostname';
}, ['%database.host%']);

print(container.get('db.context')); // Outputs "Connecting to localhost"
```

## 🔌 Service auto wiring
Catalyst supports auto wiring of services.
That means, that you only need to register the service without passing depending service names as arguments.
(Strong typing is required).
 
For example:
```dart
main() {
  Container container = new Container();
  container.register('greeter', SimpleGreeter);
  container.register('greeting_printer', (SimpleGreeter greeter) {
    print(greeter.greet('Catalyst'));
  });

  container.get('greeting_printer'); // Outputs "Hello from Catalyst!"
}

class SimpleGreeter {

  String greet(String name) {
    return "Hello from $name!";
  }
}
```

You can disable this behaviour with setting `Container.autoWire = false;`

## 🔬 Testing

```bash
$ pub run test
```

## 🤝 Contribute
Feel free to fork and add pull-requests 🤓
