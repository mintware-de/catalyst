/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018-2019 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of Catalyst;

class Service {
  /// The id of the service
  final String _id;

  /// The target if the service is resolved
  ///
  /// A class symbol will be resolved by calling the constructor with  [_arguments]
  /// Closures will be called with [_arguments]
  final dynamic _target;

  /// The arguments which are required to resolve the target
  final List<dynamic> _arguments;

  bool _targetMirrorLoaded = false;
  MethodMirror _targetMirror;

  /// Creates a new service object
  Service(this._id, this._target, [this._arguments]);

  ServiceMetaData getMetadata() {
    var mirror = targetMirror;
    var minArguments = 0;
    var maxArguments = mirror.parameters.length;

    List<Type> argTypes = [];

    for (var parameter in mirror.parameters) {
      minArguments += !parameter.isOptional ? 1 : 0;
      argTypes.add(parameter.type.reflectedType);
    }

    return new ServiceMetaData(minArguments, maxArguments, argTypes);
  }

  MethodMirror get targetMirror {
    if (!_targetMirrorLoaded) {
      if (target is Type) {
        var members = reflectClass(target).declarations.values;
        if (members.isNotEmpty) {
          _targetMirror =
              members.firstWhere((m) => m is MethodMirror && m.isConstructor);
        }
      } else if (target is Function) {
        _targetMirror = (reflect(target) as ClosureMirror).function;
      }
      _targetMirrorLoaded = true;
    }
    return _targetMirror;
  }

  /// Getter for [_id]
  String get id => _id;

  /// Getter for [_target]
  dynamic get target => _target;

  /// Getter for [_arguments]
  List<dynamic> get arguments => _arguments;
}
