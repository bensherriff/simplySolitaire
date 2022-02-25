import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solitaire/utilities.dart';
import 'card_column.dart';
import 'final_card.dart';
import 'move.dart';
import 'playing_card.dart';
import 'transformed_card.dart';

class GameScreen extends StatefulWidget {

  static bool currentGameInitialized = false;
  static int maxSeed = 4294967296;
  int seed = -1;

  GameScreen({Key? key, int? seed}) : super(key: key);

  @override
  GameScreenState createState() => GameScreenState();

}

class GameScreenState extends State<GameScreen> {

  // Stores the cards on the seven columns
  List<List<PlayingCard>> cardColumns = List.generate(7, (index) => []);

  // Stores the card deck
  List<PlayingCard> cardDeckOpened = [];
  List<PlayingCard> cardDeckClosed = [];

  // Stores the card in the upper boxes
  List<PlayingCard> finalSpadesDeck = [];
  List<PlayingCard> finalHeartsDeck = [];
  List<PlayingCard> finalClubsDeck = [];
  List<PlayingCard> finalDiamondsDeck = [];

  MoveStack moves = MoveStack();

  @override
  void initState() {
    super.initState();
    if (widget.seed == -1) {
      initializeRandomGame();
    } else {
      initializeGame(widget.seed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Utilities.backgroundColor,
        appBar: Utilities.baseAppBar(appBarWidgets()),
        body: Column(
          children: <Widget>[
            const SizedBox(
              height: 60.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFinalDecks(),
                buildCardDeck(),
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            buildColumns(),
            const SizedBox(
              height: 200.0,
            ),
            Text("Moves: " + moves.size.toString())
          ],
        ),
      )
    );
  }

  List<Widget> appBarWidgets() {
    List<Widget> widgets = [];
    if (moves.isNotEmpty) {
      widgets.add(
          IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Move? lastMove = moves.pop();
            if (lastMove != null) {
              handleCardsUndo(lastMove);
            }
          },
        )
      );
    }
    return widgets;
  }

  Widget buildColumns() {
    List<Widget> columns = [];

    for (int i = 0; i < 7; i++) {
      Widget test = Expanded(
          child: CardColumn(
            cards: cardColumns[i],
            onCardsAdded: (cards, currentColumnIndex) {
              handleCardsAdded(cards, currentColumnIndex, i);
            },
            columnIndex: i,
            onClick: (cards, currentColumnIndex) {
              moveToValidColumn(cards, currentColumnIndex);
            },
          )
      );
      columns.add(test);
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ...columns
        ]
    );
  }

  // Build the deck of cards left after building card columns
  Widget buildCardDeck() {
    return Row(
      children: <Widget>[
        InkWell(
          child: cardDeckClosed.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: TransformedCard(
              playingCard: cardDeckClosed.last,
              attachedCards: const [],
              onClick: (List<PlayingCard> cards, int currentColumnIndex) {
              },
              columnIndex: 8
            ),
          ) : Opacity(
            opacity: 0.4,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TransformedCard(
                playingCard: PlayingCard(
                  cardSuit: CardSuit.spades,
                  cardType: CardType.ace,
                ),
                attachedCards: const [],
                onClick: (List<PlayingCard> cards, int currentColumnIndex) {},
                columnIndex: 8
              ),
            ),
          ),
          onTap: () {
            setState(() {
              if (cardDeckClosed.isEmpty) {
                cardDeckClosed.addAll(cardDeckOpened.map((card) {
                  return card
                    ..opened = false
                    ..faceUp = false
                    ..clickable = false;
                }));
                cardDeckOpened.clear();
              } else {
                PlayingCard card = cardDeckClosed.removeAt(0)
                  ..faceUp = true
                  ..opened = true
                  ..clickable = true;
                cardDeckOpened.add(card);
                Move move = Move(
                  cards: [card],
                  previousColumnIndex: 8,
                  newColumnIndex: 7
                );
                moves.push(move);
              }
            });
          },
        ),
        cardDeckOpened.isNotEmpty ? Padding(
          padding: const EdgeInsets.all(4.0),
          child: TransformedCard(
            playingCard: cardDeckOpened.last,
            attachedCards: [
              cardDeckOpened.last,
            ],
            onClick: (cards, currentColumnIndex) {
              moveToValidColumn(cards, currentColumnIndex);
            },
            columnIndex: 7,
          ),
        ) : Container(
          width: 40.0,
        ),
      ],
    );
  }

  // Build the final decks of cards
  Widget buildFinalDecks() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FinalCardDeck(
            cardSuit: CardSuit.spades,
            cardsAdded: finalSpadesDeck,
            onCardAdded: (cards, currentColumnIndex) {
              handleCardsAdded(cards, currentColumnIndex, 9);
            },
            columnIndex: 9,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FinalCardDeck(
            cardSuit: CardSuit.hearts,
            cardsAdded: finalHeartsDeck,
            onCardAdded: (cards, currentColumnIndex) {
              handleCardsAdded(cards, currentColumnIndex, 10);
            },
            columnIndex: 10,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FinalCardDeck(
            cardSuit: CardSuit.clubs,
            cardsAdded: finalClubsDeck,
            onCardAdded: (cards, currentColumnIndex) {
              handleCardsAdded(cards, currentColumnIndex, 11);
            },
            columnIndex: 11,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FinalCardDeck(
            cardSuit: CardSuit.diamonds,
            cardsAdded: finalDiamondsDeck,
            onCardAdded: (cards, currentColumnIndex) {
              handleCardsAdded(cards, currentColumnIndex, 12);
            },
            columnIndex: 12,
          ),
        ),
      ],
    );
  }

  void initializeRandomGame() {
    Random random = Random();
    widget.seed = random.nextInt(GameScreen.maxSeed);
    initializeGame(widget.seed);
  }

  // Initialise a new game
  void initializeGame(int seed) {
    cardColumns = List.generate(7, (index) => []);

    // Stores the card deck
    cardDeckClosed = [];
    cardDeckOpened = [];

    // Stores the card in the upper boxes
    finalHeartsDeck = [];
    finalDiamondsDeck = [];
    finalSpadesDeck = [];
    finalClubsDeck = [];

    List<PlayingCard> allCards = [];

    // Add all cards to deck
    for (var suit in CardSuit.values) {
      for (var type in CardType.values) {
        allCards.add(PlayingCard(
          cardType: type,
          cardSuit: suit,
          faceUp: false,
        ));
      }
    }

    Random random = Random(seed);

    // Add cards to columns and remaining to deck
    for (int i = 0; i < 28; i++) {
      int randomNumber = random.nextInt(allCards.length);

      if (i == 0) {
        PlayingCard card = allCards[randomNumber];
        cardColumns[0].add(
          card
            ..opened = true
            ..faceUp = true
            ..clickable = true,
        );
        allCards.removeAt(randomNumber);
      } else if (i > 0 && i < 3) {
        addCardToColumn(allCards, cardColumns[1], i, 2, randomNumber);
      } else if (i > 2 && i < 6) {
        addCardToColumn(allCards, cardColumns[2], i, 5, randomNumber);
      } else if (i > 5 && i < 10) {
        addCardToColumn(allCards, cardColumns[3], i, 9, randomNumber);
      } else if (i > 9 && i < 15) {
        addCardToColumn(allCards, cardColumns[4], i, 14, randomNumber);
      } else if (i > 14 && i < 21) {
        addCardToColumn(allCards, cardColumns[5], i, 20, randomNumber);
      } else {
        addCardToColumn(allCards, cardColumns[6], i, 27, randomNumber);
      }
    }

    cardDeckClosed = allCards;
    cardDeckOpened.add(
      cardDeckClosed.removeLast()
        ..opened = true
        ..faceUp = true
        ..clickable = true
    );

    setState(() {});
    GameScreen.currentGameInitialized = true;
  }

  void addCardToColumn(List<PlayingCard> allCards, List<PlayingCard> cardColumn, int i, int limit, int randomNumber) {
    if (i == limit) {
      PlayingCard card = allCards[randomNumber];
      cardColumn.add(
        card
          ..opened = true
          ..faceUp = true
          ..clickable = true,
      );
    } else {
      cardColumn.add(allCards[randomNumber]);
    }
    allCards.removeAt(randomNumber);
  }

  void refreshList(int index) {
    if (finalDiamondsDeck.length +
        finalHeartsDeck.length +
        finalClubsDeck.length +
        finalSpadesDeck.length ==
        52) {
      handleWin();
    }
    List<PlayingCard> list = getListFromIndex(index);
    setState(() {
      if (list.isNotEmpty) {
        for (int i = 0; i < list.length - 1; i ++) {
          list[i]
            ..opened = false
            ..faceUp = false
            ..clickable = false;
        }
        list[list.length - 1]
          ..opened = true
          ..faceUp = true
          ..clickable = true;
      }
    });
  }

  // Handle a win condition
  void handleWin() {
    GameScreen.currentGameInitialized = false;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Text("You Win!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                initializeRandomGame();
                Navigator.pop(context);
              },
              child: const Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  void handleCardsAdded(List<PlayingCard> cards, int currentColumnIndex, int newColumnIndex) {
    Move move = Move(
      cards: cards,
      previousColumnIndex: currentColumnIndex,
      newColumnIndex: newColumnIndex
    );
    setState(() {
      moves.push(move);
      getListFromIndex(newColumnIndex).addAll(cards);
      int length = getListFromIndex(currentColumnIndex).length;
      getListFromIndex(currentColumnIndex).removeRange(length - cards.length, length);
      refreshList(currentColumnIndex);
    });
  }

  void handleCardsUndo(Move move) {
    List<PlayingCard> previousColumn = getListFromIndex(move.previousColumnIndex);
    List<PlayingCard> newColumn = getListFromIndex(move.newColumnIndex);
    int length = newColumn.length;

    setState(() {
      if (move.previousColumnIndex == 8) {
        previousColumn.insertAll(0, move.cards.map((card) {
          return card
            ..opened = false
            ..faceUp = false
            ..clickable = false;
        }));
      } else {
        previousColumn.addAll(move.cards);
        refreshList(move.previousColumnIndex);
      }
      newColumn.removeRange(length - move.cards.length, length);
      refreshList(move.newColumnIndex);
    });
  }

  void moveToValidColumn(List<PlayingCard> cards, int currentColumnIndex) {
    List<int> validColumns = findValidColumns(cards, currentColumnIndex);

    if (validColumns.isEmpty) {
      return;
    }
    int newColumnIndex = findBestColumn(currentColumnIndex, validColumns);
    handleCardsAdded(cards, currentColumnIndex, newColumnIndex);
  }

  List<int> findValidColumns(List<PlayingCard> cards, int currentColumnIndex) {
    List<int> validColumns = [];

    if (cards.isEmpty) {
      return validColumns;
    }
    PlayingCard card = cards.first;

    // Check main columns
    for (int i = 0; i < cardColumns.length; i++) {
      if (i == currentColumnIndex) {
        continue;
      }
      if (cardColumns[i].isEmpty && card.cardType == CardType.king) {
        validColumns.add(i);
      } else if (cardColumns[i].isNotEmpty) {
        PlayingCard compareCard = cardColumns[i].last;
        if (card.cardColor.name != compareCard.cardColor.name && compareCard.cardType.value - card.cardType.value == 1) {
          validColumns.add(i);
        }
      }
    }

    // Check final deck columns
    if (card.cardType == CardType.ace) {
      if (card.cardSuit == CardSuit.spades) {
        validColumns.add(9);
      } else if (card.cardSuit == CardSuit.hearts) {
        validColumns.add(10);
      } else if (card.cardSuit == CardSuit.clubs) {
        validColumns.add(11);
      } else if (card.cardSuit == CardSuit.diamonds) {
        validColumns.add(12);
      }
    } if (card.cardSuit == CardSuit.spades) {
      if (getListFromIndex(9).isNotEmpty && card.cardType.value - getListFromIndex(9).last.cardType.value == 1) {
        validColumns.add(9);
      }
    } else if (card.cardSuit == CardSuit.hearts) {
      if (getListFromIndex(10).isNotEmpty && card.cardType.value - getListFromIndex(10).last.cardType.value == 1) {
        validColumns.add(10);
      }
    } else if (card.cardSuit == CardSuit.clubs) {
      if (getListFromIndex(11).isNotEmpty && card.cardType.value - getListFromIndex(11).last.cardType.value == 1) {
        validColumns.add(11);
      }
    } else if (card.cardSuit == CardSuit.diamonds) {
      if (getListFromIndex(12).isNotEmpty && card.cardType.value - getListFromIndex(12).last.cardType.value == 1) {
        validColumns.add(12);
      }
    }

    return validColumns;
  }

  int findBestColumn(int currentColumnIndex, List<int> validColumns) {

    if (validColumns.length == 1) {
      return validColumns.first;
    }

    var validColumnsSet = validColumns.toSet();
    var finalDeckSet = {9, 10, 11, 12};

    var resultSet = validColumnsSet.intersection(finalDeckSet);
    if (resultSet.length == 1) {
      return resultSet.first;
    } else if (resultSet.length > 1){
      throw Exception("Invalid");
    }

    return validColumns.first;
  }

  List<PlayingCard> getListFromIndex(int index) {
    switch (index) {
      case 0:
        return cardColumns[0];
      case 1:
        return cardColumns[1];
      case 2:
        return cardColumns[2];
      case 3:
        return cardColumns[3];
      case 4:
        return cardColumns[4];
      case 5:
        return cardColumns[5];
      case 6:
        return cardColumns[6];
      case 7:
        return cardDeckOpened;
      case 8:
        return cardDeckClosed;
      case 9:
        return finalSpadesDeck;
      case 10:
        return finalHeartsDeck;
      case 11:
        return finalClubsDeck;
      case 12:
        return finalDiamondsDeck;
      default:
        return [];
    }
  }
}