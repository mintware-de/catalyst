/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of Catalyst;

abstract class ContainerInterface {
  /// Returns a registered service by [id]
  dynamic get(String id);

  /// Checks, if a service with the [id] is registered
  bool has(String id);
}
