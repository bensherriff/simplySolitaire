import 'package:flutter/material.dart';
import 'package:solitaire/utilities.dart';
import 'card_column.dart';
import 'playing_card.dart';
import 'movable_card.dart';

// The deck of cards which accept the final cards (Ace to King)
class CardFoundation extends StatefulWidget {
  final CardSuit suit;
  final List<PlayingCard> cards;
  final CardAcceptCallback onCardAdded;
  final int columnIndex;

  const CardFoundation({Key? key,
    required this.suit,
    required this.cards,
    required this.onCardAdded,
    this.columnIndex = -1,
  }) : super(key: key);

  @override
  CardFoundationState createState() => CardFoundationState();
}

class CardFoundationState extends State<CardFoundation> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white,
            ),
            height: Utilities.cardHeight,
            width: Utilities.cardWidth,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      height: 20.0,
                      child: suitToImage(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        DragTarget<Map>(
          builder: (context, listOne, listTwo) {
            return widget.cards.isEmpty ? Utilities.emptyCard() : MovableCard(
              playingCard: widget.cards.last,
              columnIndex: widget.columnIndex,
              attachedCards: [
                widget.cards.last,
              ]
            );
          },
          onWillAccept: (value) {
            if (value != null) {
              PlayingCard cardAdded = value["cards"].last;
              if (cardAdded.suit == widget.suit) {
                if (CardRank.values.indexOf(cardAdded.rank) == widget.cards.length) {
                  return true;
                }
              }
            }
            return false;
          },
          onAccept: (value) {
            widget.onCardAdded(
              value["cards"],
              value["currentColumnIndex"],
            );
          },
        )
      ],
    );
  }

  Image? suitToImage() {
    switch (widget.suit) {
      case CardSuit.hearts:
        return Image.asset('assets/cards/hearts.png');
      case CardSuit.diamonds:
        return Image.asset('assets/cards/diamonds.png');
      case CardSuit.clubs:
        return Image.asset('assets/cards/clubs.png');
      case CardSuit.spades:
        return Image.asset('assets/cards/spades.png');
      default:
        return null;
    }
  }
}