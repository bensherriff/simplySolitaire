import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CardSuit {
  spades,
  hearts,
  diamonds,
  clubs,
}

enum CardType {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king
}

extension CardTypeExtension on CardType {
  int get value {
    switch (this) {
      case CardType.ace:
        return 1;
      case CardType.two:
        return 2;
      case CardType.three:
        return 3;
      case CardType.four:
        return 4;
      case CardType.five:
        return 5;
      case CardType.six:
        return 6;
      case CardType.seven:
        return 7;
      case CardType.eight:
        return 8;
      case CardType.nine:
        return 9;
      case CardType.ten:
        return 10;
      case CardType.jack:
        return 11;
      case CardType.queen:
        return 12;
      case CardType.king:
        return 13;
      default:
        return -1;
    }
  }
}

enum CardColor {
  red,
  black,
}

// Simple playing card model
class PlayingCard {
  CardSuit cardSuit;
  CardType cardType;
  bool faceUp;
  bool opened;
  bool clickable;

  PlayingCard({
    required this.cardSuit,
    required this.cardType,
    this.faceUp = false,
    this.opened = false,
    this.clickable = false
  });

  CardColor get cardColor {
    if(cardSuit == CardSuit.hearts || cardSuit == CardSuit.diamonds) {
      return CardColor.red;
    } else {
      return CardColor.black;
    }
  }

}