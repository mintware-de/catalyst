/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of Catalyst;

class Container implements ContainerInterface {
  /// Holds the registered services
  Map<String, Service> _services = new Map<String, Service>();

  /// Holds the loaded services
  Map<String, dynamic> _loadedServices = new Map<String, dynamic>();

  /// Container parameters
  Map<String, dynamic> _parameters = new Map<String, dynamic>();

  @override
  get(String id) {
    if (!this.has(id)) {
      throw new ServiceNotFoundException('The service "$id" does not exist');
    }

    if (this._loadedServices.containsKey(id)) {
      return this._loadedServices[id];
    }

    var target = this._services[id].target;
    var injections = this._services[id].arguments ?? [];

    var isClass = target is Type;
    var isClosure = target is Function;

    MethodMirror reflection;
    dynamic mirror;
    if (isClass) {
      mirror = reflectClass(target);
      var members = mirror.declarations.values;
      if (members.length > 0) {
        reflection = members.firstWhere(
            (m) => m is MethodMirror && m.isConstructor,
            orElse: null);
      }
    } else if (isClosure) {
      mirror = reflect(target) as ClosureMirror;
      reflection = mirror.function;
    }

    int numGiven = injections.length;
    int maxArguments = reflection.parameters.length;
    int minArguments = 0;
    for (var parameter in reflection.parameters) {
      minArguments += !parameter.isOptional ? 1 : 0;
    }

    if (numGiven < minArguments || numGiven > maxArguments) {
      var message =
          'The Service "$id" expects exact $minArguments arguments, $numGiven given';
      if (maxArguments != minArguments) {
        message =
            'The Service "$id" expects min. $minArguments and max. $maxArguments arguments, $numGiven given';
      }
      throw new Exception(message);
    }

    var arguments = [];
    for (var injection in injections) {
      var parameter = injection;

      if (injection is String) {
        var matcher = new RegExp(r"%([^%]*?)%");

        if (parameter.substring(0, 1) == '@') {
          parameter = this.get(parameter.substring(1));
        } else if (matcher.hasMatch(parameter)) {
          Iterable<Match> matches = matcher.allMatches(parameter);
          matches.forEach((m) {
            var param = this.getParameter(m.group(1));
            parameter = parameter.replaceAll(m.group(0), param);
          });
        }
      }

      arguments.add(parameter);
    }

    dynamic loadedService = null;
    if (isClass) {
      loadedService = (mirror as ClassMirror)
          .newInstance(const Symbol(''), arguments)
          .reflectee;
    } else if (isClosure) {
      loadedService = (mirror as ClosureMirror).apply(arguments).reflectee;
    }

    this._loadedServices[id] = loadedService;
    return loadedService;
  }

  @override
  has(String id) {
    return _services.containsKey(id);
  }

  /// Register a service to the container
  ///
  /// The [id] is the unique identifier of the service and can be used
  /// as reference for other services to inject.
  /// [service] can be anything, is [service] is a function, method or closure,
  /// it will be invoked with the [arguments] within the [get] call.
  /// If a class passed as [service] the constructor will be called with the
  /// [arguments] and the new object instance will be returned within the [get]
  /// call.
  register(String id, dynamic service, [List<dynamic> arguments]) {
    if (this.has(id)) {
      throw new Exception('A service with the id "$id" already exist');
    }

    if (id.trim() == '') {
      throw new Exception('The id must have at least one character');
    }

    this._services[id] = new Service(id, service, arguments);
  }

  /// Unregister a registered service
  ///
  /// Pass the unique [id] of the Service.
  /// If a service is already loaded it can't be unregistered.
  unregister(String id) {
    if (!this.has(id)) {
      throw new ServiceNotFoundException('The service "$id" does not exist');
    } else if (_loadedServices.containsKey(id)) {
      var msg =
          'The service "$id" can not be unregistered because it\'s loaded';
      throw new Exception(msg);
    }
    this._services.remove(id);
  }

  /// Adds a new parameter to the container
  ///
  /// Use [name] as the parameter name and [value] as the parameter value.
  /// If a parameter is already added an exception will be thrown.
  addParameter(String name, dynamic value) {
    this.setParameter(name, value, false);
  }

  /// Sets a parameter
  ///
  /// Sets the parameter with the [name]. If [override] is true and the [name]
  /// is already in use, the parameter will be overridden.
  setParameter(String name, dynamic value, [bool override = true]) {
    if (this._parameters.containsKey(name) && !override) {
      throw new Exception('The parameter "$name" is already defined');
    }
    this._parameters[name] = value;
  }

  /// Removes a parameter
  ///
  /// Pass in [name] the name of the parameter.
  unsetParameter(String name) {
    if (!this._parameters.containsKey(name)) {
      var msg = 'A parameter with the name "$name" is not defined';
      throw new ParameterNotDefinedException(msg);
    }
    this._parameters.remove(name);
  }

  /// Retrieve a specific registered parameter by [name]
  getParameter(String name) {
    if (!this._parameters.containsKey(name)) {
      var msg = 'A parameter with the name "$name" is not defined';
      throw new ParameterNotDefinedException(msg);
    }
    return this._parameters[name];
  }

  /// Returns all registered services
  Map<String, dynamic> get registeredServices => _services;

  /// Returns all loaded
  Map<String, dynamic> get loadedServices => _loadedServices;

  /// Returns all registered parameters
  Map<String, dynamic> get parameters => _parameters;
}
