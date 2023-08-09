import 'dart:math';

import 'playing_card.dart';

enum DeckType {
  stock, // Draw pile
  waste, // Discard draw pile
  foundation, // Finished card piles
  column // Played piles
}

class Deck {
  List<PlayingCard> cards = [];
  DeckType type = DeckType.column;
  int index = -1;

  Deck({
    this.type = DeckType.column,
    this.index = -1
});

  void initialize({bool debug = false}) {
    if (debug) {
      for (var rank in CardRank.values.reversed) {
        for (var suit in CardSuit.values) {
          cards.add(PlayingCard(suit: suit, rank: rank));
        }
      }
    } else {
      for (var suit in CardSuit.values) {
        for (var rank in CardRank.values) {
          cards.add(PlayingCard(
            rank: rank,
            suit: suit,
            revealed: false,
          ));
        }
      }
    }
  }

  void append(PlayingCard card) {
    cards.add(card);
  }


  void appendAll(List<PlayingCard> c) {
    cards.addAll(c);
  }
  
  void prepend(PlayingCard card) {
    cards.insert(0, card);
  }

  void prependAll(List<PlayingCard> c) {
    cards.insertAll(0, c);
  }
  
  PlayingCard drawFront() {
    return drawAt(0);
  }
  
  PlayingCard drawBack() {
    return drawAt(cards.length - 1);
  } 
  
  PlayingCard drawAt(int index) {
    if (index > cards.length) {
      return cards.removeLast();
    } else {
      return cards.removeAt(index);
    }
  }

  /// Fisher-Yates Shuffle using a random and number of shuffles to perform
  void shuffle(Random random, {int shuffleCount = 4}) {
    for (int count = 0; count < shuffleCount; count++) {
      for (int i = cards.length - 1; i > 0; i--) {
        int j = random.nextInt(i+1);

        PlayingCard temp = cards[i];
        cards[i] = cards[j];
        cards[j] = temp;
      }
    }
  }

  PlayingCard get first => cards.first;
  PlayingCard get last => cards.last;

  int get size => cards.length;

  bool get isEmpty => cards.isEmpty;
  bool get isNotEmpty => cards.isNotEmpty;

}