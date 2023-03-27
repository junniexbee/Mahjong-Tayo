// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class BottomAppBarContents extends StatelessWidget {
  const BottomAppBarContents({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return BottomAppBar(
          color: palette.backgroundMain,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                color: palette.mtYellow,
                tooltip: 'Profile',
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
              IconButton(
                color: palette.mtYellow,
                tooltip: 'Friends',
                icon: const Icon(Icons.groups),
                onPressed: () {},
              ),
              Container(
                color: palette.mtYellow,
                padding: const EdgeInsets.only(left:16, bottom: 0, right: 16, top:0),
                child: IconButton(
                  color: palette.mtGreen1,
                  tooltip: 'Favorite',
                  icon: const Icon(Icons.play_circle_fill_outlined),
                  onPressed: () {},
                ),
              ),
              IconButton(
                color: palette.mtYellow,
                tooltip: 'Host Game',
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
              IconButton(
                color: palette.mtYellow,
                tooltip: 'Coin Shop',
                icon: const Icon(Icons.storefront),
                onPressed: () {},
              ),
            ],
          ),
        );
  }
}