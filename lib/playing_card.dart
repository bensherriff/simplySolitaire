import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solitaire/utilities.dart';

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

  Image toImage() {
    return Image.asset('assets/cards/${name.toLowerCase()}.png');
  }
}

enum CardRank {
  ace(name: 'Ace', short: 'a'),
  two(name: '2', short: '2'),
  three(name: '3', short: '3'),
  four(name: '4', short: '4'),
  five(name: '5', short: '5'),
  six(name: '6', short: '6'),
  seven(name: '7', short: '7'),
  eight(name: '8', short: '8'),
  nine(name: '9', short: '9'),
  ten(name: '10', short: '10'),
  jack(name: 'Jack', short: 'j'),
  queen(name: 'Queen', short: 'q'),
  king(name: 'King', short: 'k');

  const CardRank({ required this.name, required this.short });

  final String name;
  final String short;
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

  Widget display() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white
      ),
      height: Utilities.cardHeight,
      width: Utilities.cardWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(rank.short.toUpperCase(), style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 18,
                        color: cardColor == CardColor.red? Colors.red: Colors.black,
                        fontWeight: FontWeight.w500
                    )
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: SizedBox(
                  height: 20,
                  child: suit.toImage(),
                )
              )
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                height: 40,
                child: suit.toImage(),
              )
            ),
          )
        ],
      ),
    );
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