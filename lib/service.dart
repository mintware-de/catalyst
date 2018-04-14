/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of Catalyst;

class Service {
  /// The id of the service
  String _id;

  /// The target if the service is resolved
  ///
  /// A class symbol will be resolved by calling the constructor with  [_arguments]
  /// Closures will be called with [_arguments]
  dynamic _target;

  /// The arguments which are required to resolve the target
  List<dynamic> _arguments;

  /// Creates a new service object
  Service(this._id, this._target, [this._arguments]);

  /// Getter for [_id]
  String get id => _id;

  /// Getter for [_target]
  dynamic get target => _target;

  /// Getter for [_arguments]
  List<dynamic> get arguments => _arguments;
}
