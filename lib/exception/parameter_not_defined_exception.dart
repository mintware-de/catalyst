/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018-2019 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of catalyst;

class ParameterNotDefinedException implements Exception {
  String message;

  ParameterNotDefinedException(this.message);
}
