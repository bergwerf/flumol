// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

library flumol.molrender;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flumol/molreader.dart';
import 'package:vector_math/vector_math.dart';

class ZItem {
  final Function draw;
  final double z;
  ZItem(this.draw, this.z);
}

/// Render given [molecule] in [canvas] and apply affine [mat].
/// Note that this is a dirty mess. I just wanted to get something working.
void renderMolecule(Moldata molecule, ui.Canvas canvas, Matrix4 mat) {
  // Z-ordering
  final queue = new List<ZItem>();

  // Draw bonds.
  for (final bond in molecule.bonds) {
    final v1 = mat.transformed3(molecule.atoms[bond.from].position);
    final v2 = mat.transformed3(molecule.atoms[bond.to].position);

    queue.add(new ZItem(() {
      final paint = new ui.Paint();
      paint.color = new ui.Color.fromARGB(255, 255, 255, 255);
      paint.strokeWidth = 3.0;
      canvas.drawLine(
          new ui.Offset(v1.x, v1.y), new ui.Offset(v2.x, v2.y), paint);
    }, min(v1.z, v2.z) - 1));
  }

  // Draw each atom as a point.
  for (final atom in molecule.atoms) {
    final v = mat.transformed3(atom.position);
    final c = new ui.Offset(v.x, v.y);
    final r = (v.z + 500) / 50;

    queue.add(new ZItem(() {
      final paint = new ui.Paint();
      paint.shader = new ui.Gradient.radial(c, r, [
        new ui.Color.fromARGB(255, 255, 255, 255),
        getAtomColor(atom.element),
        new ui.Color.fromARGB(255, 10, 10, 10)
      ], [
        0.0,
        0.3,
        0.9
      ]);

      canvas.drawCircle(c, r, paint);
    }, v.z));
  }

  // Sort Z-queue.
  queue.sort((a, b) => a.z > b.z ? 1 : a.z < b.z ? -1 : 0);

  // Draw.
  for (final item in queue) {
    item.draw();
  }
}

ui.Color getAtomColor(String element) {
  return new ui.Color.fromARGB(255, 255, 0, 0);
}
