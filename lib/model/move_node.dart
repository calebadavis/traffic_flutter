library traffic;

import 'board.dart';
import 'piece.dart';

class MoveNode
{

  MoveNode(MoveNode? parent, Piece? p, MoveDir dir, List<int> pieces) :
    parent = parent,
    depth = ((parent == null) ? 0 : (parent.depth + 1)),
    dir = dir,
    pID = ((p == null) ? (-1) : p.getpID()),
    pieces = pieces
  {
  }

  MoveDir getDir()
  {
    return dir;
  }

  int getpID()
  {
    return pID;
  }

  MoveNode? getParent()
  {
    return parent;
  }

  void setParent(MoveNode parent)
  {
    this.parent = parent;
  }

  List<int> getPieces()
  {
    return pieces;
  }

  int getDepth()
  {
    return depth;
  }

  MoveDir dir;
  int pID;
  MoveNode? parent;
  List<int> pieces;
  int depth;
}