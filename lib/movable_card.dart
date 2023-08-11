import 'package:flutter/material.dart';
import 'card_column.dart';
import 'playing_card.dart';
import 'utilities.dart';

typedef CardTapCallback = Null Function(List<PlayingCard> cards, int currentColumnIndex);
typedef CardDragStartCallback = Null Function();
typedef CardDragEndCallback = Null Function();

Null emptyTapCallback(List<PlayingCard> cards, int currentColumnIndex) {}
Null emptyDragStartedCallback() {}
Null emptyDragEndCallback() {}

/// Transformed card that can be moved and translated according to the position
/// in the card stack.
class MovableCard extends StatefulWidget {
  final PlayingCard playingCard;
  final double transformDistance;
  final int transformIndex;
  final int columnIndex;
  final CardTapCallback onTap;
  final CardDragStartCallback onDragStarted;
  final CardDragEndCallback onDragEnd;
  final List<PlayingCard> attachedCards;

  const MovableCard({Key? key,
    required this.playingCard,
    this.attachedCards = const [],
    this.onTap = emptyTapCallback,
    this.onDragStarted = emptyDragStartedCallback,
    this.onDragEnd = emptyDragEndCallback,
    this.transformDistance = Utilities.cardHeight/3.5,
    this.transformIndex = 0,
    this.columnIndex = -1,
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
      child: widget.playingCard.toBackAsset(),
    ) : GestureDetector(
      onTap: () => widget.onTap(widget.attachedCards, widget.columnIndex),
      child: buildCard(),
    );
  }

  Widget buildCard() {
    var draggedCards = <PlayingCard>[];
    for (var c in widget.attachedCards) {
      draggedCards.add(PlayingCard(suit: c.suit, rank: c.rank, revealed: c.revealed));
    }
    return !widget.playingCard.revealed ? buildFaceDownCard(true) : Draggable<Map>(
      feedback: CardColumn(
        // cards: widget.attachedCards,
        // cards: [PlayingCard(suit: CardSuit.clubs, rank: CardRank.ace)],
        cards: draggedCards,
        columnIndex: 1,
        onCardsAdded: (card, position) {},
        onTap: (cards, currentColumnIndex) {}
      ),
      childWhenDragging: buildFaceUpCard(false),
      data: {
        "cards": widget.attachedCards,
        "currentColumnIndex": widget.columnIndex,
      },
      onDragStarted: widget.onDragStarted,
      onDragCompleted: () {
        widget.onDragEnd();
        setState(() {
          widget.playingCard.visible = true;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        widget.onDragEnd();
        setState(() {
          widget.playingCard.visible = true;
        });
      },
      child: buildFaceUpCard(widget.playingCard.visible),
    );
  }

  Widget buildFaceDownCard(visible) {
    return SizedBox(
      height: Utilities.cardHeight,
      width: Utilities.cardWidth,
      child: visible? widget.playingCard.toBackAsset(): null,
    );
  }

  Widget buildFaceUpCard(visible) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: Utilities.cardHeight,
        width: Utilities.cardWidth,
        child: visible? widget.playingCard.display() : null,
      ),
    );
  }
}