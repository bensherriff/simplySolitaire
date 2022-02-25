import 'package:flutter/material.dart';
import 'package:solitaire/utilities.dart';
import 'card_column.dart';
import 'playing_card.dart';
import 'transformed_card.dart';

// The deck of cards which accept the final cards (Ace to King)
class FinalCardDeck extends StatefulWidget {
  final CardSuit cardSuit;
  final List<PlayingCard> cardsAdded;
  final CardAcceptCallback onCardAdded;
  final int columnIndex;

  FinalCardDeck({
    required this.cardSuit,
    required this.cardsAdded,
    required this.onCardAdded,
    this.columnIndex = -1,
  });

  @override
  FinalCardDeckState createState() => FinalCardDeckState();
}

class FinalCardDeckState extends State<FinalCardDeck> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Map>(
      builder: (context, listOne, listTwo) {
        return widget.cardsAdded.isEmpty
            ? Opacity(
          opacity: 0.7,
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
        )
            : TransformedCard(
          playingCard: widget.cardsAdded.last,
          columnIndex: widget.columnIndex,
          attachedCards: [
            widget.cardsAdded.last,
          ], onClick: (List<PlayingCard> cards, int currentColumnIndex) {
            // Do not move cards from final deck on click
        },
        );
      },
      onWillAccept: (value) {
        if (value != null) {
          PlayingCard cardAdded = value["cards"].last;
          if (cardAdded.cardSuit == widget.cardSuit) {
            if (CardType.values.indexOf(cardAdded.cardType) ==
                widget.cardsAdded.length) {
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
    );
  }

  Image? suitToImage() {
    switch (widget.cardSuit) {
      case CardSuit.hearts:
        return Image.asset('images/hearts.png');
      case CardSuit.diamonds:
        return Image.asset('images/diamonds.png');
      case CardSuit.clubs:
        return Image.asset('images/clubs.png');
      case CardSuit.spades:
        return Image.asset('images/spades.png');
      default:
        return null;
    }
  }
}