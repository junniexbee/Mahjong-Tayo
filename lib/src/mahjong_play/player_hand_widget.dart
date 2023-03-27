// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_internals/mahjong_play_state.dart';
import '../style/palette.dart';
import 'mahjong_helpers.dart';


class DisplayHand extends StatelessWidget {
  final MahjongPlayState mahjongPlayState;
  final int playerNum;

  const DisplayHand(
      {super.key, required this.mahjongPlayState, required this.playerNum});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    List<Widget> handTiles = List.empty(growable: true);
    List<MtTile> playerHand = mahjongPlayState.mtHands[playerNum]!.hand;

    for (MtTile tile in playerHand) {
      handTiles.add(Flexible(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 80.0,
          ),
          child: GestureDetector(
            onTap: () => print("Tile ${tile.number} of ${tile.suit} was tapped"),
            onVerticalDragEnd: (details) {
              print("Tile ${tile.number} of ${tile.suit} was dragged");
              mahjongPlayState.throwTile(tile, playerHand);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 8.0,
              margin: EdgeInsets.all(1),
              child: tile.imagePointer,
            ),
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IgnorePointer(
        ignoring: mahjongPlayState.ignoreHandPointers[playerNum]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: handTiles,
        ),
      ),
    );
  }
}

class DisplaySmall extends StatelessWidget {
  final MahjongPlayState mahjongPlayState;
  final int playerNum;

  const DisplaySmall({
    super.key,
    required this.mahjongPlayState,
    required this.playerNum,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> handTiles = List.empty(growable: true);

    for (MtTile tile in mahjongPlayState.mtHands[playerNum]!.flowers) {
      handTiles.add(SizedBox(
        height: 24,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(1),
          child: tile.imagePointer,
        ),
      ));
    }

    for (MtTile tile in mahjongPlayState.mtHands[playerNum]!.faceUp) {
      handTiles.add(SizedBox(
        height: 24,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(1),
          child: tile.imagePointer,
        ),
      ));
    }

    for (MtTile tile in mahjongPlayState.mtHands[playerNum]!.secret) {
      handTiles.add(SizedBox(
        height: 24,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(1),
          child: Image.asset('assets/images/Tiles/face_down.png'),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        runSpacing: 4.0,
        children: handTiles,
      ),
    );
  }
}

class DisplayDiscarded extends StatelessWidget {
  final List<MtTile> discarded;

  const DisplayDiscarded({
    super.key,
    required this.discarded,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> handTiles = List.empty(growable: true);

    for (MtTile tile in discarded) {
      handTiles.add(SizedBox(
        height: 24,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(1),
          child: tile.imagePointer,
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        runSpacing: 4.0,
        children: handTiles,
      ),
    );
  }
}

class DisplayUpForGrabs extends StatelessWidget {
  final MtTile upForGrabs;

  const DisplayUpForGrabs({
    super.key,
    required this.upForGrabs,
  });

  @override
  Widget build(BuildContext context) {
    return Center();
  }
}

class DisplayPlayerCommands extends StatelessWidget {
  final int playerNum;
  final MahjongPlayState mahjongPlayState;

  const DisplayPlayerCommands(
      {super.key, required this.playerNum, required this.mahjongPlayState});

  @override
  Widget build(BuildContext context) {
    final Widget commands;

    if ((mahjongPlayState.upForGrabs.id == 0) &&
        (playerNum == mahjongPlayState.playerTurn)) {
      Row playActions = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ElevatedButton(
              onPressed: () {
                mahjongPlayState.secret(playerNum);
              }, child: const Text('Secret!')),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ElevatedButton(
              onPressed: () {
                mahjongPlayState.checkMahjong(playerNum);
                print("Checked for Mahjong");
              }, child: const Text('Mahjong!')),
        )
      ]);
      commands = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Text(
                    "${mahjongPlayState.playerMap[mahjongPlayState.playerTurn]!.username}, Discard a tile or declare!")),
            playActions,
          ]);
      if (mahjongPlayState.kangSecret == true){
        playActions.children.add(Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              onPressed: () {
                mahjongPlayState.drawTile();
              },
              child: const Text('Draw')),
        ));
        playActions.children.removeAt(0);
      }
    } else if (mahjongPlayState.upForGrabs.id != 0) {
      Row playActions = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: ElevatedButton(
                onPressed: () {
                  mahjongPlayState.pong(playerNum);
                },
                child: const Text('Pong')),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: ElevatedButton(
                onPressed: () {
                  mahjongPlayState.kang(playerNum);
                },
                child: const Text('Kang')),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child:
                ElevatedButton(onPressed: () {
                  mahjongPlayState.checkMahjong(playerNum);
                }, child: const Text('Mahjong')),
          ),
        ],
      );

      if (playerNum == mahjongPlayState.playerTurn) {
        playActions.children.insert(
            0,
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: ElevatedButton(
                  onPressed: () {
                    mahjongPlayState.chow(playerNum);
                  },
                  child: const Text('Chow')),
            ));
        playActions.children.add(Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              onPressed: () {
                mahjongPlayState.drawTile();
              },
              child: const Text('Draw')),
        ));
      } else {
        playActions.children.insert(
            0,
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child:
                  ElevatedButton(onPressed: () {
                  }, child: const Text('Wait')),
            ));
      }

      commands = playActions;
    } else {
      print("pID: $playerNum, Up for Grabs: ${mahjongPlayState.upForGrabs.id}, Turn: ${mahjongPlayState.playerTurn}");
      commands = SizedBox(height: 16);
    }

    return commands;
  }
}
