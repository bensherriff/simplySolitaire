import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solitaire/screens/game_screen.dart';
import 'package:solitaire/screens/menu_screen.dart';
import 'package:solitaire/card_column.dart';
import 'package:solitaire/deck.dart';
import 'package:solitaire/card_foundation.dart';
import 'package:solitaire/move.dart';
import 'package:solitaire/playing_card.dart';
import 'package:solitaire/movable_card.dart';
import 'package:solitaire/utilities.dart';

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

  KlondikeScreen({Key? key}) : super(key: key, gameMode: GameMode.klondike, backgroundColor: const Color(0xFF357960));

  @override
  KlondikeScreenState createState() => KlondikeScreenState();
}

class KlondikeScreenState extends GameScreenState<KlondikeScreen> {

  @override
  void initState() {
    super.initState();
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
            (checkAllCardsRevealed()) ? ElevatedButton(
              onPressed: () => {
                handleAutoWin()
                // handleWin()
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Utilities.buttonBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
                ),
              ),
              child: Text("Auto Win",
                style: TextStyle(
                  fontSize: 36.0,
                  color: Utilities.buttonTextColor
                )
              )
            ): Container(),
          ],
        ),
        bottomNavigationBar: bottomNavBar(0xFF15382b, (move) => undoMove(move)),
      )
    );
  }

  Widget buildColumns() {
    List<Widget> columnWidgets = [];

    for (int i = 0; i < 7; i++) {
      columnWidgets.add(Expanded(
        child: CardColumn(
          cards: widget.columns[i],
          columnIndex: i,
          onCardsAdded: (cards, currentColumnIndex) {
            moveCards(cards, currentColumnIndex, i);
          },
          onTap: (cards, currentColumnIndex) {
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

  /// Build the stock deck using the remaining cards
  Widget buildStockDeck() {
    return Row(
      children: <Widget>[
        InkWell(
          child: widget.stockDeck.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: MovableCard(
              playingCard: widget.stockDeck.last,
              columnIndex: 8
            ),
          ) : Opacity(
            opacity: 0.4,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: MovableCard(
                playingCard: PlayingCard(
                  suit: CardSuit.spades,
                  rank: CardRank.ace,
                ),
                columnIndex: 8
              ),
            ),
          ),
          onTap: () {
            setState(() {
              if (!widget.timer.isTimerRunning()) {
                widget.timer.startTimer(reset: false);
              }
              if (widget.stockDeck.isEmpty && widget.wasteDeck.isNotEmpty) {
                widget.stockDeck.addAll(widget.wasteDeck.map((card) {
                  return card
                    ..revealed = false;
                }));
                widget.wasteDeck.clear();
                Move move = Move(
                  cards: widget.stockDeck,
                  previousIndex: 7,
                  newIndex: 8,
                  revealedCard: false,
                  resetDeck: true
                );
                widget.moves.push(move);
              } else if (widget.stockDeck.isNotEmpty) {
                PlayingCard card = widget.stockDeck.removeAt(0)
                  ..revealed = true;
                widget.wasteDeck.add(card);
                Move move = Move(
                  cards: [card],
                  previousIndex: 8,
                  newIndex: 7,
                  revealedCard: false
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
    if (optionsScreen.leftHandMode) {
      return Container(
          constraints: const BoxConstraints(
            maxWidth: 100,
            minWidth: 100,
          ),
          child: Stack(
            children: <Widget>[
              widget.wasteDeck.length >= 3 ? Positioned(
                left: 50,
                child: SizedBox(
                  height: Utilities.cardHeight,
                  width: Utilities.cardWidth,
                  child: widget.wasteDeck.elementAt(widget.wasteDeck.length - 3).toAsset(),
                ),
              ) : const SizedBox(height: Utilities.cardHeight, width: Utilities.cardWidth),
              widget.wasteDeck.length >= 2 ? Positioned(
                left: 25,
                child: SizedBox(
                  height: Utilities.cardHeight,
                  width: Utilities.cardWidth,
                  child: widget.wasteDeck.elementAt(widget.wasteDeck.length - 2).toAsset(),
                ),
              ) : const SizedBox(height: Utilities.cardHeight, width: Utilities.cardWidth),
              widget.wasteDeck.isNotEmpty ? Positioned(
                child: InkWell(
                  child: MovableCard(
                    playingCard: widget.wasteDeck.last,
                    attachedCards: [
                      widget.wasteDeck.last,
                    ],
                    onTap: (cards, currentColumnIndex) {
                      moveToValidColumn(cards, currentColumnIndex);
                    },
                    columnIndex: 7,
                  )
                )
              ) : const Padding(
                padding: EdgeInsets.all(4.0),
                child: SizedBox(
                  height: Utilities.cardHeight,
                  width: Utilities.cardWidth,
                )
              )
            ]
          )
      );
    } else {
      return Container(
          constraints: const BoxConstraints(
            maxWidth: 100,
            minWidth: 100,
          ),
          child: Stack(
              children: <Widget>[
                widget.wasteDeck.length >= 3 ? Positioned(
                  child: SizedBox(
                    height: Utilities.cardHeight,
                    width: Utilities.cardWidth,
                    child: widget.wasteDeck.elementAt(widget.wasteDeck.length - 3).toAsset(),
                  ),
                ) : const SizedBox(height: Utilities.cardHeight, width: Utilities.cardWidth),
                widget.wasteDeck.length >= 2 ? Positioned(
                  left: 25,
                  child: SizedBox(
                    height: Utilities.cardHeight,
                    width: Utilities.cardWidth,
                    child: widget.wasteDeck.elementAt(widget.wasteDeck.length - 2).toAsset(),
                  ),
                ) : const SizedBox(height: Utilities.cardHeight, width: Utilities.cardWidth),
                widget.wasteDeck.isNotEmpty ? Positioned(
                    left: 50,
                    child: InkWell(
                        child: MovableCard(
                          playingCard: widget.wasteDeck.last,
                          attachedCards: [
                            widget.wasteDeck.last,
                          ],
                          onTap: (cards, currentColumnIndex) {
                            moveToValidColumn(cards, currentColumnIndex);
                          },
                          columnIndex: 7,
                        )
                    )
                ) : const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(
                      height: Utilities.cardHeight,
                      width: Utilities.cardWidth,
                    )
                )
              ]
          )
      );
    }
  }

  // Build the final decks of cards
  Widget buildFoundationDecks() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.spades,
            cards: widget.spadesFoundation,
            columnIndex: 9,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, 9);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.hearts,
            cards: widget.heartsFoundation,
            columnIndex: 10,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, 10);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.clubs,
            cards: widget.clubsFoundation,
            columnIndex: 11,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, 11);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.diamonds,
            cards: widget.diamondsFoundation,
            columnIndex: 12,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, 12);
            },
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

  /// Initialize a new game using a seed. The seed is used to generate the
  /// random order of cards, and to allow for re-playability.
  void initializeGame(int seed, {bool debug = false}) {
    Deck allCards = Deck();

    // Add all cards to deck
    allCards.initialize(debug: debug);

    Random random = Random(seed);
    if (!debug) {
      allCards.shuffle(random);
    }

    setState(() {
      widget.columns = List.generate(7, (index) => []);

      // Stores the card deck
      widget.stockDeck = [];
      widget.wasteDeck = [];

      // Stores the card in the upper boxes
      widget.heartsFoundation = [];
      widget.diamondsFoundation = [];
      widget.spadesFoundation = [];
      widget.clubsFoundation = [];

      widget.moves = Moves(gameMode: GameMode.klondike);

      widget.allCardsRevealed = false;

      widget.timer.resetTimer();

      if (debug) {
        for (int i = 0; i < 13; i++) {
          for (int j = 0; j < 4; j++) {
            PlayingCard card = allCards.drawFront();
            card.revealed = true;
            widget.columns[j].add(card);
          }
        }
      } else {
        for (int i = 0; i < widget.columns.length; i++) {
          for (int j = 0; j <= i; j++) {
            PlayingCard card = allCards.drawFront();
            if (j == i) {
              card.revealed = true;
            }
            widget.columns[i].add(card);
          }
        }
      }

      // Set the stock to the remaining cards
      widget.stockDeck = allCards.cards;

      widget.initialized = true;
    });
    widget.box.write('seed', widget.seed);
    widget.box.write('initialized', widget.initialized);
    // widget.box.write('moves', widget.moves);
    // widget.box.write('timer', widget.timer);
  }

  void moveCards(List<PlayingCard> cards, int currentIndex, int newIndex) {
    if (!widget.timer.isTimerRunning()) {
      widget.timer.startTimer(reset: false);
    }

    List<PlayingCard> currentColumn = getListFromIndex(currentIndex);
    List<PlayingCard> newColumn = getListFromIndex(newIndex);

    Move move = Move(
      cards: cards,
      previousIndex: currentIndex,
      newIndex: newIndex,
      revealedCard: false
    );

    setState(() {
      newColumn.addAll(cards);
      int length = currentColumn.length;
      currentColumn.removeRange(length - cards.length, length);
      if (currentColumn.isNotEmpty && !currentColumn.last.revealed) {
        currentColumn.last.revealed = true;
        move.revealedCard = true;
      }
      widget.moves.push(move);
      checkWin();
    });
  }

  void undoMove(Move move) {
    List<PlayingCard> previousColumn = getListFromIndex(move.previousIndex);
    List<PlayingCard> newColumn = getListFromIndex(move.newIndex);
    int length = newColumn.length;

    setState(() {
      if (move.previousIndex == 8) {
        previousColumn.insertAll(0, move.cards.map((card) {
          return card
            ..revealed = false;
        }));
      } else if (move.previousIndex == 7) {
        previousColumn.addAll(move.cards.map((card) {
          return card
            ..revealed = true;
        }));
      } else {
        if (previousColumn.isNotEmpty && move.revealedCard) {
          previousColumn.last.revealed = false;
        }
        previousColumn.addAll(move.cards);
      }
      newColumn.removeRange(length - move.cards.length, length);
    });
  }

  /// Move card(s) to the first valid column if one exists
  void moveToValidColumn(List<PlayingCard> cards, int currentColumnIndex) {
    List<int> validColumns = findValidColumns(cards, currentColumnIndex);

    if (validColumns.isEmpty) {
      return;
    }
    int newColumnIndex = findBestColumn(currentColumnIndex, validColumns);
    moveCards(cards, currentColumnIndex, newColumnIndex);
  }

  /// Find all valid columns for a card
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

  /// Find the best column out of a list of valid columns
  int findBestColumn(int currentColumnIndex, List<int> validColumns) {
    // If there is only one valid column, return the valid column
    if (validColumns.isEmpty) {
      return -1;
    } else if (validColumns.length == 1) {
      return validColumns.first;
    }

    var validColumnsSet = validColumns.toSet();
    var foundationSet = {9, 10, 11, 12};
    var resultSet = validColumnsSet.intersection(foundationSet);

    // If a foundation column is valid, return the foundation column
    if (resultSet.length == 1) {
      return resultSet.first;
    } else if (resultSet.length > 1){
      throw Exception("Invalid");
    }

    return validColumns.first;
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

  void checkWin() {
    if (widget.diamondsFoundation.length +
        widget.heartsFoundation.length +
        widget.clubsFoundation.length +
        widget.spadesFoundation.length ==
        52) {
      handleWin();
    }
  }

  Moves findValidMoves() {
    Moves validMoves = Moves(gameMode: widget.gameMode);

    // Flip stock card if waste is empty
    if (widget.wasteDeck.isEmpty && widget.stockDeck.isNotEmpty) {
      setState(() {
        PlayingCard card = widget.stockDeck.removeAt(0)
          ..revealed = true;
        widget.wasteDeck.add(card);
        Move move = Move(
            cards: [card],
            previousIndex: 8,
            newIndex: 7,
            revealedCard: false
        );
        widget.moves.push(move);
      });
    }

    // Check if waste card is movable
    if (widget.wasteDeck.isNotEmpty) {
      List<int> columns = findValidColumns([widget.wasteDeck.last], 7);
      if (columns.isNotEmpty) {
        int bestColumn = findBestColumn(7, columns);
        Move move = Move(cards: [widget.wasteDeck.last], previousIndex: 7, newIndex: bestColumn, revealedCard: false);
        validMoves.push(move);
      }
    }

    // Columns
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < widget.columns[i].length; j++) {
        if (widget.columns[i][j].revealed) {
          List<PlayingCard> cards = widget.columns[i].sublist(j);
          List<int> columns = findValidColumns(cards, i);
          if (columns.isNotEmpty) {
            int bestColumn = findBestColumn(i, columns);
            Move move = Move(cards: cards, previousIndex: i, newIndex: bestColumn, revealedCard: (j >= 1 && !widget.columns[i][j].revealed));
            validMoves.push(move);
          }
        }
      }
    }

    // Sort moves by priority. Moves with a higher priority should be moved first
    validMoves.list.sort((a, b) => a.cards.first.rank.compareTo(b.cards.first.rank));
    return validMoves.reversed();
  }

  void handleAutoWin() {
    // Use DFS to search for all possible moves.
    // Scan the waste and stock decks for possible moves or combinations of moves
    // i.e., move card from stock to waste, play card, then circle around and
    // play first card.
    // Scan possible moves from columns
    // Be able to reverse decisions for DFS (undo)

    Moves validMoves = Moves(gameMode: GameMode.klondike);
    do {
      validMoves = findValidMoves();
      for (int i = 0; i < validMoves.size; i++) {
        Move? move = validMoves.pop();
        if (move != null) {
          moveCards(move.cards, move.previousIndex, move.newIndex);
        }
      }
    } while (validMoves.isNotEmpty);

    checkWin();
  }

  void handleWin() {
    widget.timer.stopTimer(reset: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 20, top: 35, right: 20, bottom: 20),
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(0,5)),
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text("You won!",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15),
                    Text("Points: ${widget.moves.totalPoints().toString()}",
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 15),
                    Text('Time: ${widget.timer.time()}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            initializeGame(widget.seed);
                          },
                          child: const Text("Replay", style: TextStyle(fontSize: 18)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            initializeRandomGame();
                          },
                          child: const Text("New\nGame", style: TextStyle(fontSize: 18)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            MenuScreen screen = Get.find();
                            setState(() {
                              widget.timer.resetTimer();
                              widget.initialized = false;
                              widget.seed = -1;
                            });
                            Get.offAll(() => screen);
                          },
                          child: const Text("Main\nMenu", style: TextStyle(fontSize: 18)),
                        )
                      ],
                    )
                  ]
                )
              ),
            ]
          )
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