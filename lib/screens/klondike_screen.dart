import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solitaire/screens/game_screen.dart';
import 'package:solitaire/screens/menu_screen.dart';
import '../card_column.dart';
import '../deck.dart';
import '../final_card.dart';
import '../move.dart';
import '../playing_card.dart';
import '../transformed_card.dart';
import '../utilities.dart';

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

  bool allCardsRevealed = false;

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
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 80.0,
          ),
          buildTopDecks(),
          const SizedBox(
            height: 16.0,
          ),
          buildColumns(),
          (widget.allCardsRevealed) ? ElevatedButton(
            onPressed: () => {
              handleWin()
            },
            child: Text("Auto Win",
              style: TextStyle(
                fontSize: 36.0,
                color: Utilities.buttonTextColor
              )
            ),
            style: ElevatedButton.styleFrom(
              primary: Utilities.buttonBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)
              ),
            )
          ): Container()
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 75.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.home),
                iconSize: 30.0,
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                onPressed: () {
                  widget.timer.stopTimer(reset: false);
                  MenuScreen menuScreen = Get.find();
                  Get.to(() => menuScreen);
                }
              ),
              Obx(() => widget.timer.buildTime()),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.moves.totalPoints().toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    const Text("Points")
                  ]
                ),
              ),
              (widget.moves.isNotEmpty)? IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 30.0,
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                onPressed: () {
                  Move? lastMove = widget.moves.pop();
                  if (lastMove != null) {
                    undoMove(lastMove);
                  }
                }
              ) : IconButton(
                icon: const Icon(null),
                iconSize: 30.0,
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                onPressed: () {},
              )
            ],
          )
        ),
      ),
    );
  }

  Widget buildColumns() {
    List<Widget> columnWidgets = [];

    for (int i = 0; i < 7; i++) {
      columnWidgets.add(Expanded(
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
      ));
    }
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ...columnWidgets
        ]
      )
    );
  }

  Widget buildTopDecks() {
    if (optionsScreen.leftHandMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          buildStockDeck(),
          buildWasteDeck(),
          buildFoundationDecks()
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          buildFoundationDecks(),
          buildWasteDeck(),
          buildStockDeck()
        ],
      );
    }
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
              if (!widget.timer.isTimerRunning()) {
                widget.timer.startTimer(reset: false);
              }
              if (widget.stockDeck.isEmpty) {
                widget.stockDeck.addAll(widget.wasteDeck.map((card) {
                  return card
                    ..revealed = false;
                }));
                widget.wasteDeck.clear();
                Move move = Move(
                  cards: widget.stockDeck,
                  previousColumnIndex: 7,
                  newColumnIndex: 8,
                  flippedNewCard: false,
                  resetDeck: true
                );
                widget.moves.push(move);
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

    widget.moves = Moves();

    widget.allCardsRevealed = false;

    Deck allCards = Deck(-1);

    // Add all cards to deck
    for (var suit in CardSuit.values) {
      for (var type in CardRank.values) {
        allCards.append(PlayingCard(
          rank: type,
          suit: suit,
          revealed: false,
        ));
      }
    }


    Random random = Random(seed);
    allCards.shuffle(random);

    for (int i = 0; i < widget.columns.length; i++) {
      for (int j = 0; j <= i; j++) {
        PlayingCard card = allCards.drawFront();
        if (j == i) {
          card.revealed = true;
        }
        widget.columns[i].add(card);
      }
    }

    widget.stockDeck = allCards.cards;
    widget.stockDeck.shuffle(random);
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

  void handleCardsAdded(List<PlayingCard> cards, int currentColumnIndex, int newColumnIndex) {
    if (!widget.timer.isTimerRunning()) {
      widget.timer.startTimer(reset: false);
    }

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
      } else if (move.previousColumnIndex == 7) {
        previousColumn.insertAll(0, move.cards.map((card) {
          return card
            ..revealed = true;
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

  void checkWin() {
    if (widget.diamondsFoundation.length +
        widget.heartsFoundation.length +
        widget.clubsFoundation.length +
        widget.spadesFoundation.length ==
        52) {
      handleWin();
    } else if (checkAllCardsRevealed()) {
      widget.allCardsRevealed = true;
    }
  }

  bool checkAllCardsRevealed() {
    for (int i = 0; i < widget.columns.length; i++) {
      for (int j = 0; j < widget.columns[i].length; j++) {
        if (!widget.columns[i][j].revealed) {
          return false;
        }
      }
    }
    return true;
  }

  void handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: const Text("You Win!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                KlondikeScreen gameScreen = Get.find();
                gameScreen.initialized = false;
                gameScreen.seed = -1;
                Get.to(() => gameScreen);
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