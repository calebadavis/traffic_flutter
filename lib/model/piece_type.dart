library traffic;

import 'board.dart';

class PieceType
{

  PieceType(int h, int w, Board b)
  {
    height = h;
    width = w;
    List<PieceType> types = b.getTypes();
    id = types.length;
    types.add(this);
  }

  int getHeight()
  {
    return height;
  }

  int getWidth()
  {
    return width;
  }

  int getId()
  {
    return id;
  }
  int height = 0;
  int width = 0;
  int id = -1;
}