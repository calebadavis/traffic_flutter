library traffic;

import 'board.dart';
import 'move_trie_node.dart';

class MoveTrie
{
  static int NUM_TYPES = -1;
  static int SQUARES = -1;
  static int EMPTY_VAL = (-1);
  static bool initialized = false;

  static void init(Board b)
  {
    if (initialized) {
      return;
    }
    NUM_TYPES = b.getTypes().length;
    SQUARES = (b.getHeight() * b.getWidth());
    initialized = true;
  }

  MoveTrie() : root = MoveTrieNode()
  {
    root.allocChildren();
  }

  MoveTrieNode getRoot()
  {
    return root;
  }
  MoveTrieNode root;
}