import 'dart:math';

import 'playing_card.dart';

class Deck {
  
  final int index;
  List<PlayingCard> cards = [];
  bool isColumn = false;
  bool isStock = false;
  bool isWaste = false;

  Deck(this.index);

  void append(PlayingCard card) {
    cards.add(card);
  }

  void appendAll(List<PlayingCard> _cards) {
    cards.addAll(_cards);
  }
  
  void prepend(PlayingCard card) {
    cards.insert(0, card);
  }

  void prependAll(List<PlayingCard> _cards) {
    cards.insertAll(0, _cards);
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

  // Fisher-Yates Shuffle
  void shuffle(Random random) {
    for (int shuffleCount = 0; shuffleCount < 4; shuffleCount++) {
      for (int i = cards.length - 1; i > 0; i--) {
        int j = random.nextInt(i+1);

        PlayingCard temp = cards[i];
        cards[i] = cards[j];
        cards[j] = temp;
      }
    }
  }

  int get size => cards.length;

  bool get isEmpty => cards.isEmpty;
  bool get isNotEmpty => cards.isNotEmpty;

}