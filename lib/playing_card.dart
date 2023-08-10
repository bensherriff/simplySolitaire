import 'package:flutter/material.dart';

enum CardSuit {
  spades(name: "Spades"),
  hearts(name: "Hearts"),
  diamonds(name: "Diamonds"),
  clubs(name: "Clubs");

  const CardSuit({ required this.name });

  final String name;
}

extension CardSuitExt on CardSuit {
  String toShortString() {
    return toString().split('.').last;
  }

  CardSuit? fromString(String string) {
    for (CardSuit element in CardSuit.values) {
      if (element.toString() == string) {
        return element;
      }
    }
    return null;
  }
}

enum CardRank {
  ace(name: 'Ace', image: 'a.png'),
  two(name: '2', image: '2.png'),
  three(name: '3', image: '3.png'),
  four(name: '4', image: '4.png'),
  five(name: '5', image: '5.png'),
  six(name: '6', image: '6.png'),
  seven(name: '7', image: '7.png'),
  eight(name: '8', image: '8.png'),
  nine(name: '9', image: '9.png'),
  ten(name: '10', image: '10.png'),
  jack(name: 'Jack', image: 'j.png'),
  queen(name: 'Queen', image: 'q.png'),
  king(name: 'King', image: 'k.png');

  const CardRank({ required this.name, required this.image });

  final String name;
  final String image;
}

extension CardRankExt on CardRank {
  String toShortString() {
    return toString().split('.').last;
  }

  int compareTo(CardRank other) {
    return index.compareTo(other.index);
  }

  CardRank? fromString(String string) {
    for (CardRank element in CardRank.values) {
      if (element.toString() == string) {
        return element;
      }
    }
    return null;
  }

  int get value {
    switch (this) {
      case CardRank.ace:
        return 1;
      case CardRank.two:
        return 2;
      case CardRank.three:
        return 3;
      case CardRank.four:
        return 4;
      case CardRank.five:
        return 5;
      case CardRank.six:
        return 6;
      case CardRank.seven:
        return 7;
      case CardRank.eight:
        return 8;
      case CardRank.nine:
        return 9;
      case CardRank.ten:
        return 10;
      case CardRank.jack:
        return 11;
      case CardRank.queen:
        return 12;
      case CardRank.king:
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
  CardSuit suit;
  CardRank rank;
  bool revealed;
  bool visible;

  PlayingCard({
    required this.suit,
    required this.rank,
    this.revealed = false,
    this.visible = true,
  });

  CardColor get cardColor {
    if(suit == CardSuit.hearts || suit == CardSuit.diamonds) {
      return CardColor.red;
    } else {
      return CardColor.black;
    }
  }

  bool get isKing => (rank == CardRank.king);
  bool get isAce => rank == CardRank.ace;

  Image toAsset() {
    return Image.asset('assets/cards/${suit.toShortString()}/${rank.image}');
  }

  Image toBackAsset() {
    return Image.asset('assets/cards/backs/1.png');
  }

  String name() => '${rank.name} of ${suit.name}';

  @override
  String toString() {
    return '{suit: $suit, rank: $rank, revealed: $revealed}';
  }

  Map toJson() => {
    'suit': suit.toString(),
    'rank': rank.toString(),
    'revealed': revealed,
    'visible': visible
  };

  PlayingCard.fromJson(Map<String, dynamic> json)
    : suit = json['suit'],
      rank = json['rank'],
      revealed = json['revealed'],
      visible = json['visible'];
}