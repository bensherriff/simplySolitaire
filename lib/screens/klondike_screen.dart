import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:solitaire/screens/game_screen.dart';
import 'package:solitaire/card_column.dart';
import 'package:solitaire/deck.dart';
import 'package:solitaire/card_foundation.dart';
import 'package:solitaire/move.dart';
import 'package:solitaire/playing_card.dart';
import 'package:solitaire/movable_card.dart';
import 'package:solitaire/utilities.dart';

class KlondikeScreen extends GameScreen {

  KlondikeScreen({Key? key}) : super(
    key: key,
    gameMode: GameMode.klondike,
    style: GameStyle(
      backgroundColor: const Color(0xFF357960),
      barColor: const Color(0xFF15382b))
  );

  @override
  KlondikeScreenState createState() => KlondikeScreenState();
}

class KlondikeScreenState extends GameScreenState<KlondikeScreen> {
  final logger = Logger('KlondikeScreenState');
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
        backgroundColor: widget.style.backgroundColor,
        body: Column(
          children: <Widget>[
            topScoreBar(),
            const SizedBox(height: 8),
            buildTopDecks(),
            const SizedBox(height: 16.0),
            buildColumns(),
            (checkAllCardsRevealed()) ? ElevatedButton(
              onPressed: () async => {
                if (widget.autoMove) {
                  widget.autoMove = false
                } else {
                  widget.autoMove = true,
                  widget.timer.stopTimer(reset: false),
                  await handleAutoWin()
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(230, 60),
                backgroundColor: const Color(0xFF55688a),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)
                ),
              ),
              child: Text("Auto Win",
                style: GoogleFonts.quicksand(
                  fontSize: 36.0,
                  color: Colors.white
                )
              )
            ): const SizedBox(),
            const SizedBox(height: 8)
          ],
        ),
        bottomNavigationBar: bottomNavBar((move) => undoMove(move)),
      )
    );
  }

  Widget buildColumns() {
    List<Widget> columnWidgets = [];

    for (int i = 0; i < 7; i++) {
      columnWidgets.add(Expanded(
        child: CardColumn(
          cards: columns[i],
          columnIndex: i,
          onCardsAdded: (cards, currentColumnIndex) {
            moveCards(cards, currentColumnIndex, destinationIndex: i);
          },
          onTap: (cards, currentColumnIndex) {
            moveCards(cards, currentColumnIndex);
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
    if (Utilities.readData('leftHandMode')) {
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
          child: stockDeck.isNotEmpty ? Padding(
            padding: const EdgeInsets.all(4.0),
            child: MovableCard(
              playingCard: stockDeck.last,
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
            handleStockDeck();
          },
        ),
      ],
    );
  }

  Widget buildWasteDeck() {
    if (Utilities.readData('leftHandMode')) {
      return Container(
          constraints: const BoxConstraints(
            maxWidth: 100,
            minWidth: 100,
          ),
          child: Stack(
            children: <Widget>[
              wasteDeck.length >= 3 ? Positioned(
                left: 50,
                child: SizedBox(
                  height: Utilities.cardHeight,
                  width: Utilities.cardWidth,
                  child: wasteDeck.elementAt(wasteDeck.length - 3).display(),
                ),
              ) : Utilities.emptyCard(),
              wasteDeck.length >= 2 ? Positioned(
                left: 25,
                child: SizedBox(
                  height: Utilities.cardHeight,
                  width: Utilities.cardWidth,
                  child: wasteDeck.elementAt(wasteDeck.length - 2).display(),
                ),
              ) : Utilities.emptyCard(),
              wasteDeck.isNotEmpty ? Positioned(
                child: InkWell(
                  child: MovableCard(
                    playingCard: wasteDeck.last,
                    attachedCards: [
                      wasteDeck.last,
                    ],
                    onTap: (cards, currentColumnIndex) {
                      moveCards(cards, currentColumnIndex);
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
                wasteDeck.length >= 3 ? Positioned(
                  child: SizedBox(
                    height: Utilities.cardHeight,
                    width: Utilities.cardWidth,
                    child: wasteDeck.elementAt(wasteDeck.length - 3).display(),
                  ),
                ) : Utilities.emptyCard(),
                wasteDeck.length >= 2 ? Positioned(
                  left: 25,
                  child: SizedBox(
                    height: Utilities.cardHeight,
                    width: Utilities.cardWidth,
                    child: wasteDeck.elementAt(wasteDeck.length - 2).display(),
                  ),
                ) : Utilities.emptyCard(),
                wasteDeck.isNotEmpty ? Positioned(
                    left: 50,
                    child: InkWell(
                        child: MovableCard(
                          playingCard: wasteDeck.last,
                          attachedCards: [
                            wasteDeck.last,
                          ],
                          onTap: (cards, currentColumnIndex) {
                            moveCards(cards, currentColumnIndex);
                          },
                          columnIndex: 7,
                        )
                    )
                ) : Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Utilities.emptyCard()
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
            cards: spadesFoundation,
            columnIndex: 9,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, destinationIndex: 9);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.hearts,
            cards: heartsFoundation,
            columnIndex: 10,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, destinationIndex: 10);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.clubs,
            cards: clubsFoundation,
            columnIndex: 11,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, destinationIndex: 11);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: CardFoundation(
            suit: CardSuit.diamonds,
            cards: diamondsFoundation,
            columnIndex: 12,
            onCardAdded: (cards, currentColumnIndex) {
              moveCards(cards, currentColumnIndex, destinationIndex: 12);
            },
          ),
        ),
      ],
    );
  }

  /// Initialize a new game using a seed. The seed is used to generate the
  /// random order of cards, and to allow for re-playability.
  @override
  void initializeGame(int seed, {bool debug = false}) {
    Deck allCards = Deck();
    // seed = 1393796464;

    // Add all cards to deck
    allCards.initialize(debug: debug);

    Random random = Random(seed);
    if (!debug) {
      allCards.shuffle(random);
    }

    setState(() {
      columns = List.generate(7, (index) => []);

      // Stores the card deck
      stockDeck = [];
      wasteDeck = [];

      // Stores the card in the upper boxes
      heartsFoundation = [];
      diamondsFoundation = [];
      spadesFoundation = [];
      clubsFoundation = [];

      widget.moves = Moves(gameMode: GameMode.klondike);

      widget.timer.resetTimer();

      if (debug) {
        for (int i = 0; i < 13; i++) {
          for (int j = 0; j < 4; j++) {
            PlayingCard card = allCards.drawFront();
            card.revealed = true;
            columns[j].add(card);
          }
        }
      } else {
        for (int i = 0; i < columns.length; i++) {
          for (int j = 0; j <= i; j++) {
            PlayingCard card = allCards.drawFront();
            if (j == i) {
              card.revealed = true;
            }
            columns[i].add(card);
          }
        }
      }

      // Set the stock to the remaining cards
      stockDeck = allCards.cards;

      widget.initialized = true;
    });
    Utilities.writeData('seed', seed);
    Utilities.writeData('initialized', widget.initialized);
    // widget.box.write('moves', widget.moves);
    // widget.box.write('timer', widget.timer);
  }

  /// Move (card(s) to the destinationIndex column, or find the next best column if otherwise not specified.
  void moveCards(List<PlayingCard> cards, int sourceIndex, {int destinationIndex = -1, bool startTimer = true}) {
    if (!widget.timer.isTimerRunning() && startTimer) {
      widget.timer.startTimer(reset: false);
    }

    // Set the destinationIndex if not set
    if (destinationIndex == -1) {
      (int, double) record = determineBestColumn(sourceIndex, cards);
      if (record.$1 == -1) {
        checkWin();
        return;
      }
    }

    if (getListFromIndex(sourceIndex).length < cards.length) {
      logger.warning("Cannot move cards, column $sourceIndex does not have ${cards.length} cards");
      return;
    }

    Move move = Move(
      cards: cards,
      sourceIndex: sourceIndex,
      destinationIndex: destinationIndex,
      revealedCard: false
    );

    setState(() {
      getListFromIndex(destinationIndex).addAll(cards);
      int length = getListFromIndex(sourceIndex).length;
      getListFromIndex(sourceIndex).removeRange(length - cards.length, length);
      if (getListFromIndex(sourceIndex).isNotEmpty && !getListFromIndex(sourceIndex).last.revealed) {
        getListFromIndex(sourceIndex).last.revealed = true;
        move.revealedCard = true;
      }
      widget.moves.push(move);
    });
    checkWin();
  }

  void undoMove(Move move) {
    List<PlayingCard> previousColumn = getListFromIndex(move.sourceIndex);
    List<PlayingCard> newColumn = getListFromIndex(move.destinationIndex);
    int length = newColumn.length;

    setState(() {
      if (move.sourceIndex == 8) {
        previousColumn.insertAll(0, move.cards.map((card) {
          return card
            ..revealed = false;
        }));
      } else if (move.sourceIndex == 7) {
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
    checkWin();
  }

  /// Find the best column out of a list of valid columns
  (int, double) determineBestColumn(int currentColumnIndex, List<PlayingCard> cards) {
    // If there are no cards, there is no best column
    if (cards.isEmpty) {
      return (-1, -1);
    }
    PlayingCard card = cards.first;

    Map<int, double> validColumns = HashMap();

    void add(int columnIndex, double score) {
      if (validColumns.containsKey(columnIndex)) {
        validColumns[columnIndex] = (validColumns[columnIndex]! + score);
      } else {
        validColumns[columnIndex] = score;
      }
      logger.finest('($card) $currentColumnIndex -> $columnIndex: ${validColumns[columnIndex]}');
    }

    // Count the hidden cards in the current column (if applicable)
    int currentColumnHiddenCards = 0;
    if (currentColumnIndex < columns.length) {
      currentColumnHiddenCards = Utilities.countHiddenCards(columns[currentColumnIndex]);
    }

    // Check if cards can be placed onto the main columns
    for (int i = 0; i < columns.length; i++) {
      if (i == currentColumnIndex) {
        validColumns[i] = -1;
        continue;
      }
      // Check if king can be moved to empty column
      if (columns[i].isEmpty && card.isKing) {
        // Disfavor kings that are already the first card
        if (currentColumnIndex < columns.length - 1 && currentColumnHiddenCards == 0) {
          add(i, -50);
        } else {
          add(i, 10 + (1.6 * currentColumnHiddenCards));
        }
      } else if (columns[i].isNotEmpty) {
        PlayingCard compareCard = columns[i].last;
        // Check if card can be placed onto another card in a new column
        if (card.cardColor.name != compareCard.cardColor.name && compareCard.rank.value - card.rank.value == 1) {
          // Add a bias to moving this card based on the number of hidden cards in the current column
          add(i, 5 + (1.5 * currentColumnHiddenCards));
          // Prioritize columns with less hidden cards
          int hiddenCards = Utilities.countHiddenCards(columns[i]);
          add(i, -(hiddenCards/2.5));
          // Disfavor moving a card to another card if it's already placed
          if (currentColumnIndex < columns.length - 1) {
            List<PlayingCard> currentColumn = columns[currentColumnIndex];
            int currentCardIndex = currentColumn.indexOf(card);
            // Check if moving the card helps move the above card
            if (currentCardIndex > 0) {
              List<PlayingCard> aboveCards = currentColumn.sublist(currentCardIndex - 1, currentColumn.length - 1);
              (int, double) aboveCardResults = determineBestColumn(currentColumnIndex, aboveCards);
              if (aboveCardResults.$1 == -1) {
                add(i, -20 * (aboveCards.first.revealed? 1: 0));
              } else if (aboveCardResults.$2 >= validColumns[i]!) {
                add(i, aboveCardResults.$2 / 2);
              }
            }
          }
        }
      }
    }

    // Check if cards can be placed onto the foundation decks
    if (cards.length == 1) {
      if (card.isAce) {
        if (card.suit == CardSuit.spades) {
          add(9, 24);
        } else if (card.suit == CardSuit.hearts) {
          add(10, 24);
        } else if (card.suit == CardSuit.clubs) {
          add(11, 24);
        } else if (card.suit == CardSuit.diamonds) {
          add(12, 24);
        }
      } else if (card.suit == CardSuit.spades) {
        if (getListFromIndex(9).isNotEmpty && card.rank.value - getListFromIndex(9).last.rank.value == 1) {
          add(9, 12);
          // Less incentive if other foundation decks are behind
          if (getListFromIndex(10).isNotEmpty) {
            add(9, (getListFromIndex(10).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(11).isNotEmpty) {
            add(9, (getListFromIndex(11).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(12).isNotEmpty) {
            add(9, (getListFromIndex(12).last.rank.value - card.rank.value)  * 1.0);
          }
        }
      } else if (card.suit == CardSuit.hearts) {
        if (getListFromIndex(10).isNotEmpty && card.rank.value - getListFromIndex(10).last.rank.value == 1) {
          add(10, 12);
          // Less incentive if other foundation decks are behind
          if (getListFromIndex(9).isNotEmpty) {
            add(10, (getListFromIndex(9).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(11).isNotEmpty) {
            add(10, (getListFromIndex(11).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(12).isNotEmpty) {
            add(10, (getListFromIndex(12).last.rank.value - card.rank.value)  * 1.0);
          }
        }
      } else if (card.suit == CardSuit.clubs) {
        if (getListFromIndex(11).isNotEmpty && card.rank.value - getListFromIndex(11).last.rank.value == 1) {
          add(11, 12);
          // Less incentive if other foundation decks are behind
          if (getListFromIndex(9).isNotEmpty) {
            add(11, (getListFromIndex(9).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(9).isNotEmpty) {
            add(11, (getListFromIndex(9).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(12).isNotEmpty) {
            add(11, (getListFromIndex(12).last.rank.value - card.rank.value) * 1.0);
          }
        }
      } else if (card.suit == CardSuit.diamonds) {
        if (getListFromIndex(12).isNotEmpty && card.rank.value - getListFromIndex(12).last.rank.value == 1) {
          add(12, 12);
          // Less incentive if other foundation decks are behind
          if (getListFromIndex(9).isNotEmpty) {
            add(12, (getListFromIndex(9).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(10).isNotEmpty) {
            add(12, (getListFromIndex(10).last.rank.value - card.rank.value)  * 1.0);
          }
          if (getListFromIndex(11).isNotEmpty) {
            add(12, (getListFromIndex(11).last.rank.value - card.rank.value)  * 1.0);
          }
        }
      }
    }

    // Return the column with the best score
    int bestColumn = -1;
    double bestScore = -1;
    validColumns.forEach((column, score) {
      if (score > bestScore) {
        bestColumn = column;
        bestScore = score;
      }
    });
    return (bestColumn, bestScore);
  }

  /// Finds all the valid moves sorted by priority
  Moves findValidMoves() {
    HashMap<Move, double> validMoves = HashMap();

    // Columns
    for (int i = 0; i < columns.length; i++) {
      for (int j = 0; j < columns[i].length; j++) {
        if (columns[i][j].revealed) {
          List<PlayingCard> cards = columns[i].sublist(j);
          (int, double) record = determineBestColumn(i, cards);
          if (record.$1 != -1) {
            Move move = Move(cards: cards, sourceIndex: i, destinationIndex: record.$1, revealedCard: (j >= 1 && !columns[i][j].revealed));
            validMoves[move] = record.$2 * 3.0;
          }
        }
      }
    }

    // Check if waste card is movable
    if (wasteDeck.isNotEmpty) {
      PlayingCard card = wasteDeck.last;
      (int, double) record = determineBestColumn(7, [card]);
      if (record.$1 != -1) {
        Move move = Move(cards: [card], sourceIndex: 7, destinationIndex: record.$1, revealedCard: false);
        validMoves[move] = record.$2 * 1.5;
      }
    }

    // Check if stock deck has a movable card
    for (int i = 0; i < stockDeck.length; i++) {
      PlayingCard card = stockDeck[i];
      (int, double) record = determineBestColumn(8, [card]);
      if (record.$1 != -1) {
        Move move = Move(cards: stockDeck.sublist(0, min(i + 1, stockDeck.length)), sourceIndex: 8, destinationIndex: 7, revealedCard: false);
        validMoves[move] = record.$2 - (i * 4.5);
      }
    }
    // Check if reset stock deck (from waste deck) has a movable card
    for (int i = 0; i < wasteDeck.length; i++) {
      PlayingCard card = wasteDeck[i];
      (int, double) record = determineBestColumn(7, [card]);
      if (record.$1 != -1) {
        Move move = Move(cards: wasteDeck.sublist(0, min(i + 1, wasteDeck.length)), sourceIndex: 7, destinationIndex: 8, revealedCard: false);
        validMoves[move] = record.$2 - (i * 4.5) - stockDeck.length;
      }
    }

    Move? lastMove = widget.moves.peek;
    for (int i = 0; i < validMoves.entries.length; i++) {
      MapEntry<Move, double> entry = validMoves.entries.toList()[i];
      Move move = entry.key;
      if (lastMove != null && move.destinationIndex == lastMove.sourceIndex && move.sourceIndex == lastMove.destinationIndex) {
        validMoves[move] = validMoves[move]! - 10;
      }
    }

    // Return a list of prioritized moves
    Map<Move, double> sortedMap = Map.fromEntries(
        validMoves.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value))
    );

    // Debug printing
    String possibleMovesString = "Possible moves:\n";
    for (int i = 0; i < sortedMap.entries.length; i++) {
      MapEntry<Move, double> entry = sortedMap.entries.toList()[i];
      possibleMovesString += '${entry.key.sourceIndex} to ${entry.key.destinationIndex} (';
      for (PlayingCard card in entry.key.cards) {
        possibleMovesString += '${card.name()}${entry.key.cards.last != card? ', ': ''}';
      }
      possibleMovesString += ')';
      possibleMovesString += ': ${entry.value}${i < sortedMap.entries.length - 1? '\n': ''}';
    }
    logger.finer(possibleMovesString);

    Moves moves = Moves(gameMode: widget.gameMode);
    moves.set(sortedMap.keys.toList());
    return moves;
  }

  bool checkAllCardsRevealed() {
    // return true;
    for (int i = 0; i < columns.length; i++) {
      for (int j = 0; j < columns[i].length; j++) {
        if (!columns[i][j].revealed) {
          return false;
        }
      }
    }
    return true;
  }

  void checkWin() {
    Moves validMoves = findValidMoves();
    Move? move = validMoves.pop();
    if (move != null) {
      if (move.sourceIndex == 8) {
        logger.fine('Next: reveal stock (${validMoves.size + 1} possible moves)');
      } else {
        logger.fine('Next: move ${move.cards.first.name()} from ${move.sourceIndex} to ${move.destinationIndex} (${validMoves.size + 1} possible moves)');
      }
    } else {
      logger.fine('No next moves found');
    }
    if (diamondsFoundation.length +
        heartsFoundation.length +
        clubsFoundation.length +
        spadesFoundation.length ==
        52) {
      handleWin();
    }
  }

  Future<void> handleAutoWin() async {
    Moves validMoves = findValidMoves();
    do {
      if (!widget.autoMove) {
        return;
      }
      for (int i = 0; i < validMoves.size; i++) {
        if (!widget.autoMove) {
          return;
        }
        Move? move = validMoves.pop();
        if (move != null) {
          if ((move.sourceIndex == 7 && move.destinationIndex == 8) ||
              (move.sourceIndex == 8 && move.destinationIndex == 7)) {
            handleStockDeck(startTimer: false);
          } else {
            moveCards(move.cards, move.sourceIndex, destinationIndex: move.destinationIndex, startTimer: false);
          }
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      validMoves = findValidMoves();
    } while (validMoves.isNotEmpty);
  }

  void handleStockDeck({startTimer = true}) {
    setState(() {
      if (startTimer && !widget.timer.isTimerRunning()) {
        widget.timer.startTimer(reset: false);
      }
      if (stockDeck.isEmpty && wasteDeck.isNotEmpty) {
        stockDeck.addAll(wasteDeck.map((card) {
          return card
            ..revealed = false;
        }));
        wasteDeck.clear();
        Move move = Move(
            cards: stockDeck,
            sourceIndex: 7,
            destinationIndex: 8,
            revealedCard: false,
            resetStockDeck: true
        );
        widget.moves.push(move);
      } else if (stockDeck.isNotEmpty) {
        PlayingCard card = stockDeck.removeAt(0)
          ..revealed = true;
        wasteDeck.add(card);
        Move move = Move(
            cards: [card],
            sourceIndex: 8,
            destinationIndex: 7,
            revealedCard: false
        );
        widget.moves.push(move);
      }
    });
    checkWin();
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

  @override
  Map toJson() => {
    'columns': columns,
    'waste': wasteDeck,
    'stock': stockDeck,
    'spades': spadesFoundation,
    'hearts': heartsFoundation,
    'clubs': clubsFoundation,
    'diamonds': diamondsFoundation,
    'initialized': widget.initialized,
    'seed': widget.seed,
    'moves': widget.moves,
    'timer': widget.timer.toJson()
  };

  @override
  void fromJson(Map<String, dynamic> json) {
  }
}