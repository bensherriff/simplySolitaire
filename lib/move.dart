import 'dart:math';

import 'package:solitaire/playing_card.dart';

import 'screens/game_screen.dart';

class Move {
  List<PlayingCard> cards;
  int previousIndex;
  int newIndex;
  bool revealedCard;
  bool resetDeck;

  Move({
    required this.cards,
    required this.previousIndex,
    required this.newIndex,
    required this.revealedCard,
    this.resetDeck = false,
  });

  int calculatePoints(GameMode gameMode) {
    int points = 0;
    if (gameMode == GameMode.klondike) {
      return calculateKlondikePoints(points);
    } else {
      return points;
    }
  }

  int calculateKlondikePoints(int points) {
    // Waste to Column
    if (previousIndex == 7 && newIndex <=6) {
      points += 5 * cards.length;
    }

    // To Foundation
    if (newIndex >= 9 && newIndex <= 12) {
      points += 10;
    }

    // Turned over card
    if (revealedCard) {
      points += 5;
    }

    // Foundation to Column
    if (previousIndex >= 9 && previousIndex <=12 && newIndex <= 6) {
      points -= 15;
    }

    if (resetDeck) {
      points -= 100;
    }
    return points;
  }

  @override
  String toString() {
    return "{cards: $cards, newIndex: $newIndex, previousIndex: $previousIndex, revealedCard: $revealedCard}";
  }
}

class Moves {
  final GameMode gameMode;
  List<Move> list = <Move>[];

  Moves({
    required this.gameMode
  });

  void push(Move move) => list.add(move);

  Move? pop() => (isEmpty) ? null : list.removeLast();
  Move? get peek => (isEmpty) ? null : list.last;

  int totalPoints() {
    int totalPoints = 0;
    for (var move in list) {
      totalPoints = max(0, totalPoints + move.calculatePoints(gameMode));
    }
    return totalPoints;
  }

  int get size => list.length;
  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  Moves reversed() {
    Moves reversedMoves = Moves(gameMode: gameMode);
    reversedMoves.list = list.reversed.toList();
    return reversedMoves;
  }

  @override
  String toString() => list.toString();
}