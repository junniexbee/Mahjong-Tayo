// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class ManoState extends ChangeNotifier {
  final VoidCallback onWin;

  final int goal;

  ManoState({required this.onWin, this.goal = 100});

  int _progress = 0;
  int _playerTurn = 1;

  int get progress => _progress;

  void setAndCheck(int value) {
    _progress = value;
    notifyListeners();
    if (_progress >= goal) {
      onWin();
    }
  }

  void checkMano(int value) {
    _progress = value;
    notifyListeners();
    if (_progress >= goal) {
      onWin();
    }
  }
}
