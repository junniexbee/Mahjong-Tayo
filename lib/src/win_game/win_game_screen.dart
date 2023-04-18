// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../ads/banner_ad_widget.dart';
import '../game_internals/player_profile.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  // final Score score;
  final String winner;
  int playerNum;
  final Map<String, bool> winningAmbitions;
  final int winnings;

  WinGameScreen(
      {super.key, required this.winner, required this.playerNum, required this.winningAmbitions, required this.winnings});

  @override
  Widget build(BuildContext context) {
    final adsControllerAvailable = context.watch<AdsController?>() != null;
    final adsRemoved =
        context.watch<InAppPurchaseController?>()?.adRemoval.active ?? false;
    final palette = context.watch<Palette>();
    int playerIndex;

    const gap = SizedBox(height: 10);
    String ambitionsText = '';

    print(winningAmbitions);

    if (playerNum == 0){
      playerNum = 4;
      playerIndex = 3;
    } else{
      playerIndex = playerNum - 1;
    }

    if (winningAmbitions['bunot'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "Bunot";
    }
    if (winningAmbitions['7pairs'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "7 Pairs";
    }
    if (winningAmbitions['escalera'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "Escalera";
    }
    if (winningAmbitions['allChow'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "All Chow";
    }
    if (winningAmbitions['allPong'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "All Pong";
    }
    if (winningAmbitions['allUp'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "All Up";
    }
    if (winningAmbitions['fullFlush'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "Full Flush";
    }
    if (winningAmbitions['single'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "Single";
    }
    if (winningAmbitions['edge'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "Edge";
    }
    if (winningAmbitions['wedge'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "Wedge";
    }
    if (winningAmbitions['backToBack'] == true){
      if (ambitionsText != ''){
        ambitionsText += ' | ';
      }
      ambitionsText += "backToBack";
    }

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (adsControllerAvailable && !adsRemoved) ...[
            const Expanded(
              child: Center(
                child: BannerAdWidget(),
              ),
            ),
          ],
          gap,
          Center(
            child: Text(
              '$winner #$playerNum, you won!',
              style: TextStyle(fontFamily: 'Permanent Marker', color: palette.mtGreen1, fontSize: 50),
            ),
          ),
          if (ambitionsText != '') ...[
            Center(
              child: Text(ambitionsText,
                style: TextStyle(fontFamily: 'Permanent Marker', color: palette.mtGreen1, fontSize: 50),
              ),
            ),
          ],
          gap,
          Center(
            child: Text(
              // 'Score: ${score.score}\n'
              'Winnings: $winnings'
              '\nTayoCoins: ${players.elementAt(playerIndex)!.tayoCoins}',
              style:
                  TextStyle(fontFamily: 'Permanent Marker', color: palette.mtGreen1, fontSize: 20),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/play');
              },
              child: const Text('Play Again!'),
            ),
          )
        ],
      ),
    );
  }
}
