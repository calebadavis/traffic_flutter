library traffic;

import 'board.dart';
import 'move_trie.dart';

class MoveTrieNode
{

  void allocChildren()
  {
    children = List<MoveTrieNode>.generate(MoveTrie.NUM_TYPES + 1, (int x) => MoveTrieNode(), growable: false);
  }

  bool addBoard(List<int> pieces, int pos, Board b)
  {
    if (pos == pieces.length) {
      return true;
    }
    bool ret = true;
    if (children == null) {
      allocChildren();
      ret = false;
    }
    int pID = pieces[pos];
    int type = ((pID == (-1)) ? MoveTrie.NUM_TYPES : b.getPieces()[pID].getType().getId());
    if (children?[type] == null) {
      children?[type] = new MoveTrieNode();
      ret = false;
    }
    bool? addResult = children?[type]?.addBoard(pieces, pos + 1, b);
    return addResult! && ret;
  }

  List<MoveTrieNode?>? getChildren()
  {
    return children;
  }

  List<MoveTrieNode?>? children;

}