// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:mahjong_tayo/src/mahjong_play/player_hand_widget.dart';
import 'package:provider/provider.dart';

import '../ads/ads_controller.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/mahjong_play_state.dart';
import '../games_services/games_services.dart';
import '../games_services/score.dart';
import '../in_app_purchase/in_app_purchase.dart';
import '../player_progress/player_progress.dart';
import '../style/confetti.dart';
import 'mahjong_helpers.dart';

class MahjongPlayScreen extends StatefulWidget {
  final int manoPlayer;
  final int players = 4;
  final List<MtTile> deck;
  final Map<int, MtHand> hands;

  const MahjongPlayScreen({
    super.key,
    required this.manoPlayer,
    required this.deck,
    required this.hands,
  });

  @override
  State<MahjongPlayScreen> createState() => _MahjongPlayScreenState();
}

class _MahjongPlayScreenState extends State<MahjongPlayScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;
  late int _playerTurn;

  late MahjongPlayState myMahjongPlayState;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => myMahjongPlayState),
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
                SingleChildScrollView(
                  // This is the entirety of the "game".
                  child: Consumer<MahjongPlayState>(
                    builder: (context, myMahjongPlayState, child) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Let's get ready to play! \nMahjong Tayo!",
                            style: TextStyle(
                                fontFamily: 'Permanent Marker', fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        DisplayDiscarded(
                            discarded: myMahjongPlayState.discardPile),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Column(
                                  children: [
                                const Text("TayoCoins:"),
                                Text(
                                    "${myMahjongPlayState.playerMap[1]!.username} - ${myMahjongPlayState.playerMap[1]!.tayoCoins}"),
                                Text(
                                    "${myMahjongPlayState.playerMap[2]!.username} - ${myMahjongPlayState.playerMap[2]!.tayoCoins}"),
                                Text(
                                    "${myMahjongPlayState.playerMap[3]!.username} - ${myMahjongPlayState.playerMap[3]!.tayoCoins}"),
                                Text(
                                    "${myMahjongPlayState.playerMap[0]!.username} - ${myMahjongPlayState.playerMap[0]!.tayoCoins}"),
                              ]),
                            ),
                            Flexible(
                              flex: 6,
                              child: Column(children: [
                                Center(
                                    child: SizedBox(
                                      height: 80,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        elevation: 5,
                                        margin: EdgeInsets.all(1),
                                        child: myMahjongPlayState.upForGrabs.imagePointer,
                                      ),
                                    )),
                              ]),
                            ),
                          ],
                        ),
                        DisplayPlayerCommands(
                            mahjongPlayState: myMahjongPlayState, playerNum: 1),
                        Center(
                          child: DisplayHand(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 1),
                        ),
                        Center(
                          child: DisplaySmall(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 1),
                        ),
                        DisplayPlayerCommands(
                            mahjongPlayState: myMahjongPlayState, playerNum: 2),
                        Center(
                          child: DisplayHand(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 2),
                        ),
                        Center(
                          child: DisplaySmall(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 2),
                        ),
                        DisplayPlayerCommands(
                            mahjongPlayState: myMahjongPlayState, playerNum: 3),
                        Center(
                          child: DisplayHand(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 3),
                        ),
                        Center(
                          child: DisplaySmall(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 3),
                        ),
                        DisplayPlayerCommands(
                            mahjongPlayState: myMahjongPlayState, playerNum: 0),
                        Center(
                          child: DisplayHand(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 0),
                        ),
                        Center(
                          child: DisplaySmall(
                              mahjongPlayState: myMahjongPlayState,
                              playerNum: 0),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).go('/play');
                          },
                          child: const Text('Continue'),
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

    _startOfPlay = DateTime.now();
    _playerTurn = widget.manoPlayer;
    if (_playerTurn == 4) _playerTurn = 0;

    myMahjongPlayState = MahjongPlayState(
      goal: 13,
      deck: widget.deck,
      playerTurn: widget.manoPlayer,
      mtHands: widget.hands,
      onWin: _playerWon,
      context: context
    );

    myMahjongPlayState.ignoreHandPointers[_playerTurn] = false;

    // Preload ad for the win screen.
    final adsRemoved =
        context.read<InAppPurchaseController?>()?.adRemoval.active ?? false;
    if (!adsRemoved) {
      final adsController = context.read<AdsController?>();
      adsController?.preloadAd();
    }


    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkFlowers());
  }

  void checkFlowers(){
    myMahjongPlayState.checkFlowers(1);
    myMahjongPlayState.checkFlowers(2);
    myMahjongPlayState.checkFlowers(3);
    myMahjongPlayState.checkFlowers(0);
  }

  Future<void> _playerWon() async {
    _log.info('Mahjong Game won');

    final score = Score(
      3,
      10,
      DateTime.now().difference(_startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(3);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    final gamesServicesController = context.read<GamesServicesController?>();
    if (gamesServicesController != null) {
      // Award achievement.
      // if (widget.level.awardsAchievement) {
      //   await gamesServicesController.awardAchievement(
      //     android: widget.level.achievementIdAndroid!,
      //     iOS: widget.level.achievementIdIOS!,
      //   );
      // }

      // Send score to leaderboard.
      await gamesServicesController.submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    //GoRouter.of(context).go('/play/mahjongPlay', extra: {'manoPlayer': manoPlayer, 'deck': deck, 'hands': hands});
    GoRouter.of(context).go('/play/mahjongWin', extra: {
      'winner':
          myMahjongPlayState.playerMap[myMahjongPlayState.playerTurn]!.username,
      'playerNum': myMahjongPlayState.playerTurn,
      'winningAmbitions': myMahjongPlayState.winningAmbitions
    });
  }
}
