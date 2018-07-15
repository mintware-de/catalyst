/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

import 'package:catalyst/catalyst.dart';
import 'package:test/test.dart';

void main() {
  test('Test constructor and inheritance', () {
    var container = new Container();
    expect(container, const TypeMatcher<Container>());
    expect(container, const TypeMatcher<ContainerInterface>());
  });

  test('Test register a service name twice fails', () {
    var container = new Container();

    container.register('failing', () {});
    expect(
        () => container.register('failing', () {}),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString() ==
                'Exception: A service with the id "failing" already exist')));
  });

  test('Test register a service with an empty id fails', () {
    var container = new Container();

    container.register('fail_service', () {});
    expect(
        () => container.register('                       ', () {}),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString() ==
                'Exception: The id must have at least one character')));
  });

  test('Test register a service', () {
    var container = new Container();
    container.register('hello', () {});
    expect(container.registeredServices['hello'], const TypeMatcher<Service>());
  });

  test('Unregister service fails missing', () {
    var container = new Container();
    expect(
        () => container.unregister('foobar'),
        throwsA(predicate((e) =>
            e is ServiceNotFoundException &&
            e.message == 'The service "foobar" does not exist')));
  });

  test('Unregister service fails already loaded', () {
    var container = new Container();

    container.register('foo', () => null);
    container.get('foo');

    var msg =
        'Exception: The service "foo" can not be unregistered because it\'s loaded';
    expect(() => container.unregister('foo'),
        throwsA(predicate((e) => e is Exception && e.toString() == msg)));
  });

  test('Unregister service', () {
    var container = new Container();

    expect(container.registeredServices, hasLength(0));
    expect(container.loadedServices, hasLength(0));

    container.register('foo', () => null);
    expect(container.registeredServices, hasLength(1));
    expect(container.loadedServices, hasLength(0));

    container.unregister('foo');
    expect(container.registeredServices, hasLength(0));
    expect(container.loadedServices, hasLength(0));
  });

  test('Load service fails', () {
    var container = new Container();

    var msg = 'The service "non_existent_service" does not exist';
    expect(
        () => container.get('non_existent_service'),
        throwsA(predicate(
            (e) => e is ServiceNotFoundException && e.message == msg)));
  });

  test('Load service simple', () {
    var container = new Container();
    container.register('message', () => 'A simple message');
    expect(container.registeredServices, hasLength(1));
    expect(container.loadedServices, hasLength(0));

    var message = container.get('message');
    expect(container.registeredServices, hasLength(1));
    expect(container.loadedServices, hasLength(1));

    expect(message, 'A simple message');
  });

  test('Load service with dependency fails', () {
    var container = new Container();
    container.register('msg', (String dependency) => null, ['1', '2']);

    var msg = 'Exception: The Service "msg" expects exact 1 arguments, 2 given';
    expect(() => container.get('msg'),
        throwsA(predicate((e) => e is Exception && e.toString() == msg)));
  });

  test('Load service with optional dependency fails', () {
    var container = new Container();
    container.register('msg', ([String dependency]) => null, ['1', '2']);

    var msg =
        'Exception: The Service "msg" expects min. 0 and max. 1 arguments, 2 given';
    expect(() => container.get('msg'),
        throwsA(predicate((e) => e is Exception && e.toString() == msg)));
  });

  test('Load Service with static dependency', () {
    var container = new Container();
    container.register('msg', (String dep) => 'Hello, I am $dep', ['static']);

    expect(container.get('msg'), 'Hello, I am static');
  });

  test('Load service with service dependency', () {
    var container = new Container();
    container.register('a_dependency', () => 'dependency');

    container.register('msg', (String dep) {
      return 'Hello, I am a $dep';
    }, ['@a_dependency']);

    expect(container.get('msg'), 'Hello, I am a dependency');
  });

  test('Load service with static dependency array', () {
    var container = new Container();
    container.register('msg', (List<String> arrMessages, [String sep = ';']) {
      return arrMessages.join(sep);
    }, [
      ['Hello', 'World'],
      ', '
    ]);

    expect(container.get('msg'), 'Hello, World');
  });

  test('Load already loaded service', () {
    var container = new Container();

    container.register('my_year', () {
      var date = new SimpleDate();
      date.year = 1982;
      return date;
    });

    expect(container.loadedServices, hasLength(0));

    SimpleDate year1982 = container.get('my_year');
    expect(year1982.year, 1982);

    year1982.year = 1987;
    expect(year1982.year, 1987);

    SimpleDate year1987 = container.get('my_year');
    expect(year1987.year, 1987);

    expect(container.registeredServices, hasLength(1));
    expect(container.loadedServices, hasLength(1));
  });

  test('Add parameter', () {
    var container = new Container();
    container.addParameter('foobar', 'baz');
    expect(container.parameters.containsKey('foobar'), true);
    expect(container.parameters['foobar'], 'baz');
  });

  test('Add parameter fails already defined', () {
    var container = new Container();
    container.addParameter('foobar', 'baz');

    var msg = 'Exception: The parameter "foobar" is already defined';
    expect(() => container.addParameter('foobar', 'baz'),
        throwsA(predicate((e) => e is Exception && e.toString() == msg)));
  });

  test('Set parameter', () {
    var container = new Container();
    container.setParameter('foobar', 'baz');
    expect(container.parameters.containsKey('foobar'), true);
    expect(container.parameters['foobar'], 'baz');

    container.setParameter('foobar', 'bar');
    expect(container.parameters.containsKey('foobar'), true);
    expect(container.parameters['foobar'], 'bar');
  });

  test('Unset parameter fails not exist', () {
    var container = new Container();

    var msg = 'A parameter with the name "foobar" is not defined';
    expect(
        () => container.unsetParameter('foobar'),
        throwsA(predicate(
            (e) => e is ParameterNotDefinedException && e.message == msg)));
  });

  test('Unset parameter', () {
    var container = new Container();
    container.addParameter('foobar', 'baz');
    expect(container.parameters.containsKey('foobar'), true);
    expect(container.parameters['foobar'], 'baz');

    container.unsetParameter('foobar');
    expect(container.parameters.containsKey('foobar'), false);
  });

  test('Has service', () {
    var container = new Container();
    expect(container.has('foo'), false);
    container.register('foo', () => null);
    expect(container.has('foo'), true);
  });

  test('Class as service target', () {
    var container = new Container();
    container.register('simpleDate', SimpleDate, [1955]);

    var date = container.get('simpleDate');
    expect(date, const TypeMatcher<SimpleDate>());
    expect(date.year, 1955);
  });

  test('Get parameter fails', () {
    var container = new Container();

    var msg = 'A parameter with the name "foobar" is not defined';
    expect(
        () => container.getParameter('foobar'),
        throwsA(predicate(
            (e) => e is ParameterNotDefinedException && e.message == msg)));
  });

  test('Load service with parameter', () {
    var container = new Container();
    container.addParameter('database.host', 'my.server.tld');
    container.addParameter('database.port', '1337');
    container.register('db.ctx', (String server) {
      return 'Connecting to $server';
    }, ['%database.host%:%database.port%']);
    expect(container.get('db.ctx'), 'Connecting to my.server.tld:1337');
  });

  test('Autowiring service fails', () {
    var container = new Container();
    container.autoWire = true;
    container.register('simple_date', SimpleDate, [1955]);
    container.register('year_printer', (SimpleDate sd, Container nonExistent) {
      return 'Year: ${sd.year}';
    });

    var msg =
        'Exception: The Service "year_printer" expects exact 2 arguments, 1 given';
    expect(() => container.get('year_printer'),
        throwsA(predicate((e) => e is Exception && e.toString() == msg)));
  });

  test('Autowiring service', () {
    var container = new Container();
    container.autoWire = true;
    container.register('simple_date', SimpleDate, [1955]);
    container.register('year_printer', (SimpleDate sd) {
      return 'Year: ${sd.year}';
    });

    expect(container.get('year_printer'), 'Year: 1955');
  });
}

class SimpleDate {
  int year;

  SimpleDate([this.year]);
}
