// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/mano_state.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../level_selection/levels.dart';
import '../mahjong_play/mahjong_helpers.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';

class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  int leftDiceNumber = 0;
  int rightDiceNumber = 0;
  int diceSum = 0;

  int playerTurn = 1;
  int players = 4;
  Map<int, int> manoScores = {};
  Map<int, int> playerMap = {1: 1, 2: 2, 3: 3, 0: 4};
  Iterable manoKeys = [];

  int highestDiceSum = 0;

  String playInstructions = "";

  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;


  void rollDice() {
    leftDiceNumber = Random().nextInt(6) + 1;
    rightDiceNumber = Random().nextInt(6) + 1;
    diceSum = leftDiceNumber + rightDiceNumber;

    if (diceSum > highestDiceSum) {
      manoScores.clear();
      manoScores[playerMap[playerTurn] ?? players] = diceSum;
      highestDiceSum = diceSum;
      playInstructions =
          "Player ${playerMap[playerTurn]} rolled a $diceSum and is up for Mano!";
    } else if (diceSum == highestDiceSum) {
      int player = playerMap[playerTurn] ?? 1; // nullable statement
      manoScores[player] = diceSum;
      highestDiceSum = diceSum;
      playInstructions =
          "Player ${playerMap[playerTurn]} rolled a $diceSum and is tied for Mano!";
    } else {
      playInstructions =
          "Player ${playerMap[playerTurn]} rolled a $diceSum and is out, sorry!";
    }

    if (playerTurn == 0) {
      //End of Round
      if (manoScores.length == 1) {
        //we have a Mano
        playInstructions += "\n" "Player ${manoScores.keys.first} is Mano!!!!!";
        diceSum = 13; //End Game
      } else {
        // remaining players compete for mano
        players = manoScores.length;
        playerMap.clear();
        playInstructions +=
            "\n" "$players players tied for Mano, We gotta go again...";
        for (var key in manoScores.keys) {
          playerTurn += 1;
          playerTurn = playerTurn % players;
          playerMap[playerTurn] = key;
        }
        playerTurn = 0;
        manoScores.clear();
      }
      highestDiceSum = 0;
      playerTurn += 1;
      playerTurn = playerTurn % players;
      playInstructions +=
      "\n" "Player ${playerMap[playerTurn]}, please roll the dice.";
    } else {
      // Keep going
      playerTurn += 1;
      playerTurn = playerTurn % players;
      playInstructions +=
          "\n" "Player ${playerMap[playerTurn]}, please roll the dice.";
    }
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ManoState(
            goal: 13,
            onWin: _playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/green-slate.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  // This is the entirety of the "game".
                  child: Consumer<ManoState>(
                    builder: (context, manoState, child) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkResponse(
                            onTap: () => GoRouter.of(context).push('/settings'),
                            child: Image.asset(
                              'assets/images/settings.png',
                              semanticLabel: 'Settings',
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(playInstructions, textAlign: TextAlign.center),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8),
                            child: Row(children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: InkResponse(
                                    onTap: () {
                                      rollDice();
                                      manoState.setAndCheck(diceSum);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                          'assets/images/Dice/Dice$leftDiceNumber.png'),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkResponse(
                                    onTap: () {
                                      rollDice();
                                      manoState.setAndCheck(diceSum);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                          'assets/images/Dice/Dice$rightDiceNumber.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => GoRouter.of(context).go('/play'),
                              child: const Text('Back'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox.expand(
                  child: Visibility(
                    visible: _duringCelebration,
                    child: IgnorePointer(
                      child: Confetti(
                        isStopped: !_duringCelebration,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    playInstructions = "Player ${playerMap[playerTurn]}, Roll the dice!";

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    _log.info('Level ${widget.level.number} won');
    final int manoPlayer = manoScores.keys.first;

    // Shuffle Tiles & Deal hands
    final deck = getDeck();
    final Map<int,MtHand> hands = getHands(deck,manoPlayer);



    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/mahjongPlay', extra: {'manoPlayer': manoPlayer, 'deck': deck, 'hands': hands});
  }
}
