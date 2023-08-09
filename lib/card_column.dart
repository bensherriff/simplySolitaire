import 'package:flutter/material.dart';
import 'package:solitaire/utilities.dart';
import 'playing_card.dart';
import 'movable_card.dart';

typedef CardAcceptCallback = Null Function(List<PlayingCard> cards, int currentColumnIndex);

// This is a stack of overlayed cards (implemented using a stack)
class CardColumn extends StatefulWidget {

  // List of cards in the stack
  final List<PlayingCard> cards;

  // Callback when card is added to the stack
  final CardAcceptCallback onCardsAdded;
  final CardTapCallback onTap;

  // The index of the list in the game
  final int columnIndex;


  const CardColumn({Key? key,
    required this.cards,
    required this.onCardsAdded,
    required this.onTap,
    required this.columnIndex,
  }) : super(key: key);

  @override
  CardColumnState createState() => CardColumnState();
}

class CardColumnState extends State<CardColumn> {
  List<PlayingCard> cards = [];


  @override
  Widget build(BuildContext context) {
    cards = widget.cards;
    return Container(
      width: Utilities.cardWidth + 30,
      margin: const EdgeInsets.all(2.0),
      child: DragTarget<Map>(
        builder: (context, data, rejectedData) {
          return Stack(
            children: cards.map((card) {
              int index = cards.indexOf(card);
              return MovableCard(
                playingCard: card,
                transformIndex: index,
                attachedCards: [...cards.sublist(index, cards.length)],
                columnIndex: widget.columnIndex,
                onTap: (cards, currentColumnIndex) {
                  widget.onTap(cards, currentColumnIndex);
                },
                onDragStarted: () {
                  setState(() {
                    for (var element in cards.sublist(index, cards.length)) {
                      element.visible = false;
                    }
                  });
                },
                onDragEnd: () {
                  setState(() {
                    for (var element in cards.sublist(index, cards.length)) {
                      element.visible = true;
                    }
                  });
                },
              );
            }).toList(),
          );
        },
        onWillAccept: (value) {
          // Get dragged cards list
          if (value != null) {
            List<PlayingCard> draggedCards = value["cards"];
            PlayingCard firstCard = draggedCards.first;

            // Hide cards in column
            // int index = widget.cards.indexOf(firstCard);
            // widget.cards.removeRange(index, index + draggedCards.length);

            // If empty and king, accept
            if (widget.cards.isEmpty) {
              if (firstCard.rank == CardRank.king) {
                return true;
              } else {
                return false;
              }
            }

            if (firstCard.cardColor == CardColor.red) {
              if (widget.cards.last.cardColor == CardColor.red) {
                return false;
              }

              int lastColumnCardIndex = CardRank.values.indexOf(widget.cards.last.rank);
              int firstDraggedCardIndex = CardRank.values.indexOf(firstCard.rank);

              if(lastColumnCardIndex != firstDraggedCardIndex + 1) {
                return false;
              }

            } else {
              if (widget.cards.last.cardColor == CardColor.black) {
                return false;
              }

              int lastColumnCardIndex = CardRank.values.indexOf(widget.cards.last.rank);
              int firstDraggedCardIndex = CardRank.values.indexOf(firstCard.rank);

              if(lastColumnCardIndex != firstDraggedCardIndex + 1) {
                return false;
              }

            }
          }
          return true;
        },
        onAccept: (value) {
          widget.onCardsAdded(
            value["cards"],
            value["currentColumnIndex"],
          );
        },
      )
    );
  }
}