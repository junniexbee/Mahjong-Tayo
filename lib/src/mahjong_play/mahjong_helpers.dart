// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

class MtTile {
  int id = 0;
  late String suit;
  late int number;
  late Image imagePointer;

  MtTile.empty(){
    id = 0;
    suit = "";
    number = 0;
    imagePointer = Image.asset('assets/images/Tiles/grabs.png', fit: BoxFit.cover);
  }
  MtTile(this.id) {
    if (id < 37) {
      //determine suit
      suit = "balls";
    } else if (id > 36 && id < 73) {
      suit = "chars";
    } else if (id > 72 && id < 109) {
      suit = "sticks";
    } else {
      suit = "flowers";
    }

    number = id % 9; //determine number
    if (number == 0) number = 9;

    if (suit == "balls") {
      //get image pointer
      if (number == 1) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/1.png', fit: BoxFit.cover);
      } else if (number == 2) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/2.png', fit: BoxFit.cover);
      } else if (number == 3) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/3.png', fit: BoxFit.cover);
      } else if (number == 4) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/4.png', fit: BoxFit.cover);
      } else if (number == 5) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/5.png', fit: BoxFit.cover);
      } else if (number == 6) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/6.png', fit: BoxFit.cover);
      } else if (number == 7) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/7.png', fit: BoxFit.cover);
      } else if (number == 8) {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/8.png', fit: BoxFit.cover);
      } else {
        imagePointer =
            Image.asset('assets/images/Tiles/Balls/9.png', fit: BoxFit.cover);
      }
    } else if (suit == "chars") {
      if (number == 1) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/1.png', fit: BoxFit.cover);
      } else if (number == 2) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/2.png', fit: BoxFit.cover);
      } else if (number == 3) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/3.png', fit: BoxFit.cover);
      } else if (number == 4) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/4.png', fit: BoxFit.cover);
      } else if (number == 5) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/5.png', fit: BoxFit.cover);
      } else if (number == 6) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/6.png', fit: BoxFit.cover);
      } else if (number == 7) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/7.png', fit: BoxFit.cover);
      } else if (number == 8) {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/8.png', fit: BoxFit.cover);
      } else {
        imagePointer =
            Image.asset('assets/images/Tiles/Chars/9.png', fit: BoxFit.cover);
      }
    } else if (suit == "sticks") {
      if (number == 1) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/1.png', fit: BoxFit.cover);
      } else if (number == 2) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/2.png', fit: BoxFit.cover);
      } else if (number == 3) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/3.png', fit: BoxFit.cover);
      } else if (number == 4) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/4.png', fit: BoxFit.cover);
      } else if (number == 5) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/5.png', fit: BoxFit.cover);
      } else if (number == 6) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/6.png', fit: BoxFit.cover);
      } else if (number == 7) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/7.png', fit: BoxFit.cover);
      } else if (number == 8) {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/8.png', fit: BoxFit.cover);
      } else {
        imagePointer =
            Image.asset('assets/images/Tiles/Sticks/9.png', fit: BoxFit.cover);
      }
    } else {
      if (number == 1) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/1.png', fit: BoxFit.cover);
      } else if (number == 2) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/2.png', fit: BoxFit.cover);
      } else if (number == 3) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/3.png', fit: BoxFit.cover);
      } else if (number == 4) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/4.png', fit: BoxFit.cover);
      } else if (number == 5) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/5.png', fit: BoxFit.cover);
      } else if (number == 6) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/6.png', fit: BoxFit.cover);
      } else if (number == 7) {
        imagePointer =
            Image.asset('assets/images/Tiles/Flowers/7.png', fit: BoxFit.cover);
      } else if (number == 8) {
        if (id == 116) {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/8a.png',
              fit: BoxFit.cover);
        } else if (id == 124) {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/8b.png',
              fit: BoxFit.cover);
        } else if (id == 132) {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/8c.png',
              fit: BoxFit.cover);
        } else {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/8d.png',
              fit: BoxFit.cover);
        }
      } else {
        if (id == 117) {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/9a.png',
              fit: BoxFit.cover);
        } else if (id == 125) {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/9b.png',
              fit: BoxFit.cover);
        } else if (id == 133) {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/9c.png',
              fit: BoxFit.cover);
        } else {
          imagePointer = Image.asset('assets/images/Tiles/Flowers/9d.png',
              fit: BoxFit.cover);
        }
      }
    } // end flowers suit
  }
}

class MtHand {
  List<MtTile> hand = List.empty(growable: true);
  List<MtTile> faceUp = List.empty(growable: true);
  List<MtTile> secret = List.empty(growable: true);
  List<MtTile> flowers = List.empty(growable: true);
  int sets = 0;
  int pairs = 0;
  int chows = 0;
  int pongs = 0;
  bool goingFor7Pairs = false;
  int round = 0;

  MtHand();

  bool addTile(MtTile tile) {
    if (tile.id > 108) {
      //check if flower
      flowers.add(tile);
      return true;
    } else {
      hand.add(tile);
      return false;
    }
  }

  void sort() {
    hand.sort((a, b) {
      int comp = a.suit.compareTo(b.suit);
      if (comp == 0) {
        return a.number.compareTo(b.number); // '-' for descending
      }
      return comp;
    });
  }
}

class MtPayoutStyle{
  final int mahjong;
  final int minor;
  final int major;

  const MtPayoutStyle({
    required this.mahjong,
    required this.minor,
    required this.major
  });
}

const List<MtPayoutStyle> payouts = [
  MtPayoutStyle(mahjong: 100, minor: 25, major: 50),
  MtPayoutStyle(mahjong: 200, minor: 50, major: 100),
  MtPayoutStyle(mahjong: 300, minor: 75, major: 150),
  MtPayoutStyle(mahjong: 500, minor: 100, major: 200)
];

/// ########### METHODS ##############
/// Shuffle and Tiles
///

List<MtTile> getDeck() {
  final List<MtTile> deck = List.empty(growable: true);
  List<int> deckIds =
      List<int>.generate(144, (index) => index + 1, growable: false);

  deckIds.shuffle();
  deckIds.shuffle();
  for (var tileId in deckIds) {
    deck.add(MtTile(tileId));
  }
  return deck;
}

Map<int,MtHand> getHands(List<MtTile> deck, int mano) {
  Map<int,MtHand> hands = {1:MtHand(),2:MtHand(),3:MtHand(),0:MtHand()};
  int player = mano;
  if (player == 4) {
    player = 0;
  }

  bool isFlower;
  for (var i = 0; i < 17; i++) {
    // Deal to Mano
    isFlower = true;
    do {
      isFlower = hands[player]!.addTile(deck.first);
      deck.removeAt(0);
    } while (isFlower == true);
  }
  hands[player]!.sort();
  player = (player + 1) % 4;

  for (var i = 0; i < 16; i++) {
    // deal 2nd hand
    isFlower = true;
    do {
      isFlower = hands[player]!.addTile(deck.first);
      deck.removeAt(0);
    } while (isFlower == true);
  }
  hands[player]!.sort();
  player = (player + 1) % 4;

  for (var i = 0; i < 16; i++) {
    // Deal 3rd hand
    isFlower = true;
    do {
      isFlower = hands[player]!.addTile(deck.first);
      deck.removeAt(0);
    } while (isFlower == true);
  }
  hands[player]!.sort();
  player = (player + 1) % 4;

  for (var i = 0; i < 16; i++) {
    // Deal 4th hand
    isFlower = true;
    do {
      isFlower = hands[player]!.addTile(deck.first);
      deck.removeAt(0);
    } while (isFlower == true);
  }
  hands[player]!.sort();

  return hands;
}
