/*
 * This file is part of the Catalyst package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

import 'package:catalyst/catalyst.dart';

main() {
  Container container = new Container();

  // Register the StackAsAService in the container
  container.register('shared_stack', StackAsAService);

  // Get the registered service from the container
  StackAsAService stack = container.get('shared_stack');

  // Modify the stack
  print(stack.length); // Outputs 0

  stack.add("Hello");
  stack.add("World");

  print(stack.length); // Outputs 2

  print(stack.entries); // Outputs [Hello, World]

  // Retrieve the  same service again from the container
  StackAsAService anotherStack = container.get('shared_stack');

  print(anotherStack.length); // Outputs 2

  print(anotherStack.entries); // Outputs [Hello, World]

  // Modify it...
  anotherStack.remove('World');

  // And the first variable is also modified
  print(stack.length); // Outputs 2

  print(stack.entries); // Outputs [Hello]
}

class StackAsAService {
  List<String> _entries = new List<String>();

  void add(String entry) {
    _entries.add(entry);
  }

  void remove(String entry) {
    _entries.removeWhere((e) => e == entry);
  }

  List<String> get entries => _entries;

  int get length => _entries.length;
}
