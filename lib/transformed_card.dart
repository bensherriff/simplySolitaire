import 'package:flutter/material.dart';
import 'card_column.dart';
import 'playing_card.dart';
import 'utilities.dart';

typedef CardClickCallback = Null Function(List<PlayingCard> cards, int currentColumnIndex);

/// Transformed card that can be moved and translated according to the position
/// in the card stack.
class TransformedCard extends StatefulWidget {
  final PlayingCard playingCard;
  final double transformDistance;
  final int transformIndex;
  final int columnIndex;
  final List<PlayingCard> attachedCards;
  final CardClickCallback onClick;

  const TransformedCard({Key? key,
    required this.playingCard,
    required this.attachedCards,
    required this.onClick,
    this.transformDistance = Utilities.cardHeight/6,
    this.transformIndex = 0,
    this.columnIndex = -1
  }) : super(key: key);

  @override
  TransformedCardState createState() => TransformedCardState();
}

class TransformedCardState extends State<TransformedCard> {
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
    return !widget.playingCard.revealed ? SizedBox(
      height: Utilities.cardHeight,
      width: Utilities.cardWidth,
      child: Image.asset('images/backs/1.png'),
    ) : Draggable<Map>(
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


  Widget buildFaceUpCard(visible) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: Utilities.cardHeight,
        width: Utilities.cardWidth,
        child: visible? Image.asset('images/${widget.playingCard.suit.toShortString()}/${widget.playingCard.rank.toShortString()}.png') : null,
      ),
    );
  }

  String cardTypeToString() {
    switch (widget.playingCard.rank) {
      case CardRank.ace:
        return "A";
      case CardRank.two:
        return "2";
      case CardRank.three:
        return "3";
      case CardRank.four:
        return "4";
      case CardRank.five:
        return "5";
      case CardRank.six:
        return "6";
      case CardRank.seven:
        return "7";
      case CardRank.eight:
        return "8";
      case CardRank.nine:
        return "9";
      case CardRank.ten:
        return "10";
      case CardRank.jack:
        return "J";
      case CardRank.queen:
        return "Q";
      case CardRank.king:
        return "K";
      default:
        return "";
    }
  }

  Image? suitToImage() {
    switch (widget.playingCard.suit) {
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