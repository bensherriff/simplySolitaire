import 'dart:collection';
import 'dart:math';

import 'package:solitaire/playing_card.dart';

import 'screens/game.dart';

class Move {
  /// List of cards in the move
  List<PlayingCard> cards;
  /// The index of the source column or pile the cards are moved from
  int sourceIndex;
  /// The index of the destination column or pile to which the cards are moved.
  int destinationIndex;
  /// Indicates if a new card was revealed as a result of this move.
  bool revealedCard;
  /// Indicates whether the stock deck was reset due to this move.
  bool resetStockDeck;

  Move({
    required this.cards,
    required this.sourceIndex,
    required this.destinationIndex,
    required this.revealedCard,
    this.resetStockDeck = false,
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
    if (sourceIndex == 7 && destinationIndex <=6) {
      points += 5 * cards.length;
    }

    // To Foundation
    if (destinationIndex >= 9 && destinationIndex <= 12) {
      points += 10;
    }

    // Turned over card
    if (revealedCard) {
      points += 5;
    }

    // Foundation to Column
    if (sourceIndex >= 9 && sourceIndex <=12 && destinationIndex <= 6) {
      points -= 15;
    }

    if (resetStockDeck) {
      points -= 100;
    }
    return points;
  }

  @override
  String toString() {
    return "{cards: $cards, source: $sourceIndex, destination: $destinationIndex, revealedCard: $revealedCard, resetStockDeck: $resetStockDeck}";
  }

  Map toJson() => {
    'cards': cards,
    'sourceIndex': sourceIndex,
    'destinationIndex': destinationIndex,
    'revealedCard': revealedCard,
    'resetStockDeck': resetStockDeck
  };
}

class Moves {
  final GameMode gameMode;
  List<Move> _list = <Move>[];

  Moves({
    required this.gameMode
  });

  void set(List<Move> moves) {
    _list = moves;
  }

  void push(Move move) => _list.add(move);

  Move? pop() => (isEmpty) ? null : _list.removeLast();
  Move? get peek => (isEmpty) ? null : _list.last;

  int totalPoints() {
    int totalPoints = 0;
    for (var move in _list) {
      totalPoints = max(0, totalPoints + move.calculatePoints(gameMode));
    }
    return totalPoints;
  }

  int get size => _list.length;
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();

  Map toJson() => {
    'gameMode': gameMode.toString(),
    'list': _list
  };

  Moves.fromJson(Map<String, dynamic> json)
    : gameMode = json['gameMode'],
      _list = json['list'];
}