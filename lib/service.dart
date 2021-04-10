/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018-present by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of catalyst;

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

  var _targetMirrorLoaded = false;
  late MethodMirror _targetMirror;

  /// Creates a new service object
  Service(this._id, this._target, [this._arguments = const []]);

  ServiceMetaData getMetadata() {
    var mirror = targetMirror;
    var minArguments = 0;
    var maxArguments = mirror.parameters.length;

    var argTypes = <Type>[];
    for (var parameter in mirror.parameters) {
      minArguments += !parameter.isOptional ? 1 : 0;
      argTypes.add(parameter.type.reflectedType);
    }

    return ServiceMetaData(minArguments, maxArguments, argTypes);
  }

  MethodMirror get targetMirror {
    if (!_targetMirrorLoaded) {
      if (target is Type) {
        var members = reflectClass(target).declarations.values;
        if (members.isNotEmpty) {
          _targetMirror = members
              .whereType<MethodMirror>()
              .firstWhere((m) => m.isConstructor);
        }
      } else if (target is Function) {
        _targetMirror = (reflect(target) as ClosureMirror).function;
      } else {
        throw Exception('Failed to create the target mirror');
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

class NullService extends Service {
  NullService() : super('NULL_SERVICE', null);
}
