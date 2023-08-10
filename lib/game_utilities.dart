import 'package:solitaire/playing_card.dart';

class GameUtilities {
  static int countHiddenCards(List<PlayingCard> cards) {
    int hiddenCount = 0;
    for (PlayingCard card in cards) {
      if (!card.revealed) {
        hiddenCount++;
      }
    }
    return hiddenCount;
  }
}