import 'dart:math';

import 'playing_card.dart';

enum DeckType {
  stock,
  waste,
  foundation,
  column
}

class Deck {
  List<PlayingCard> cards = [];
  DeckType type = DeckType.column;

  Deck();

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

  /// Fisher-Yates Shuffle
  void shuffle(Random random) {
    int _shuffleCount = 4;
    for (int shuffleCount = 0; shuffleCount < _shuffleCount; shuffleCount++) {
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