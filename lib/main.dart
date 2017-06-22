// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by an AGPL-3.0-style license
// that can be found in the LICENSE file.

import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flumol/molreader.dart';
import 'package:flumol/molrender.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter/services.dart' show rootBundle;

Moldata molecule;

void renderFrame(Duration timestamp) {
  /*rootBundle.loadString('assets/Flumolol.mol').then((file) {
    molecule = loadMolfile(file);
  });*/

  // Initialize drawing.
  final ui.Rect paintBounds =
      ui.Offset.zero & (ui.window.physicalSize / ui.window.devicePixelRatio);
  final ui.PictureRecorder recorder = new ui.PictureRecorder();
  final ui.Canvas canvas = new ui.Canvas(recorder, paintBounds);

  // Create transformation matrix with time-dependant rotation.
  final mat = new Matrix4.identity();

  const secondsPerRotation = 5;
  final angle = timestamp.inMicroseconds / 10e6 / secondsPerRotation * 2 * PI;

  mat.translate(paintBounds.width / 2, paintBounds.height / 2, 0.0);
  mat.setRotationY(angle);
  mat.scale(30.0);

  renderMolecule(molecule, canvas, mat);

  final ui.Picture picture = recorder.endRecording();

  // Create scene graph for GPU rendering.
  final double devicePixelRatio = ui.window.devicePixelRatio;
  final Float64List deviceTransform = new Float64List(16)
    ..[0] = devicePixelRatio
    ..[5] = devicePixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;

  final ui.SceneBuilder sceneBuilder = new ui.SceneBuilder()
    ..pushTransform(deviceTransform)
    ..addPicture(ui.Offset.zero, picture)
    ..pop();

  ui.window.render(sceneBuilder.build());

  // Schedule next frame right away.
  ui.window.scheduleFrame();
}

Future main() async {
  // Load molecule.
  molecule = loadMolfile(await rootBundle.loadString('assets/Flumolol.mol'));

  ui.window.onBeginFrame = renderFrame;
  ui.window.scheduleFrame();
}
