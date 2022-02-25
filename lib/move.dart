import 'package:solitaire/playing_card.dart';

class Move {
  List<PlayingCard> cards;
  int newColumnIndex;
  int previousColumnIndex;
  bool flippedNewCard;

  Move({
    required this.cards,
    required this.newColumnIndex,
    required this.previousColumnIndex,
    required this.flippedNewCard,
  });

  @override
  String toString() {
    return "{cards: $cards, newColumnIndex: $newColumnIndex, previousColumnIndex: $previousColumnIndex, flippedNewCard: $flippedNewCard}";
  }
}

class MoveStack {
  final list = <Move>[];

  void push(Move move) => list.add(move);

  Move? pop() => (isEmpty) ? null : list.removeLast();
  Move? get peek => (isEmpty) ? null : list.last;

  int get size => list.length;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => list.toString();
}