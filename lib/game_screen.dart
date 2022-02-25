import 'dart:developer';
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
  List<List<PlayingCard>> columns = List.generate(7, (index) => []);

  // Stores the card deck
  List<PlayingCard> wasteDeck = [];
  List<PlayingCard> stockDeck = [];

  // Stores the card in the upper boxes
  List<PlayingCard> spadesFoundation = [];
  List<PlayingCard> heartsFoundation = [];
  List<PlayingCard> clubsFoundation = [];
  List<PlayingCard> diamondsFoundation = [];

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
                buildFoundationDecks(),
                buildStockDeck(),
                buildWasteDeck()
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
        Material(
          type: MaterialType.transparency,
          child: Ink(
            child: InkWell(
              borderRadius: BorderRadius.circular(1000.0),
              onTap: () {
                Move? lastMove = moves.pop();
                if (lastMove != null) {
                  undoMove(lastMove);
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.arrow_back,
                  size: 36.0,
                  color: Colors.white
                )
              )
            )
          )
        )
      );
    }
    return widgets;
  }

  Widget buildColumns() {
    List<Widget> columnWidgets = [];

    for (int i = 0; i < 7; i++) {
      Widget test = Expanded(
          child: CardColumn(
            cards: columns[i],
            onCardsAdded: (cards, currentColumnIndex) {
              handleCardsAdded(cards, currentColumnIndex, i);
            },
            columnIndex: i,
            onClick: (cards, currentColumnIndex) {
              moveToValidColumn(cards, currentColumnIndex);
            },
          )
      );
      columnWidgets.add(test);
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ...columnWidgets
        ]
    );
  }

  // Build the deck of cards left after building card columns
  Widget buildStockDeck() {
    return Row(
      children: <Widget>[
        InkWell(
          child: stockDeck.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: TransformedCard(
              playingCard: stockDeck.last,
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
                  suit: CardSuit.spades,
                  rank: CardRank.ace,
                ),
                attachedCards: const [],
                onClick: (List<PlayingCard> cards, int currentColumnIndex) {
                  // Override onClick functionality with onTap method in waste deck
                },
                columnIndex: 8
              ),
            ),
          ),
          onTap: () {
            setState(() {
              if (stockDeck.isEmpty) {
                stockDeck.addAll(wasteDeck.map((card) {
                  return card
                    ..revealed = false;
                }));
                wasteDeck.clear();
              } else {
                PlayingCard card = stockDeck.removeAt(0)
                  ..revealed = true;
                wasteDeck.add(card);
                Move move = Move(
                  cards: [card],
                  previousColumnIndex: 8,
                  newColumnIndex: 7,
                  flippedNewCard: false
                );
                moves.push(move);
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildWasteDeck() {
    return Row(
      children: <Widget>[
        InkWell(
          child: wasteDeck.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: TransformedCard(
              playingCard: wasteDeck.last,
              attachedCards: [
                wasteDeck.last,
              ],
              onClick: (cards, currentColumnIndex) {
                moveToValidColumn(cards, currentColumnIndex);
              },
              columnIndex: 7,
            ),
          ) : Container(
            width: 40.0,
          )
        )
      ]
    );
  }

  // Build the final decks of cards
  Widget buildFoundationDecks() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FinalCardDeck(
            cardSuit: CardSuit.spades,
            cardsAdded: spadesFoundation,
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
            cardsAdded: heartsFoundation,
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
            cardsAdded: clubsFoundation,
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
            cardsAdded: diamondsFoundation,
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
    columns = List.generate(7, (index) => []);

    // Stores the card deck
    stockDeck = [];
    wasteDeck = [];

    // Stores the card in the upper boxes
    heartsFoundation = [];
    diamondsFoundation = [];
    spadesFoundation = [];
    clubsFoundation = [];

    List<PlayingCard> allCards = [];

    // Add all cards to deck
    for (var suit in CardSuit.values) {
      for (var type in CardRank.values) {
        allCards.add(PlayingCard(
          rank: type,
          suit: suit,
          revealed: false,
        ));
      }
    }

    Random random = Random(seed);

    // Add cards to columns and remaining to deck
    for (int i = 0; i < 28; i++) {
      int randomNumber = random.nextInt(allCards.length);

      if (i == 0) {
        PlayingCard card = allCards[randomNumber];
        columns[0].add(
          card
            ..revealed = true
        );
        allCards.removeAt(randomNumber);
      } else if (i > 0 && i < 3) {
        addCardToColumn(allCards, columns[1], i, 2, randomNumber);
      } else if (i > 2 && i < 6) {
        addCardToColumn(allCards, columns[2], i, 5, randomNumber);
      } else if (i > 5 && i < 10) {
        addCardToColumn(allCards, columns[3], i, 9, randomNumber);
      } else if (i > 9 && i < 15) {
        addCardToColumn(allCards, columns[4], i, 14, randomNumber);
      } else if (i > 14 && i < 21) {
        addCardToColumn(allCards, columns[5], i, 20, randomNumber);
      } else {
        addCardToColumn(allCards, columns[6], i, 27, randomNumber);
      }
    }

    stockDeck = allCards;
    wasteDeck.add(
      stockDeck.removeLast()
        ..revealed = true
    );

    setState(() {});
    GameScreen.currentGameInitialized = true;
  }

  void addCardToColumn(List<PlayingCard> allCards, List<PlayingCard> cardColumn, int i, int limit, int randomNumber) {
    if (i == limit) {
      PlayingCard card = allCards[randomNumber];
      cardColumn.add(
        card
          ..revealed = true
      );
    } else {
      cardColumn.add(allCards[randomNumber]);
    }
    allCards.removeAt(randomNumber);
  }

  void checkWin() {
    if (diamondsFoundation.length +
        heartsFoundation.length +
        clubsFoundation.length +
        spadesFoundation.length ==
        52) {
      handleWin();
    }
  }

  void handleCardsAdded(List<PlayingCard> cards, int currentColumnIndex, int newColumnIndex) {

    List<PlayingCard> currentColumn = getListFromIndex(currentColumnIndex);
    List<PlayingCard> newColumn = getListFromIndex(newColumnIndex);

    Move move = Move(
      cards: cards,
      previousColumnIndex: currentColumnIndex,
      newColumnIndex: newColumnIndex,
      flippedNewCard: false
    );

    setState(() {
      newColumn.addAll(cards);
      int length = currentColumn.length;
      currentColumn.removeRange(length - cards.length, length);
      if (currentColumn.isNotEmpty && !currentColumn.last.revealed) {
        currentColumn.last.revealed = true;
        move.flippedNewCard = true;
      }
      moves.push(move);
      checkWin();
    });
  }

  void undoMove(Move move) {
    List<PlayingCard> previousColumn = getListFromIndex(move.previousColumnIndex);
    List<PlayingCard> newColumn = getListFromIndex(move.newColumnIndex);
    int length = newColumn.length;

    setState(() {
      if (move.previousColumnIndex == 8) {
        previousColumn.insertAll(0, move.cards.map((card) {
          return card
            ..revealed = false;
        }));
      } else {
        if (previousColumn.isNotEmpty && move.flippedNewCard) {
          previousColumn.last.revealed = false;
        }
        previousColumn.addAll(move.cards);
      }
      newColumn.removeRange(length - move.cards.length, length);
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
    for (int i = 0; i < columns.length; i++) {
      if (i == currentColumnIndex) {
        continue;
      }
      if (columns[i].isEmpty && card.isKing) {
        validColumns.add(i);
      } else if (columns[i].isNotEmpty) {
        PlayingCard compareCard = columns[i].last;
        if (card.cardColor.name != compareCard.cardColor.name && compareCard.rank.value - card.rank.value == 1) {
          validColumns.add(i);
        }
      }
    }

    // Check final deck columns
    if (card.isAce) {
      if (card.suit == CardSuit.spades) {
        validColumns.add(9);
      } else if (card.suit == CardSuit.hearts) {
        validColumns.add(10);
      } else if (card.suit == CardSuit.clubs) {
        validColumns.add(11);
      } else if (card.suit == CardSuit.diamonds) {
        validColumns.add(12);
      }
    } if (card.suit == CardSuit.spades) {
      if (getListFromIndex(9).isNotEmpty && card.rank.value - getListFromIndex(9).last.rank.value == 1) {
        validColumns.add(9);
      }
    } else if (card.suit == CardSuit.hearts) {
      if (getListFromIndex(10).isNotEmpty && card.rank.value - getListFromIndex(10).last.rank.value == 1) {
        validColumns.add(10);
      }
    } else if (card.suit == CardSuit.clubs) {
      if (getListFromIndex(11).isNotEmpty && card.rank.value - getListFromIndex(11).last.rank.value == 1) {
        validColumns.add(11);
      }
    } else if (card.suit == CardSuit.diamonds) {
      if (getListFromIndex(12).isNotEmpty && card.rank.value - getListFromIndex(12).last.rank.value == 1) {
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

  List<PlayingCard> getListFromIndex(int index) {
    switch (index) {
      case 0:
        return columns[0];
      case 1:
        return columns[1];
      case 2:
        return columns[2];
      case 3:
        return columns[3];
      case 4:
        return columns[4];
      case 5:
        return columns[5];
      case 6:
        return columns[6];
      case 7:
        return wasteDeck;
      case 8:
        return stockDeck;
      case 9:
        return spadesFoundation;
      case 10:
        return heartsFoundation;
      case 11:
        return clubsFoundation;
      case 12:
        return diamondsFoundation;
      default:
        return [];
    }
  }
}