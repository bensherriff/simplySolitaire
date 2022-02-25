import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solitaire/game_screen.dart';
import 'package:solitaire/utilities.dart';
import 'card_column.dart';
import 'final_card.dart';
import 'move.dart';
import 'playing_card.dart';
import 'transformed_card.dart';

class KlondikeScreen extends GameScreen {


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

  KlondikeScreen({Key? key}) : super(key: key, gameName: "Klondike", backgroundColor: const Color(0xFF357960));

  @override
  KlondikeScreenState createState() => KlondikeScreenState();
}

class KlondikeScreenState extends GameScreenState<KlondikeScreen> {

  @override
  void initState() {
    if (!widget.initialized) {
      super.initState();
      if (widget.seed == -1) {
        initializeRandomGame();
      } else {
        initializeGame(widget.seed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
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
            Text("Moves: " + widget.moves.size.toString())
          ],
        ),
      )
    );
  }

  List<Widget> appBarWidgets() {
    List<Widget> widgets = [];
    if (widget.moves.isNotEmpty) {
      widgets.add(
        Material(
          type: MaterialType.transparency,
          child: Ink(
            child: InkWell(
              borderRadius: BorderRadius.circular(1000.0),
              onTap: () {
                Move? lastMove = widget.moves.pop();
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
            cards: widget.columns[i],
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
          child: widget.stockDeck.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: TransformedCard(
              playingCard: widget.stockDeck.last,
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
              if (widget.stockDeck.isEmpty) {
                widget.stockDeck.addAll(widget.wasteDeck.map((card) {
                  return card
                    ..revealed = false;
                }));
                widget.wasteDeck.clear();
              } else {
                PlayingCard card = widget.stockDeck.removeAt(0)
                  ..revealed = true;
                widget.wasteDeck.add(card);
                Move move = Move(
                  cards: [card],
                  previousColumnIndex: 8,
                  newColumnIndex: 7,
                  flippedNewCard: false
                );
                widget.moves.push(move);
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
          child: widget.wasteDeck.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: TransformedCard(
              playingCard: widget.wasteDeck.last,
              attachedCards: [
                widget.wasteDeck.last,
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
            cardsAdded: widget.spadesFoundation,
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
            cardsAdded: widget.heartsFoundation,
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
            cardsAdded: widget.clubsFoundation,
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
            cardsAdded: widget.diamondsFoundation,
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
    widget.seed = (random.nextInt(GameScreen.maxSeed));
    initializeGame(widget.seed);
  }

  // Initialise a new game
  void initializeGame(int seed) {
    widget.columns = List.generate(7, (index) => []);

    // Stores the card deck
    widget.stockDeck = [];
    widget.wasteDeck = [];

    // Stores the card in the upper boxes
    widget.heartsFoundation = [];
    widget.diamondsFoundation = [];
    widget.spadesFoundation = [];
    widget.clubsFoundation = [];

    List<PlayingCard> allCards = [];

    widget.moves = MoveStack();

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

    for (int i = 0; i < widget.columns.length; i++) {
      for (int j = 0; j <= i; j++) {
        int randomNumber = random.nextInt(allCards.length);
        PlayingCard card = allCards[randomNumber];
        if (j == i) {
          card.revealed = true;
        }
        widget.columns[i].add(card);
        allCards.removeAt(randomNumber);
      }
    }

    widget.stockDeck = allCards;
    widget.wasteDeck.add(
        widget.stockDeck.removeLast()
        ..revealed = true
    );

    widget.initialized = true;
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
    if (widget.diamondsFoundation.length +
        widget.heartsFoundation.length +
        widget.clubsFoundation.length +
        widget.spadesFoundation.length ==
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
      widget.moves.push(move);
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
    for (int i = 0; i < widget.columns.length; i++) {
      if (i == currentColumnIndex) {
        continue;
      }
      if (widget.columns[i].isEmpty && card.isKing) {
        validColumns.add(i);
      } else if (widget.columns[i].isNotEmpty) {
        PlayingCard compareCard = widget.columns[i].last;
        if (card.cardColor.name != compareCard.cardColor.name && compareCard.rank.value - card.rank.value == 1) {
          validColumns.add(i);
        }
      }
    }

    // Check foundation decks
    if (cards.length == 1) {
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
      } else if (card.suit == CardSuit.spades) {
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

    // Check if foundation deck is available
    if (resultSet.length == 1) {
      return resultSet.first;
    } else if (resultSet.length > 1){
      throw Exception("Invalid");
    }

    return validColumns.first;
  }

  void handleWin() {
    widget.initialized = true;
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
        return widget.columns[0];
      case 1:
        return widget.columns[1];
      case 2:
        return widget.columns[2];
      case 3:
        return widget.columns[3];
      case 4:
        return widget.columns[4];
      case 5:
        return widget.columns[5];
      case 6:
        return widget.columns[6];
      case 7:
        return widget.wasteDeck;
      case 8:
        return widget.stockDeck;
      case 9:
        return widget.spadesFoundation;
      case 10:
        return widget.heartsFoundation;
      case 11:
        return widget.clubsFoundation;
      case 12:
        return widget.diamondsFoundation;
      default:
        return [];
    }
  }
}