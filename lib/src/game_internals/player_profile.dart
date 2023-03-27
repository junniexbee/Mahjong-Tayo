// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
List<PlayerProfile> players = [
  PlayerProfile(id: 1, username: "Juness", tayoCoins: 1000),
  PlayerProfile(id: 1, username: "Eula", tayoCoins: 1000),
  PlayerProfile(id: 1, username: "Charles", tayoCoins: 1000),
  PlayerProfile(id: 1, username: "Gerry", tayoCoins: 1000),
];

class PlayerProfile {
  final int id;
  String username;
  int tayoCoins;
  int rank = 0;

  PlayerProfile({
    required this.id,
    required this.username,
    required this.tayoCoins
  });
}
