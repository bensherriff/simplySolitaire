import 'dart:math';

import 'package:solitaire/playing_card.dart';

import 'screens/game_screen.dart';

class Move {
  List<PlayingCard> cards;
  int newColumnIndex;
  int previousColumnIndex;
  bool flippedNewCard;
  bool resetDeck;

  Move({
    required this.cards,
    required this.newColumnIndex,
    required this.previousColumnIndex,
    required this.flippedNewCard,
    this.resetDeck = false,
  });

  int points({GameMode gameMode = GameMode.klondike}) {
    int points = 0;

    // Waste to Column
    if (previousColumnIndex == 7 && newColumnIndex <=6) {
      points += 5 * cards.length;
    }

    // To Foundation
    if (newColumnIndex >= 9 && newColumnIndex <= 12) {
        points += 10;
    }

    // Turned over card
    if (flippedNewCard) {
      points += 5;
    }

    // Foundation to Column
    if (previousColumnIndex >= 9 && previousColumnIndex <=12 && newColumnIndex <= 6) {
      points -= 15;
    }

    if (resetDeck) {
      points -= 100;
    }

    return points;
  }

  @override
  String toString() {
    return "{cards: $cards, newColumnIndex: $newColumnIndex, previousColumnIndex: $previousColumnIndex, flippedNewCard: $flippedNewCard}";
  }
}

class Moves {
  final list = <Move>[];

  void push(Move move) => list.add(move);

  Move? pop() => (isEmpty) ? null : list.removeLast();
  Move? get peek => (isEmpty) ? null : list.last;

  int totalPoints({GameMode gameMode = GameMode.klondike}) {
    int totalPoints = 0;
    for (var move in list) {
      totalPoints = max(0, totalPoints + move.points(gameMode: gameMode));
    }
    return totalPoints;
  }

  int get size => list.length;
  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => list.toString();
}