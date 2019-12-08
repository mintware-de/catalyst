/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018-2019 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

import 'package:catalyst/catalyst.dart';
import 'package:test/test.dart';

void main() {
  test('Constructor', () {
    var srv = Service('foo', () => false);

    expect(srv.id, 'foo');
    expect(srv.target, TypeMatcher<Function>());
    expect(srv.arguments, null);
  });

  test('Test constructor with arguments', () {
    var srv = Service('bar', () => 42, ['foo', 'baz', 12]);

    expect(srv.id, 'bar');
    expect(srv.target, TypeMatcher<Function>());
    expect(srv.arguments, ['foo', 'baz', 12]);
  });

  test('Call target', () {
    var srv = Service('bar', (x) => 42 * x, ['foo', 'baz', 12]);

    expect(srv.target(10), 420);
  });
}
