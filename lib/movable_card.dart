import 'package:flutter/material.dart';
import 'card_column.dart';
import 'playing_card.dart';
import 'utilities.dart';

typedef CardClickCallback = Null Function(List<PlayingCard> cards, int currentColumnIndex);

/// Transformed card that can be moved and translated according to the position
/// in the card stack.
class MovableCard extends StatefulWidget {
  final PlayingCard playingCard;
  final double transformDistance;
  final int transformIndex;
  final int columnIndex;
  final List<PlayingCard> attachedCards;
  final CardClickCallback onClick;

  const MovableCard({Key? key,
    required this.playingCard,
    required this.attachedCards,
    required this.onClick,
    this.transformDistance = Utilities.cardHeight/5,
    this.transformIndex = 0,
    this.columnIndex = -1
  }) : super(key: key);

  @override
  MovableCardState createState() => MovableCardState();
}

class MovableCardState extends State<MovableCard> {
  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(
          0.0,
          widget.transformIndex * widget.transformDistance,
          0.0,
        ),
      child: buildCardClickable()
    );
  }

  Widget buildCardClickable() {
    return !widget.playingCard.revealed ? SizedBox(
      height: Utilities.cardHeight,
      width: Utilities.cardWidth,
      child: Image.asset('images/backs/1.png'),
    ) : GestureDetector(
      onTap: () => widget.onClick(widget.attachedCards, widget.columnIndex),
      child: buildCard(),
    );
  }

  Widget buildCard() {
    return !widget.playingCard.revealed ? buildFaceDownCard(true) : Draggable<Map>(
      feedback: CardColumn(
          cards: widget.attachedCards,
          columnIndex: 1,
          onCardsAdded: (card, position) {},
          onClick: (cards, currentColumnIndex) {}
      ),
      childWhenDragging: buildFaceUpCard(false),
      data: {
        "cards": widget.attachedCards,
        "currentColumnIndex": widget.columnIndex,
      },
      child: buildFaceUpCard(true),
    );
  }

  Widget buildFaceDownCard(visible) {
    return SizedBox(
      height: Utilities.cardHeight,
      width: Utilities.cardWidth,
      child: visible? Image.asset('images/backs/1.png'): null,
    );
  }

  Widget buildFaceUpCard(visible) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: Utilities.cardHeight,
        width: Utilities.cardWidth,
        child: visible? widget.playingCard.toAsset() : null,
      ),
    );
  }
}