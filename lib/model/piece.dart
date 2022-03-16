library traffic;

import 'piece_type.dart';
import 'board.dart';

class Piece
{

  Piece(PieceType type, Board b, int leftPos, int topPos) :
    type = type,
    leftPos = leftPos,
    topPos = topPos,
    moves = [],
    pID = b.getPieces().length
  {
    List<Piece> pieces = b.getPieces();
    pieces.add(this);
    b.markBoard(this, true);
  }

  PieceType getType()
  {
    return type;
  }

  int getLeftPos()
  {
    return leftPos;
  }

  void setLeftPos(int leftPos)
  {
    this.leftPos = leftPos;
  }

  int getTopPos()
  {
    return topPos;
  }

  void setTopPos(int topPos)
  {
    this.topPos = topPos;
  }

  int getpID()
  {
    return pID;
  }

  List<MoveDir> getMoves()
  {
    return moves;
  }
  PieceType type;
  int leftPos;
  int topPos;
  int pID;
  List<MoveDir> moves;
}