// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

library flumol.molreader;

import 'package:vector_math/vector_math.dart';

class Atom {
  final Vector3 position;
  final String element;
  Atom(this.position, this.element);
}

class Bond {
  final int from, to, c;
  Bond(this.from, this.to, this.c);
}

class Moldata {
  final atoms = new List<Atom>();
  final bonds = new List<Bond>();
}

Moldata loadMolfile(String molfile) {
  final lines = molfile.split('\n');
  if (lines.length < 4) {
    throw new FormatException('corrupt molfile');
  }

  final atomCount = int.parse(lines[3].substring(0, 3));
  if (atomCount <= 0) {
    throw new FormatException('atom count must be > 0');
  }

  final bondCount = int.parse(lines[3].substring(3, 6));
  if (lines.length < 4 + atomCount + bondCount) {
    throw new FormatException('data is too small');
  }

  final mol = new Moldata();
  var offset = 4;

  for (var i = 0; i < atomCount; i++) {
    final line = lines[offset++];

    final x = line.substring(0, 10);
    final y = line.substring(10, 20);
    final z = line.substring(20, 30);
    final element = line.substring(31, 34).trim();

    mol.atoms.add(new Atom(
        new Vector3(double.parse(x), double.parse(y), double.parse(z)),
        element));
  }

  for (var i = 0; i < bondCount; i++) {
    final line = lines[offset++];

    final from = line.substring(0, 3);
    final to = line.substring(3, 6);
    final c = line.substring(6, 9);

    mol.bonds
        .add(new Bond(int.parse(from) - 1, int.parse(to) - 1, int.parse(c)));
  }

  return mol;
}
