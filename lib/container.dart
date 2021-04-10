/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018-present by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of catalyst;

class Container implements ContainerInterface {
  /// Holds the registered services
  final _services = <String, Service>{};

  /// Holds the loaded services
  final _loadedServices = <String, dynamic>{};

  /// Container parameters
  final _parameters = <String, dynamic>{};

  /// Determines if auto wiring is enabled
  var autoWire = true;

  @override
  dynamic get(String id) {
    if (!has(id)) {
      throw ServiceNotFoundException('The service "$id" does not exist');
    }

    if (!_loadedServices.containsKey(id)) {
      return _loadAndRetrieveService(id);
    }

    return _loadedServices[id];
  }

  @override
  bool has(String id) => _services.containsKey(id);

  /// Register a service to the container
  ///
  /// The [id] is the unique identifier of the service and can be used
  /// as reference for other services to inject.
  /// [service] can be anything, is [service] is a function, method or closure,
  /// it will be invoked with the [arguments] within the [get] call.
  /// If a class passed as [service] the constructor will be called with the
  /// [arguments] and the new object instance will be returned within the [get]
  /// call.
  void register(String id, dynamic service, [arguments = const <dynamic>[]]) {
    if (has(id)) {
      throw Exception('A service with the id "$id" already exist');
    }

    if (id.trim() == '') {
      throw Exception('The id must have at least one character');
    }

    _services[id] = Service(id, service, arguments);
  }

  /// Unregister a registered service
  ///
  /// Pass the unique [id] of the Service.
  /// If a service is already loaded it can't be unregistered.
  void unregister(String id) {
    if (!has(id)) {
      throw ServiceNotFoundException('The service "$id" does not exist');
    } else if (_loadedServices.containsKey(id)) {
      var msg =
          'The service "$id" can not be unregistered because it\'s loaded';
      throw Exception(msg);
    }
    _services.remove(id);
  }

  /// Adds a new parameter to the container
  ///
  /// Use [name] as the parameter name and [value] as the parameter value.
  /// If a parameter is already added an exception will be thrown.
  void addParameter(String name, dynamic value) {
    setParameter(name, value, false);
  }

  /// Sets a parameter
  ///
  /// Sets the parameter with the [name]. If [override] is true and the [name]
  /// is already in use, the parameter will be overridden.
  void setParameter(String name, dynamic value, [bool override = true]) {
    if (_parameters.containsKey(name) && !override) {
      throw Exception('The parameter "$name" is already defined');
    }
    _parameters[name] = value;
  }

  /// Removes a parameter
  ///
  /// Pass in [name] the name of the parameter.
  void unsetParameter(String name) {
    if (!_parameters.containsKey(name)) {
      var msg = 'A parameter with the name "$name" is not defined';
      throw ParameterNotDefinedException(msg);
    }
    _parameters.remove(name);
  }

  /// Retrieve a specific registered parameter by [name]
  dynamic getParameter(String name) {
    if (!_parameters.containsKey(name)) {
      var msg = 'A parameter with the name "$name" is not defined';
      throw ParameterNotDefinedException(msg);
    }
    return _parameters[name];
  }

  dynamic _loadAndRetrieveService(String id) {
    var svcDefinition = _services[id];

    if (svcDefinition == null) {
      throw Exception('Service "$id" not found.');
    }

    var arguments = svcDefinition.arguments;
    if (autoWire) {
      arguments = _doAutoWire(svcDefinition.targetMirror, arguments);
    }

    var numGiven = arguments.length;
    var metadata = svcDefinition.getMetadata();
    if (numGiven < metadata.minArguments || numGiven > metadata.maxArguments) {
      throw Exception(_buildWrongArgsMessage(id, numGiven, metadata));
    }

    arguments = _injectServicesAndParameters(arguments);

    dynamic service;
    var target = svcDefinition.target;
    if (target is Type) {
      service = reflectClass(target).newInstance(const Symbol(''), arguments);
    } else if (target is Function) {
      service = (reflect(target) as ClosureMirror).apply(arguments);
    }

    return _loadedServices[id] = service?.reflectee;
  }

  List<dynamic> _injectServicesAndParameters(List<dynamic> arguments) {
    var injected = [];
    for (var argument in arguments) {
      if (argument is String) {
        var paramMatcher = RegExp(r'%([^%]*?)%');

        if (argument.substring(0, 1) == '@') {
          argument = get(argument.substring(1));
        } else if (paramMatcher.hasMatch(argument)) {
          paramMatcher.allMatches(argument).forEach((match) {
            var paramValue = getParameter(match.group(1)!);
            argument = argument.replaceAll(match.group(0), paramValue);
          });
        }
      }
      injected.add(argument);
    }
    return injected;
  }

  static final Service _nullService = NullService();

  List<dynamic> _doAutoWire(MethodMirror reflection, List<dynamic> arguments) {
    var returnArguments = arguments.toList();
    var parameterIndex = -1;
    for (var parameter in reflection.parameters) {
      parameterIndex++;
      if ((returnArguments.length < parameterIndex + 1)) {
        var locatedSvc = _services.values.firstWhere((Service svc) {
          if (!(svc.target is Type)) {
            return false;
          }
          var svcType = reflectType(svc.target).reflectedType;
          return parameter.type.reflectedType == svcType;
        }, orElse: () => _nullService);

        if (locatedSvc is NullService) {
          break;
        }

        returnArguments.add(get(locatedSvc.id));
      }
    }
    return returnArguments;
  }

  /// Builds the message for wrong args count
  ///
  /// 'The Service "foobar" expects exact 0 arguments, 1 given'
  /// 'The Service "foobar" expects min 1 and max. 2 arguments, 3 given'
  String _buildWrongArgsMessage(String id, int numGiven, ServiceMetaData meta) {
    var buffer = StringBuffer();
    buffer.write('The Service "$id" expects ');

    if (meta.minArguments == meta.maxArguments) {
      buffer.write('exact ${meta.minArguments} arguments');
    } else {
      buffer.write('min. ${meta.minArguments} and ');
      buffer.write('max. ${meta.maxArguments} arguments');
    }
    buffer.write(', $numGiven given');

    return buffer.toString();
  }

  /// Returns all registered services
  Map<String, dynamic> get registeredServices => _services;

  /// Returns all loaded
  Map<String, dynamic> get loadedServices => _loadedServices;

  /// Returns all registered parameters
  Map<String, dynamic> get parameters => _parameters;
}
