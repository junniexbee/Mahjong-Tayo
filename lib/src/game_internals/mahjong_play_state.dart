// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import '../game_internals/player_profile.dart';
import '../mahjong_play/mahjong_helpers.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class MahjongPlayState extends ChangeNotifier {
  final VoidCallback onWin;
  final int goal;
  final BuildContext context;
  List<MtTile> deck;
  List<MtTile> discardPile = List.empty(growable: true);
  Map<int, MtHand> mtHands;
  int playerTurn;
  MtTile upForGrabs = MtTile.empty();
  MtTile lastDrawn = MtTile.empty();
  bool kangSecret = false;
  MtPayoutStyle payout = payouts[0];
  Map<int, bool> ignoreHandPointers = {1: true, 2: true, 3: true, 0: true};
  Map<int, PlayerProfile> playerMap = {
    1: players[0],
    2: players[1],
    3: players[2],
    0: players[3]
  };
  final Map<String, bool> winningAmbitions = {'bunot': false, "7pairs": false, "escalera": false, "allPong": false, 'allChow': false, "fullFlush": false,
    'single': false, 'edge': false, 'wedge': false, 'backToBack': false, 'allUp': false};




  MahjongPlayState(
      {required this.onWin,
      required this.deck,
      this.goal = 100,
      required this.mtHands,
      required this.playerTurn,
      required this.context});

  int checkPairsFirst(List<MtTile> checkList) {
    int pairs = 0;
    List<MtTile> removeList = List.empty(growable: true);

    while ((checkList.length > 1) && (checkList.length % 2 == 0)){
      MtTile tileCheck = checkList.first;
      int pairCount = 0;

      for (MtTile tile in checkList){
        if ((tile.number == tileCheck.number) && (pairCount < 3)){
          pairCount += 1;
          removeList.add(tile);
        }
      }

      if (pairCount == 2){
        pairs += 1;
        for (MtTile tile in removeList){
          checkList.remove(tile);
        }
      } else{
        checkList.remove(tileCheck);
      }
      removeList.clear();
    }

    while ((checkList.length > 1) && (checkList.length % 3 == 2)){
      MtTile tileCheck = checkList.first;
      int pairCount = 0;

      for (MtTile tile in checkList){
        if ((tile.number == tileCheck.number) && (pairCount < 3)){
          pairCount += 1;
          removeList.add(tile);

        }
      }

      if (pairCount == 2){
        pairs += 1;
        for (MtTile tile in removeList){
          checkList.remove(tile);
        }
      } else{
        checkList.remove(tileCheck);
      }
      removeList.clear();
    }

    return pairs;
  }

  Map<String, dynamic> checkForSets(List<MtTile> checkList, int direction){
    int sets = 0;
    int pairs = 0;
    int chows = 0;
    int pongs = 0;
    List<MtTile> removeChow = List.empty(growable: true);
    List<MtTile> removePong = List.empty(growable: true);
    Map<String, bool> checkAmbitions = {'fullFlush': false, 'bunot': false, 'single': false, 'edge': false, 'wedge': false, 'backToBack': false};


    while (checkList.length > 2){
      MtTile tileCheck = checkList.first;
      int chowCount = 0;
      int pongCount = 0;

      int chowDiff1;
      int chowDiff2;

      if (direction == 0){
        chowDiff1 = tileCheck.number + 1;
        chowDiff2 = tileCheck.number + 2;
      } else{
        chowDiff1 = tileCheck.number - 1;
        chowDiff2 = tileCheck.number - 2;
      }

      for (MtTile tile in checkList){

        if ((chowCount == 0) && (tile.number == tileCheck.number)){
          chowCount += 1;
          removeChow.add(tile);
        } else if ((chowCount == 1) && (tile.number == chowDiff1)){
          chowCount += 1;
          removeChow.add(tile);
        } else if ((chowCount == 2) && (tile.number == chowDiff2)){
          chowCount += 1;
          removeChow.add(tile);
        }
      }

      removeChow.sort((a, b) => a.number.compareTo(b.number));

      if (chowCount == 3){
        sets += 1;
        chows += 1;

        if (((removeChow.elementAt(2).number == lastDrawn.number) && (removeChow.elementAt(2).suit == lastDrawn.suit) && (removeChow.elementAt(2).number == 3))
            || ((removeChow.elementAt(2).number == upForGrabs.number) && (removeChow.elementAt(2).suit == upForGrabs.suit) && removeChow.elementAt(2).number == 3)
            || ((removeChow.first.number == lastDrawn.number) && (removeChow.first.suit == lastDrawn.suit) && (removeChow.first.number == 7))
            || ((removeChow.first.number == upForGrabs.number) && (removeChow.first.suit == upForGrabs.suit) && removeChow.first.number == 7)){
          checkAmbitions['edge'] = true;
        } else if (((removeChow.elementAt(1).number == lastDrawn.number) && (removeChow.elementAt(1).suit == lastDrawn.suit))
            || ((removeChow.elementAt(1).number == upForGrabs.number) && (removeChow.elementAt(1).suit == upForGrabs.suit))) {
          checkAmbitions['wedge'] = true;
        }

        for (MtTile tile in removeChow){
          checkList.remove(tile);
        }
        removeChow.clear();

      }

      for (MtTile tile in checkList){
        if ((tile.number == tileCheck.number) && (pongCount < 4)){
          pongCount += 1;
          removePong.add(tile);
        }
      }


      if (pongCount == 3){
        sets += 1;
        pongs += 1;

        print('check back to back: ${removePong.first.number} of ${removePong.first.suit}');
        if (((removePong.first.number == lastDrawn.number) && (removePong.first.suit == lastDrawn.suit))
            || ((removePong.first.number == upForGrabs.number) && (removePong.first.suit == upForGrabs.suit))){
          checkAmbitions['backToBack'] = true;
          print('back to back found: ${removePong.first.number} of ${removePong.first.suit}');
        }
        for (MtTile tile in removePong){
          checkList.remove(tile);
        }
        removePong.clear();

      } else { // check for pair
        checkList.remove(tileCheck);
        int i = 0;
        while((pairs == 0) && (i < checkList.length)){
          if (checkList.elementAt(i).number == tileCheck.number){
            pairs += 1;
            checkList.removeAt(i);
          }
          i++;
        }
      }
    }

    if (checkList.length == 2){ // check for pair if only 2 tiles left to check
      if (checkList.elementAt(0).number == checkList.elementAt(1).number){
        pairs += 1;
        if (checkList.elementAt(0) == upForGrabs || checkList.elementAt(1) == upForGrabs){
          checkAmbitions['single'] = true;
        }
        if (checkList.elementAt(0) == lastDrawn || checkList.elementAt(1) == lastDrawn){
          checkAmbitions['bunot'] = true;
          checkAmbitions['single'] = true;
        }
      }
      checkList.removeLast();
      checkList.removeLast();
    }

    if (sets == 5 && pairs == 1){
      checkAmbitions['fullFlush'] = true;
    }
    return {"sets": sets, "pairs": pairs, "chows": chows, "pongs": pongs,
      "fullFlush": checkAmbitions['fullFlush'], "bunot": checkAmbitions['bunot'], "single": checkAmbitions['single'],
      'edge': checkAmbitions['edge'], 'wedge': checkAmbitions['wedge'], 'backToBack': checkAmbitions['backToBack']};
  }

  void checkMahjong(int playerNum) {
    print("checking Mahjong!");
    print(mtHands[playerNum]!.sets);
    List<MtTile> balls = List.empty(growable: true);
    List<MtTile> chars = List.empty(growable: true);
    List<MtTile> sticks = List.empty(growable: true);
    List<MtTile> ballsRev = List.empty(growable: true);
    List<MtTile> charsRev = List.empty(growable: true);
    List<MtTile> sticksRev = List.empty(growable: true);
    const up = 0;
    const down = 1;
    Map<String, dynamic> checkMap;
    Map<String, int> checkUpDown = {"sets": 0, "pairs": 0, "setsUp": 0, "setsDown": 0, "pairsUp": 0, "pairsDown": 0, "chowsUp": 0, "chowsDown": 0, "pongsUp": 0, "pongsDown": 0};
    final Map<String, dynamic> checkFinal = {"sets": mtHands[playerNum]!.sets, "pairs": mtHands[playerNum]!.pairs, "chows": mtHands[playerNum]!.chows, "pongs": mtHands[playerNum]!.pongs};
    final Map<String, bool> allAmbitions = {'bunot': false, "7pairs": false, "escalera": false, "allPong": false, 'allChow': false, "fullFlush": false,
      'single': false, 'edge': false, 'wedge': false, 'backToBack': false, 'allUp': false};
    Map<String, List<bool>> checkAmbitions = {"fullFlushUp": List.empty(growable: true), "fullFlushDown": List.empty(growable: true),
      "singleUp": List.empty(growable: true), "singleDown": List.empty(growable: true),
      "bunotUp": List.empty(growable: true), "bunotDown": List.empty(growable: true),
      "edgeUp": List.empty(growable: true), "edgeDown": List.empty(growable: true),
      "wedgeUp": List.empty(growable: true), "wedgeDown": List.empty(growable: true),
      "backToBackUp": List.empty(growable: true), "backToBackDown": List.empty(growable: true),
      'escalera': List.empty(growable: true,)
    };
    String boolString;
    bool checkBool;
    //TODO Edge, Wedge, Back to Back
    //TODO Check bisaklat, before the fifth

    mtHands[playerNum]!.sort();

    for (MtTile tile in mtHands[playerNum]!.hand) {
      if (tile.id < 37) {
        balls.add(tile);
      } else if (tile.id > 36 && tile.id < 73) {
        chars.add(tile);
      } else {
        sticks.add(tile);
      }
    }

    if (upForGrabs.id < 37) {
      balls.add(upForGrabs);
      balls.sort((a, b) => a.number.compareTo(b.number));
    } else if (upForGrabs.id > 36 && upForGrabs.id < 73) {
      chars.add(upForGrabs);
      chars.sort((a, b) => a.number.compareTo(b.number));
    } else if (upForGrabs.id != 0){
      sticks.add(upForGrabs);
      sticks.sort((a, b) => a.number.compareTo(b.number));
    }

    //TODO can mahjong have undeclared secret?

    //check sets in suits... if divisible by 3 check for sets
    //else has pair

    ballsRev.addAll(balls.reversed);
    charsRev.addAll(chars.reversed);
    sticksRev.addAll(sticks.reversed);

    if (mtHands[playerNum]!.goingFor7Pairs == false){
      //check forwards
      checkMap = checkForSets(balls, up);
      checkUpDown.update("pairsUp", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkUpDown.update("setsUp", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkUpDown.update("chowsUp", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkUpDown.update("pongsUp", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      boolString = checkMap['bunot']!.toString(); //check bunot
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["bunotUp"]!.add(checkBool);
      boolString = checkMap['single']!.toString(); //check single
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["singleUp"]!.add(checkBool);
      if (checkUpDown["setsUp"]! == 5){
        checkAmbitions["fullFlushUp"]!.add(true);
      } else {
        checkAmbitions["fullFlushUp"]!.add(false);
      }
      boolString = checkMap['edge']!.toString(); //check edge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["edgeUp"]!.add(checkBool);
      boolString = checkMap['wedge']!.toString(); //check wedge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["wedgeUp"]!.add(checkBool);
      boolString = checkMap['backToBack']!.toString(); //check backToBack
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["backToBackUp"]!.add(checkBool);
      checkMap = checkForSets(chars, up);
      checkUpDown.update("pairsUp", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkUpDown.update("setsUp", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkUpDown.update("chowsUp", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkUpDown.update("pongsUp", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      boolString = checkMap['bunot']!.toString(); //check bunot
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["bunotUp"]!.add(checkBool);
      boolString = checkMap['single']!.toString(); //check single
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["singleUp"]!.add(checkBool);
      if (checkUpDown["setsUp"]! == 5){ // checkFullFlush
        checkAmbitions["fullFlushUp"]!.add(true);
      } else {
        checkAmbitions["fullFlushUp"]!.add(false);
      }
      boolString = checkMap['edge']!.toString(); //check edge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["edgeUp"]!.add(checkBool);
      boolString = checkMap['wedge']!.toString(); //check wedge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["wedgeUp"]!.add(checkBool);
      boolString = checkMap['backToBack']!.toString(); //check backToBack
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["backToBackUp"]!.add(checkBool);
      print('${sticks.length} sticks length');
      checkMap = checkForSets(sticks, up);
      checkUpDown.update("pairsUp", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkUpDown.update("setsUp", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkUpDown.update("chowsUp", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkUpDown.update("pongsUp", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      boolString = checkMap['bunot']!.toString(); //check bunot
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["bunotUp"]!.add(checkBool);
      boolString = checkMap['single']!.toString(); //check single
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["singleUp"]!.add(checkBool);
      if (checkUpDown["setsUp"]! == 5){
        checkAmbitions["fullFlushUp"]!.add(true);
      } else {
        checkAmbitions["fullFlushUp"]!.add(false);
      }
      boolString = checkMap['edge']!.toString(); //check edge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["edgeUp"]!.add(checkBool);
      boolString = checkMap['wedge']!.toString(); //check wedge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["wedgeUp"]!.add(checkBool);
      boolString = checkMap['backToBack']!.toString(); //check backToBack
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["backToBackUp"]!.add(checkBool);

      //check backwards
      checkMap = checkForSets(ballsRev, down);
      checkUpDown.update("pairsDown", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkUpDown.update("setsDown", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkUpDown.update("chowsDown", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkUpDown.update("pongsDown", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      boolString = checkMap['bunot']!.toString(); //check bunot
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["bunotDown"]!.add(checkBool);
      boolString = checkMap['single']!.toString(); //check single
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["singleDown"]!.add(checkBool);
      if (checkUpDown["setsUp"]! == 5){ //check fullFlush
        checkAmbitions["fullFlushDown"]!.add(true);
      } else {
        checkAmbitions["fullFlushDown"]!.add(false);
      }
      boolString = checkMap['edge']!.toString(); //check edge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["edgeDown"]!.add(checkBool);
      boolString = checkMap['wedge']!.toString(); //check wedge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["wedgeDown"]!.add(checkBool);
      boolString = checkMap['backToBack']!.toString(); //check backToBack
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["backToBackDown"]!.add(checkBool);
      checkMap = checkForSets(charsRev, down);
      checkUpDown.update("pairsDown", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkUpDown.update("setsDown", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkUpDown.update("chowsDown", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkUpDown.update("pongsDown", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      boolString = checkMap['bunot']!.toString(); //check bunot
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["bunotDown"]!.add(checkBool);
      boolString = checkMap['single']!.toString(); //check single
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["singleDown"]!.add(checkBool);
      if (checkUpDown["setsUp"]! == 5){
        checkAmbitions["fullFlushDown"]!.add(true);
      } else {
        checkAmbitions["fullFlushDown"]!.add(false);
      }
      boolString = checkMap['edge']!.toString(); //check edge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["edgeDown"]!.add(checkBool);
      boolString = checkMap['wedge']!.toString(); //check wedge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["wedgeDown"]!.add(checkBool);
      boolString = checkMap['backToBack']!.toString(); //check backToBack
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["backToBackDown"]!.add(checkBool);
      checkMap= checkForSets(sticksRev, down);
      checkUpDown.update("pairsDown", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkUpDown.update("setsDown", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkUpDown.update("chowsDown", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkUpDown.update("pongsDown", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      boolString = checkMap['bunot']!.toString(); //check bunot
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["bunotDown"]!.add(checkBool);
      boolString = checkMap['single']!.toString(); //check single
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["singleDown"]!.add(checkBool);
      if (checkUpDown["setsUp"]! == 5){
        checkAmbitions["fullFlushDown"]!.add(true);
      } else {
        checkAmbitions["fullFlushDown"]!.add(false);
      }
      boolString = checkMap['edge']!.toString(); //check edge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["edgeDown"]!.add(checkBool);
      boolString = checkMap['wedge']!.toString(); //check wedge
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["wedgeDown"]!.add(checkBool);
      boolString = checkMap['backToBack']!.toString(); //check backToBack
      if (boolString == 'false') {
        checkBool = false;
      } else {
        checkBool = true;
      }
      checkAmbitions["backToBackDown"]!.add(checkBool);

      if(checkUpDown["setsUp"]! >= checkUpDown["setsDown"]!){
        checkFinal.update("pairs", (value) => value + checkUpDown["pairsUp"]!);
        checkFinal.update("sets", (value) => value + checkUpDown["setsUp"]!);
        checkFinal.update("chows", (value) => value + checkUpDown["chowsUp"]!);
        checkFinal.update("pongs", (value) => value + checkUpDown["pongsUp"]!);

        if (checkAmbitions["fullFlushUp"]!.elementAt(0) == true || checkAmbitions["fullFlushUp"]!.elementAt(1) == true || checkAmbitions["fullFlushUp"]!.elementAt(2) == true){
          allAmbitions.update("fullFlush", (value) => true);
        }
        if (checkAmbitions["singleUp"]!.elementAt(0) == true || checkAmbitions["singleUp"]!.elementAt(1) == true || checkAmbitions["singleUp"]!.elementAt(2) == true){
          allAmbitions.update("single", (value) => true);
        }
        if (checkAmbitions["bunotUp"]!.elementAt(0) == true || checkAmbitions["bunotUp"]!.elementAt(1) == true || checkAmbitions["bunotUp"]!.elementAt(2) == true){
          allAmbitions.update("bunot", (value) => true);
        }
        if (checkAmbitions["edgeUp"]!.elementAt(0) == true || checkAmbitions["edgeUp"]!.elementAt(1) == true || checkAmbitions["edgeUp"]!.elementAt(2) == true){
          allAmbitions.update("edge", (value) => true);
        }
        if (checkAmbitions["wedgeUp"]!.elementAt(0) == true || checkAmbitions["wedgeUp"]!.elementAt(1) == true || checkAmbitions["wedgeUp"]!.elementAt(2) == true){
          allAmbitions.update("wedge", (value) => true);
        }
        if (checkAmbitions["backToBackUp"]!.elementAt(0) == true || checkAmbitions["backToBackUp"]!.elementAt(1) == true || checkAmbitions["backToBackUp"]!.elementAt(2) == true){
          allAmbitions.update("backToBack", (value) => true);
        }

      } else{
        checkFinal.update("pairs", (value) => value + checkUpDown["pairsDown"]!);
        checkFinal.update("sets", (value) => value + checkUpDown["setsDown"]!);
        checkFinal.update("chows", (value) => value + checkUpDown["chowsDown"]!);
        checkFinal.update("pongs", (value) => value + checkUpDown["pongsDown"]!);
        if (checkAmbitions["fullFlushDown"]!.elementAt(0) == true || checkAmbitions["fullFlushDown"]!.elementAt(1) == true || checkAmbitions["fullFlushDown"]!.elementAt(2) == true){
          allAmbitions.update("fullFlush", (value) => true);
        }
        if (checkAmbitions["singleDown"]!.elementAt(0) == true || checkAmbitions["singleDown"]!.elementAt(1) == true || checkAmbitions["singleDown"]!.elementAt(2) == true){
          allAmbitions.update("single", (value) => true);
        }
        if (checkAmbitions["bunotDown"]!.elementAt(0) == true || checkAmbitions["bunotDown"]!.elementAt(1) == true || checkAmbitions["bunotDown"]!.elementAt(2) == true){
          allAmbitions.update("bunot", (value) => true);
        }
        if (checkAmbitions["edgeDown"]!.elementAt(0) == true || checkAmbitions["edgeDown"]!.elementAt(1) == true || checkAmbitions["edgeDown"]!.elementAt(2) == true){
          allAmbitions.update("edge", (value) => true);
        }
        if (checkAmbitions["wedgeDown"]!.elementAt(0) == true || checkAmbitions["wedgeDown"]!.elementAt(1) == true || checkAmbitions["wedgeDown"]!.elementAt(2) == true){
          allAmbitions.update("wedge", (value) => true);
        }
        if (checkAmbitions["backToBackDown"]!.elementAt(0) == true || checkAmbitions["backToBackDown"]!.elementAt(1) == true || checkAmbitions["backToBackDown"]!.elementAt(2) == true){
          allAmbitions.update("backToBack", (value) => true);
        }
      }

    } else { //TODO check 7 pairs bunot, single,
      print("checking for 7 pairs");
      checkFinal.update("pairs", (value) => value + checkPairsFirst(balls));
      checkMap = checkForSets(balls, up);
      checkFinal.update("sets", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkFinal.update("chows", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkFinal.update("pongs", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkFinal.update("pairs", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      if (checkFinal["pairs"] == 7 && checkFinal["sets"] == 1){
        checkAmbitions["fullFlushUp"]!.add(true);
      } else {
        checkAmbitions["fullFlushUp"]!.add(false);
      }

      checkFinal.update("pairs", (value) => value + checkPairsFirst(chars));
      checkMap = checkForSets(chars, up);
      checkFinal.update("sets", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkFinal.update("chows", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkFinal.update("pongs", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkFinal.update("pairs", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      if (checkFinal["pairs"] == 7 && checkFinal["sets"] == 1){
        checkAmbitions["fullFlushUp"]!.add(true);
      } else {
        checkAmbitions["fullFlushUp"]!.add(false);
      }

      checkFinal.update("pairs", (value) => value + checkPairsFirst(sticks));
      checkMap = checkForSets(sticks, up);
      checkFinal.update("sets", (value) => value.toInt() + int.parse(checkMap["pairs"]!.toString()));
      checkFinal.update("chows", (value) => value.toInt() + int.parse(checkMap["sets"]!.toString()));
      checkFinal.update("pongs", (value) => value.toInt() + int.parse(checkMap["chows"]!.toString()));
      checkFinal.update("pairs", (value) => value.toInt() + int.parse(checkMap["pongs"]!.toString()));
      if (checkFinal["pairs"] == 7 && checkFinal["sets"] == 1){
        checkAmbitions["fullFlushUp"]!.add(true);
      } else {
        checkAmbitions["fullFlushUp"]!.add(false);
      }

      if (checkAmbitions["fullFlushUp"]!.elementAt(0) == true || checkAmbitions["fullFlushUp"]!.elementAt(1) == true || checkAmbitions["fullFlushUp"]!.elementAt(2) == true){
        allAmbitions['fullFlush'] = true;
      }
    }

    print("${checkFinal["sets"]} Sets and ${checkFinal["pairs"]} Pairs");

    int playerid = playerNum;
    if ((checkFinal["sets"] == 5) && (checkFinal["pairs"] == 1)){
      playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.mahjong * 3);
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.mahjong;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.mahjong;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.mahjong;

      print('check final chows ${checkFinal['chows']}');
      if (checkFinal["chows"] == 5){
        allAmbitions['allChow'] = true;
      }else if (checkFinal["pongs"] == 5){
        allAmbitions['allPong'] = true;
      }

      //check escalera
      balls.clear();
      chars.clear();
      sticks.clear();
      for (MtTile tile in mtHands[playerNum]!.hand){
        if (tile.suit == 'balls'){
          balls.add(tile);
        } else if (tile.suit == 'chars'){
          chars.add(tile);
        } else {
          sticks.add(tile);
        }
      }
      for (MtTile tile in mtHands[playerNum]!.faceUp){
        if (tile.suit == 'balls'){
          balls.add(tile);
        } else if (tile.suit == 'chars'){
          chars.add(tile);
        } else {
          sticks.add(tile);
        }
      }

      balls.sort((a, b) => a.number.compareTo(b.number));
      chars.sort((a, b) => a.number.compareTo(b.number));
      sticks.sort((a, b) => a.number.compareTo(b.number));

      int nextEscalera = 1;
      for (MtTile tile in balls){
        if (tile.number == nextEscalera){
          nextEscalera += 1;
        }
      }
      print(nextEscalera);
      if (nextEscalera == 10){
        checkAmbitions['escalera']!.add(true);
      } else {
        checkAmbitions['escalera']!.add(false);
      }
      nextEscalera = 1;
      for (MtTile tile in chars){
        if (tile.number == nextEscalera){
          nextEscalera += 1;
        }
      }
      print(nextEscalera);
      if (nextEscalera == 10){
        checkAmbitions['escalera']!.add(true);
      } else {
        checkAmbitions['escalera']!.add(false);
      }
      nextEscalera = 1;
      for (MtTile tile in sticks){
        if (tile.number == nextEscalera){
          nextEscalera += 1;
        }
      }
      print(nextEscalera);
      if (nextEscalera == 10){
        checkAmbitions['escalera']!.add(true);
      } else {
        checkAmbitions['escalera']!.add(false);
      }

      if (checkAmbitions['escalera']!.elementAt(0) == true || checkAmbitions['escalera']!.elementAt(1) == true || checkAmbitions['escalera']!.elementAt(2) == true){
        allAmbitions['escalera'] = true;
      }

      if (allAmbitions["escalera"] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
        print('${playerMap[playerid]!.tayoCoins} Escalera Major Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
      }
      if (allAmbitions['fullFlush'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
        print('${playerMap[playerid]!.tayoCoins} Major Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
      }
      if (allAmbitions['single'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
        print('${playerMap[playerid]!.tayoCoins} Single Minor Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
      }
      if (allAmbitions['bunot'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 6);
        print('${playerMap[playerid]!.tayoCoins} Major Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major * 2;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major * 2;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major * 2;
      }
      if (allAmbitions['edge'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
        print('${playerMap[playerid]!.tayoCoins} Edge Minor Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
      } else if (allAmbitions['wedge'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
        print('${playerMap[playerid]!.tayoCoins} Wedge Minor Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
      } else if (allAmbitions['backToBack'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
        print('${playerMap[playerid]!.tayoCoins} Back To Back Minor Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
      }

      if (allAmbitions['allChow'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
        print('${playerMap[playerid]!.tayoCoins} All Chow Minor Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
      } else if (allAmbitions['allPong'] == true) { // all pong
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
        print('${playerMap[playerid]!.tayoCoins} All Pong Major Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
      }

      print(allAmbitions);
      winningAmbitions.updateAll((key, value) => allAmbitions[key]!);
      onWin();
    } else if ((checkFinal["sets"] == 1) && (checkFinal["pairs"] == 7)) {
      allAmbitions.update("7pairs", (value) => true);
      playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
      print('${playerMap[playerid]!.tayoCoins} Major Ambition');
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.major;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.major;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.major;

      if (allAmbitions['fullFlush'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
        print('${playerMap[playerid]!.tayoCoins} Major Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
      }

      if (allAmbitions['single'] == true){
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
        print('${playerMap[playerid]!.tayoCoins} Single Minor Ambition');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.minor;
      }

      print(allAmbitions);
      winningAmbitions.updateAll((key, value) => allAmbitions[key]!);
      onWin();

    }

    notifyListeners();
  }

  void throwTile(MtTile tile, List<MtTile> hand) {
    int throwPosition = hand.indexOf(tile);
    hand.removeAt(throwPosition);

    upForGrabs = tile;
    ignoreHandPointers[playerTurn] = true;
    mtHands[playerTurn]!.sort();
    playerTurn = (playerTurn + 1) % 4;
    notifyListeners();
  }

  void drawTile() {
    if(kangSecret == true){
      mtHands[playerTurn]!.goingFor7Pairs = false;
      mtHands[playerTurn]!.sets -= 1;
      mtHands[playerTurn]!.pairs += 2;
      kangSecret = false;
    }

    ignoreHandPointers[playerTurn] = false;
    bool isFlower = true;
    if (upForGrabs.id != 0){
      discardPile.add(upForGrabs);
      lastDrawn = upForGrabs;
      upForGrabs = MtTile.empty();
    }

    MtTile drawn = deck.first;
    isFlower = mtHands[playerTurn]!.addTile(drawn);
    deck.removeAt(0);

    while (isFlower == true) {
      checkFlowers(playerTurn);
      MtTile drawn = deck.last;
      for (MtTile tile in mtHands[playerTurn]!.faceUp){
        if (mtHands[playerTurn]!.faceUp.indexOf(tile) + 1 < mtHands[playerTurn]!.faceUp.length){
          if (drawn.suit == tile.suit && drawn.number == tile.number
              && drawn.number == mtHands[playerTurn]!.faceUp.elementAt(mtHands[playerTurn]!.faceUp.indexOf(tile) + 1).number
              && drawn.suit == mtHands[playerTurn]!.faceUp.elementAt(mtHands[playerTurn]!.faceUp.indexOf(tile) + 1).suit) {
            mtHands[playerTurn]!.faceUp.insert(mtHands[playerTurn]!.faceUp.indexOf(tile), drawn);

            kangSecret = true;
            mtHands[playerTurn]!.goingFor7Pairs = true;
            int playerid = playerTurn;
            playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
            print('${playerMap[playerid]!.tayoCoins} Bonus');
            playerid = (playerid + 1) % 4;
            playerMap[playerid]!.tayoCoins -= payout.major;
            playerid = (playerid + 1) % 4;
            playerMap[playerid]!.tayoCoins -= payout.major;
            playerid = (playerid + 1) % 4;
            playerMap[playerid]!.tayoCoins -= payout.major;

            showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Sagasa Major Bonus!'),
                titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
                content: Text('${playerMap[playerTurn]!.username} won a major bonus!'
                    '\nAll other players have given them ${payout.major} Tayo Coins for a total of ${(payout.major * 3)} TC!'),
                contentTextStyle: TextStyle(color: Colors.white),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
                actionsAlignment: MainAxisAlignment.center,
              ),
            );
            break;
          }
        }
      }
      if (kangSecret == false){
        isFlower = mtHands[playerTurn]!.addTile(drawn);
      }
      deck.removeLast();
    }

    if(deck.isEmpty){
      //TODO end game no winner no mahjong
    }
    notifyListeners();
  }

  void pong(int playerNum) {
    List<MtTile> pongList = List.empty(growable: true);

    for (MtTile tile in mtHands[playerNum]!.hand) {
      if ((tile.suit == upForGrabs.suit) &&
          (tile.number == upForGrabs.number)) {
        pongList.add(tile);
      }
    }
    if (pongList.length > 1) {
      for (MtTile tile in pongList) {
        mtHands[playerNum]!.faceUp.add(tile);
        mtHands[playerNum]!.hand.removeWhere((tile) =>
            (tile.number == upForGrabs.number) &&
            (tile.suit == upForGrabs.suit));
      }
      if (pongList.length == 2) {
        mtHands[playerNum]!.faceUp.add(upForGrabs);
      } else {
        mtHands[playerNum]!.hand.add(upForGrabs);
      }
      mtHands[playerNum]!.sort();
      upForGrabs = MtTile.empty();
      ignoreHandPointers[playerNum] = false;
      mtHands[playerNum]!.sets += 1;
      mtHands[playerNum]!.pongs += 1;
      playerTurn = playerNum;
    }

    notifyListeners();
  }

  void kang(int playerNum) {
    List<MtTile> kangList = List.empty(growable: true);

    for (MtTile tile in mtHands[playerNum]!.hand) {
      if ((tile.suit == upForGrabs.suit) &&
          (tile.number == upForGrabs.number)) {
        kangList.add(tile);
      }
    }
    if (kangList.length > 2) {
      kangSecret = true;
      mtHands[playerNum]!.sets += 1;
      int playerid = playerNum;
      playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.minor * 3);
      print('${playerMap[playerid]!.tayoCoins} Bonus');
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;

      //TODO debt exception

      for (MtTile tile in kangList) {
        mtHands[playerNum]!.faceUp.add(tile);
        mtHands[playerNum]!.hand.removeWhere((tile) =>
            (tile.number == upForGrabs.number) &&
            (tile.suit == upForGrabs.suit));
      }
      playerTurn = playerNum;
      ignoreHandPointers[playerNum] = false;
      mtHands[playerNum]!.faceUp.add(upForGrabs);
      mtHands[playerTurn]!.sort();
      upForGrabs = MtTile.empty();
      ignoreHandPointers[playerTurn] = false;
    }

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kang Minor Bonus'),
        titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
        content: Text('${playerMap[playerTurn]!.username} won a minor bonus!'
            '\nAll other players have given them ${payout.minor} Tayo Coins for a total of ${(payout.minor * 3)} TC!'),
        contentTextStyle: TextStyle(color: Colors.white),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
    notifyListeners();
  }

  Future<bool?> _confirmTopChow(List<MtTile> sameSuit) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose your chow'),
        titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('which set would you like to chow?'),
            SizedBox(height: 10),
            Row(
              children: [
                InkResponse(
                  containedInkWell: true,
                  highlightShape: BoxShape.rectangle,
                  onTap: () => Navigator.pop(context, true),
                  // Add image & text
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 8.0,
                        margin: EdgeInsets.all(1),
                        child: sameSuit.elementAt(0).imagePointer),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 8.0,
                          margin: EdgeInsets.all(1),
                          child: sameSuit.elementAt(1).imagePointer),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 8.0,
                          margin: EdgeInsets.all(1),
                          child: sameSuit.elementAt(2).imagePointer),
                    ],
                  ),
                ),
                Text('   OR   '),
                InkResponse(
                  containedInkWell: true,
                  highlightShape: BoxShape.rectangle,
                  onTap: () => Navigator.pop(context, false),
                  // Add image & text
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 8.0,
                          margin: EdgeInsets.all(1),
                          child: sameSuit.elementAt(sameSuit.length - 3).imagePointer),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 8.0,
                          margin: EdgeInsets.all(1),
                          child: sameSuit.elementAt(sameSuit.length - 2).imagePointer),
                      Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 8.0,
                          margin: EdgeInsets.all(1),
                          child: sameSuit.elementAt(sameSuit.length - 1).imagePointer),
                    ],
                  ),
                ),
              ])
          ]),
        contentTextStyle: TextStyle(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        ),
      );
  }

  Future<void> chow(int playerNum) async {
    List<MtTile> sameSuit = List.empty(growable: true);
    sameSuit.add(upForGrabs);
    bool chowIt = false;

    MtTile prevTile = MtTile.empty();
    List<int> removeList = List.empty(growable: true);
    for (MtTile tile in mtHands[playerNum]!.hand) {
      if (prevTile.suit != tile.suit){
        prevTile = MtTile.empty();
      }

      if ((tile.suit == upForGrabs.suit) &&
          (tile.number - upForGrabs.number < 3) &&
          (tile.number - upForGrabs.number > -3) &&
          (tile.number != prevTile.number) &&
          (tile.number != upForGrabs.number)) {
        sameSuit.add(tile);
      }

      prevTile.number = tile.number;
    }



    sameSuit.sort((a, b) => a.number.compareTo(b.number));
    int checkPos = 0;
    for (MtTile tile in sameSuit) {
      if (checkPos != 0 && (tile.number - prevTile.number != 1)){
        removeList.add(checkPos - 1);
      }
      checkPos += 1;
      prevTile = tile;
    }

    for (int num in removeList){
      sameSuit.removeAt(num);
    }

    if (sameSuit.length > 2) {
      if (sameSuit.length == 5 || sameSuit.length == 4) {
        //Chose Chow
        // choose chow
        bool? isTopChow;
        isTopChow = await _confirmTopChow(sameSuit);
        if (isTopChow == true) {
          mtHands[playerNum]!.hand.add(upForGrabs);
          mtHands[playerNum]!.sort();
          mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(0));
          mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(1));
          mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(2));
          mtHands[playerNum]!
              .hand
              .removeWhere((tile) => tile.id == sameSuit.elementAt(0).id);
          mtHands[playerNum]!
              .hand
              .removeWhere((tile) => tile.id == sameSuit.elementAt(1).id);
          mtHands[playerNum]!
              .hand
              .removeWhere((tile) => tile.id == sameSuit.elementAt(2).id);
          chowIt = true;
        } else if (isTopChow == false){
          //is bottom chow
          mtHands[playerNum]!.hand.add(upForGrabs);
          mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(sameSuit.length - 3));
          mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(sameSuit.length - 2));
          mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(sameSuit.length - 1));
          mtHands[playerNum]!
              .hand
              .removeWhere((tile) => tile.id == sameSuit.elementAt(sameSuit.length - 3).id);
          mtHands[playerNum]!
              .hand
              .removeWhere((tile) => tile.id == sameSuit.elementAt(sameSuit.length - 2).id);
          mtHands[playerNum]!
              .hand
              .removeWhere((tile) => tile.id == sameSuit.elementAt(sameSuit.length - 1).id);
          chowIt = true;
        }
      } else {
        mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(0));
        mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(1));
        mtHands[playerNum]!.faceUp.add(sameSuit.elementAt(2));
        mtHands[playerNum]!
            .hand
            .removeWhere((tile) => tile.id == sameSuit.elementAt(0).id);
        mtHands[playerNum]!
            .hand
            .removeWhere((tile) => tile.id == sameSuit.elementAt(1).id);
        mtHands[playerNum]!
            .hand
            .removeWhere((tile) => tile.id == sameSuit.elementAt(2).id);
        chowIt = true;
      }

      if (chowIt == true){
        mtHands[playerNum]!.chows += 1;
        mtHands[playerNum]!.sort();
        upForGrabs = MtTile.empty();
        ignoreHandPointers[playerNum] = false;
        mtHands[playerNum]!.sets += 1;
        playerTurn = playerNum;
      }

      notifyListeners();
    }
  }

  void secret(int playerNum){
    List<MtTile> checkList = List.empty(growable: true);
    checkList.addAll(mtHands[playerNum]!.hand);

    do {
      int secretCount = 1;
      MtTile checkTile = checkList.last;
      checkList.removeLast();

      for (MtTile tile in checkList){
        if ((tile.suit == checkTile.suit) && (tile.number == checkTile.number)){
          secretCount += 1;
        }
      }

      if (secretCount == 4){
        kangSecret = true;
        int playerid = playerNum;
        playerMap[playerid]!.tayoCoins = playerMap[playerid]!.tayoCoins + (payout.major * 3);
        print('${playerMap[playerid]!.tayoCoins} Bonus');
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
        playerid = (playerid + 1) % 4;
        playerMap[playerid]!.tayoCoins -= payout.major;
//TODO debt exception
        for (MtTile tile in mtHands[playerNum]!.hand){
          if ((tile.suit == checkTile.suit) && (tile.number == checkTile.number)){
            mtHands[playerNum]!.secret.add(tile);
          }
        }
        mtHands[playerNum]!.hand.removeWhere((tile) => ((tile.number == checkTile.number) && (tile.suit == checkTile.suit)));
        mtHands[playerNum]!.sets += 1;

        showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Secret Major Bonus'),
            titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
            content: Text('${playerMap[playerTurn]!.username} won a major bonus!'
                '\nAll other players have given them ${payout.major} Tayo Coins for a total of ${(payout.major * 3)} TC!'),
            contentTextStyle: TextStyle(color: Colors.white),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        );
      }
    } while (checkList.isNotEmpty);

    notifyListeners();
  }

  void checkFlowers(int playerNum){
    final flowers = mtHands[playerNum]!.flowers;
    int playerid = playerNum;

    if (flowers.isEmpty){
      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin Flor Major Bonus!'),
          titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
          content: Text('${playerMap[playerid]!.username} won a major bonus!'
              '\nAll other players have given them ${payout.major} Tayo Coins for a total of ${(payout.major * 3)} TC!'),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );

      playerMap[playerNum]!.tayoCoins += (payout.major * 3);
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.major;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.major;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.major;
    } else if (flowers.length == 1){
      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('1 Flower Minor Bonus!'),
          titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
          content: Text('${playerMap[playerid]!.username} won a minor bonus!'
              '\nAll other players have given them ${payout.minor} Tayo Coins for a total of ${(payout.minor * 3)} TC!'),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );

      playerMap[playerNum]!.tayoCoins += (payout.minor * 3);
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
    } else if (flowers.length == 13){
      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('13 Flowers Minor Bonus!'),
          titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
          content: Text('${playerMap[playerid]!.username} won a minor bonus!'
              '\nAll other players have given them ${payout.minor} Tayo Coins for a total of ${(payout.minor * 3)} TC!'),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );

      playerMap[playerNum]!.tayoCoins += (payout.minor * 3);
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
    } else if (flowers.length == 18){
      showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('18 Flowers Minor Bonus!'),
          titleTextStyle: TextStyle(fontFamily: 'Permanent Marker', color: Colors.white),
          content: Text('${playerMap[playerTurn]!.username} won a minor bonus!'
              '\nAll other players have given them ${payout.minor} Tayo Coins for a total of ${(payout.minor * 3)} TC!'),
          contentTextStyle: TextStyle(color: Colors.white),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
        ),
      );

      playerMap[playerNum]!.tayoCoins += (payout.minor * 3);
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
      playerid = (playerid + 1) % 4;
      playerMap[playerid]!.tayoCoins -= payout.minor;
    }
    notifyListeners();
  }

}
