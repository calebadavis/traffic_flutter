library traffic;

import 'move_node.dart';
import 'move_trie.dart';
import 'piece.dart';
import 'piece_type.dart';

class Board {

  static const int DEFAULT_HEIGHT = 5;
  static const int DEFAULT_WIDTH = 4;

  int _height, _width;
  List<List<int>> _aBoard = [];

  List<Piece> _pieces;
  List<PieceType> _types;

  List<int> _solvedBoard = [];
  late List<int> _startingBoard ;

  Board({int height = DEFAULT_HEIGHT, int width = DEFAULT_WIDTH})
      :
        _height = height,
        _width = width,
        _types = [],
        _pieces = [];

  void initBoard() {
    for (int row = 0; row < _height; ++row) {
      _aBoard.add(List<int>.generate(_width, (int x) => -1, growable: false));
    }
    
    _solvedBoard = List<int>.generate(getHeight() * getWidth(), (int x) => -1, growable: false);
    
    // For now, we just hardcode the types and starting board setup:

    PieceType(1, 2, this);
    PieceType(2, 1, this);
    PieceType(1, 1, this);
    PieceType(2, 2, this);

    Piece(_types[0], this, 1, 0); // 2x1 piece in top row, second from left
    Piece(_types[1], this, 0, 1); // 1x2 piece in second row, leftmost column
    Piece(_types[1], this, 3, 1); // 1x2 piece in second row, rightmost column
    Piece(_types[1], this, 0, 3); // 1x2 piece in fourth row, leftmost column
    Piece(_types[1], this, 3, 3); // 1x2 piece in fourth row, rightmost column
    Piece(_types[2], this, 1, 1); // 1x1 piece in second row, second column
    Piece(_types[2], this, 2, 1); // 1x1 piece in second row, third column
    Piece(_types[2], this, 1, 2); // 1x1 piece in third row, second column
    Piece(_types[2], this, 2, 2); // 1x1 piece in third row, third column
    Piece(_types[3], this, 1, 3); // 2x2 piece in fourth row, second column

    _solvedBoard[1] = 3;
    _solvedBoard[4] = 2;
    _solvedBoard[7] = 2;
    _solvedBoard[8] = 2;
    _solvedBoard[9] = 0;
    _solvedBoard[11] = 2;
    _solvedBoard[12] = 1;
    _solvedBoard[13] = 1;
    _solvedBoard[14] = 1;
    _solvedBoard[15] = 1;

    for (Piece p in _pieces) storeMoves(p);
    
    _startingBoard = pieceLocs();
    
    for (List<int> row in _aBoard)
      print(row);
  }

  // Either put a piece on, or remove a piece from, the board
  // If 'place' is true, place the piece on the board
  // If 'place is false, fill that piece's spot on the board with -1s
  void markBoard(Piece p, bool place) {
    PieceType pt = p.getType();
    int id = pt.getId();
    int height = pt.getHeight();
    int width = pt.getWidth();
    int topPos = p.getTopPos();
    int leftPos = p.getLeftPos();

    for (int row = topPos; row < topPos + height; ++row) {
      for (int col = leftPos; col < leftPos + width; ++col) {
        _aBoard[row][col] = (place) ? id : -1;
      }
    }
  }

  bool _doesFit(Piece p, int leftPos, int topPos) {
    // Check if the piece would be off the bounds of the board
    if (
    leftPos < 0
        || topPos < 0
        || p.getType().getWidth() + leftPos > _width
        || p.getType().getHeight() + topPos > _height
    )
      return false;

    // Check that all the squares occupied by the piece are vacant
    for (int row = topPos; row < topPos + p.getType().getHeight(); ++row) {
      for (int col = leftPos; col < leftPos + p.getType().getWidth(); ++col) {
        if (_aBoard[row][col] != -1) return false;
      }
    }

    // If the piece is entirely in the bounds of the board, and all its
    // squares are vacant, then it fits
    return true;
  }

  bool move(Piece p, MoveDir dir) {

    bool ret = true;

    // Clear the piece from the board array
    markBoard(p, false);

    PieceType pType = p.getType();
    int pTop = p.getTopPos();
    int pLeft = p.getLeftPos();
    int pHeight = pType.getHeight();
    int pWidth = pType.getWidth();

    // The logic to slide a piece differs based on the direction
    switch (dir) {

    // Attempting to slide the piece to the left:
      case MoveDir.LEFT:
      // First make sure the piece isn't on the left edge
        if (pLeft == 0) {
          ret = false;
          break;
        }

        // look at each row occupied by the piece
        for (int iRow = pTop; iRow < pTop + pHeight; ++iRow) {
          // Check that the new spot to be occupied is clear
          if (_aBoard[iRow][pLeft - 1] != -1) {
            ret = false;
            break;
          }

          // Mark the spots to be occupied on the board array
          for (int iCol = pLeft -1; iCol < pLeft + pWidth - 1; ++iCol) {
            _aBoard[iRow][iCol] = pType.getId();
          }
        }

        // update the state of the piece to its new location
        p.setLeftPos(pLeft - 1);
        break;

      case MoveDir.RIGHT:

      // First make sure the piece isn't on the right edge
        if (pLeft + pWidth > _width - 1) {
          ret = false;
          break;
        }

        // look at each row occupied by the piece
        for (int iRow = pTop; iRow < pTop + pHeight; ++iRow) {

          // Check that the new spot to be occupied is clear
          if (_aBoard[iRow][pLeft + pWidth] != -1) {
            ret = false;
            break;
          }

          // Mark the spots to be occupied on the board array
          for (int iCol = pLeft + 1; iCol < pLeft + pWidth + 1; ++iCol) {
            _aBoard[iRow][iCol] = pType.getId();
          }
        }

        // update the state of the piece to its new location
        p.setLeftPos(pLeft + 1);
        break;

      case MoveDir.UP:
      // First make sure the piece isn't on the top edge
        if (pTop == 0) {
          ret = false;
          break;
        }

        // look at each column occupied by the piece
        for (int iCol = pLeft; iCol < pLeft + pWidth; ++iCol) {

          // Check that the new spot to be occupied is clear
          if (_aBoard[pTop - 1][iCol] != -1) {
            ret = false;
            break;
          }

          // Mark the spots to be occupied on the board array
          for (int iRow = pTop - 1; iRow < pTop + pHeight - 1; ++iRow) {
            _aBoard[iRow][iCol] = pType.getId();
          }
        }

        // update the state of the piece to its new location
        p.setTopPos(pTop - 1);
        break;

      case MoveDir.DOWN:

      // First make sure the piece isn't on the bottom edge
        if (pTop + pHeight  + 1 > _height) {
          ret = false;
          break;
        }

        // look at each column occupied by the piece
        for (int iCol = pLeft; iCol < pLeft + pWidth; ++iCol) {

          // Check that the new spot to be occupied is clear
          if (_aBoard[pTop + pHeight][iCol] != -1) {
            ret = false;
            break;
          }

          // Mark the spots to be occupied on the board array
          for (int iRow = pTop + 1; iRow < pTop + pHeight + 1; ++iRow) {
            _aBoard[iRow][iCol] = pType.getId();
          }
        }

        // update the state of the piece to its new location
        p.setTopPos(pTop + 1);

        break;

      default:
        break;

    }

    if (!ret) {

      // if the move failed, restore board array
      markBoard(p, true);

    } else {

      // If the move was successful, store the set of possible next moves
      for (Piece nextP in _pieces) {
        storeMoves(nextP);
      }

    }

    return ret;
  }

  void reset(MoveNode mn) {

    // Get the new board layout
    List<int> aPieces = mn.getPieces();

    int pID, row, col;
    Piece p;

    // Clear the board
    for (int iRow = 0; iRow < _height; ++iRow)
      for (int iCol = 0; iCol < _width; ++iCol)
        _aBoard[iRow][iCol] = -1;

    // For each spot in the layout
    for (int i = 0; i < aPieces.length; ++i) {

      // If no Piece in the spot, move to the next
      if ((pID = aPieces[i]) == -1)
        continue;

      // retrieve the Piece occupying the spot
      p = _pieces[pID];

      // Calculate its 2-D position
      row = i ~/ _width;
      col = i % _width;

      // Set the Piece's position values
      p.setTopPos(row);
      p.setLeftPos(col);

      // Place the Piece on the board
      markBoard(p, true);
    }
  }

  bool matches(List<int>pids, List<int> types) {

  int pID, tID;

  // for each item in the board layout array
  for (int i = 0, size = pids.length; i < size; ++i) {

    // see if the position in the array contains a piece
    pID = pids[i];

    // If the position array says there's no piece there, but the types
    // array shows a piece type, then the two layouts are not a match
    if (pID == -1)
    if (types[i] != -1) return false;
    else continue;

    // Reaching here means the position array shows a piece there
    // Get the piece by its id, get its type, and check that the typeID
    // matches the one specified in the type array at the same position
    tID = _pieces[pID].getType().getId();
    if ( tID != types[i])
    return false;
  }

  // We've walked all the positions, and each was a match. Done!
  return true;
  }

  List<int> pieceLocs() {

    // Create a flattened array to represent the board
    List<int> ret = List<int>.generate(_height * _width, (int x) => -1, growable: false);

    // Fill the board with piece types at the top-left corner of each
    // piece
    for (Piece p in _pieces) {
      ret[p.getTopPos() * _width + p.getLeftPos()] = p.getpID();
    }

    // Return the newly filled-in layout array
    return ret;
  }

  int getHeight() {
    return _height;
  }

  int getWidth() {
    return _width;
  }

  List<PieceType> getTypes() {
    return _types;
  }

  List<Piece> getPieces() {
    return _pieces;
  }

  List<int> getSolvedBoard() {
    return _solvedBoard;
  }

  List<int> getStartingBoard() {
    return _startingBoard;
  }

  void storeMoves(Piece p) {
    // Conceptually this method 'picks up' the piece from the board array,
    // then checks if the spots the piece would cover are clear in each of
    // the four possible directions.

    // Clear out the old stored moves
    p.getMoves().clear();

    // Empty out the spots occupied by the piece
    markBoard(p, false);

    // Try placing the piece left
    if (_doesFit(p, p.getLeftPos() - 1, p.getTopPos()))
      p.getMoves().add(MoveDir.LEFT);

    // Try right
    if (_doesFit(p, p.getLeftPos() + 1, p.getTopPos()))
      p.getMoves().add(MoveDir.RIGHT);

    // Try up
    if (_doesFit(p, p.getLeftPos(), p.getTopPos() - 1))
      p.getMoves().add(MoveDir.UP);

    // Try down
    if (_doesFit(p, p.getLeftPos(), p.getTopPos() + 1))
      p.getMoves().add(MoveDir.DOWN);

    // Restore the spots occupied by the piece
    markBoard(p, true);

  }

  MoveNode? solve() {
    return
      solveIter(_solvedBoard);
    //solveRec(_solvedBoard);
  }

  MoveNode? solveIter(List<int> solution) {

    // Initialize the trie of previously encountered layouts
    MoveTrie.init(this);
    MoveTrie tries = MoveTrie();

    // As we discover moves available, defer nodes for those moves in a
    // pending list
    List<MoveNode> pending = [];

    // The current board layout
    List<int> locs = pieceLocs();

    // allocate the root MoveNode to match the current board
    MoveNode root = MoveNode(null, null, MoveDir.NONE, locs);

    // For each available move, add that move to the pending list
    for (MoveNode n in _getNextMoves(root, locs)) {
      pending.add(n);
    }

    // As we remove pending moves, store each in 'next'
    MoveNode? next = null;

    // Keep removing nodes until none are left
    while(pending.length > 0) {

      // Remove the earliest move first
      next = pending.removeAt(0);

      // reset the board layout to match that move, and make the move
      reset(next);
      move(_pieces[next.getpID()], next.getDir());

      // check if the move resulted in a solved configuration
      locs = pieceLocs();
      if (matches(locs, solution)) {

        // a match means we're almost done...
        // but the state of the board AFTER the final move still isn't
        // in the tree of moves (MoveNode only stores the state PRIOR
        // to making the move). So we construct a dummy node
        // representing this final configuration, and stick it on the
        // bottom of the solved branch of the tree
        next = MoveNode(next, null, MoveDir.NONE, locs);
        return next;
      }

      // only add child moves to the pending list if the new layout is
      // one we haven't seen before
      if (!tries.getRoot().addBoard(locs, 0, this)) {
        for (MoveNode n in _getNextMoves(next, locs)) {
          pending.add(n);
          print('Pending moves: ${pending.length}');
        }
      }
    }

    // Reaching here means we've exhausted all moves - the board is
    // unsolvable!
    return null;
  }

  /**
   * Helper method to retrieve the next possible moves from the current
   * board. To minimize computation time, assumes the caller has previously
   * called {@link #pieceLocs()}, passing the returned array as parameter
   * pieceLocs[]
   *
   * @param mn        the {@link #MoveNode} which resulted in the current board
   * @param pieceLocs the array of piece locations describing this board
   * @return          a Linked list of {@link #MoveNode} objects, representing
   * all possible moves available from this board configuration
   */
  List<MoveNode> _getNextMoves(MoveNode mn, List<int> pieceLocs) {
    // Create the list of nodes
    List<MoveNode> nextMoves = [];

    // For every piece
    for (Piece p in _pieces) {
      // Get the possible moves, and for each one
      for (MoveDir md in p.getMoves()) {
        // Add the move (as a MoveNode) to the move list
        nextMoves.add(new MoveNode(mn, p, md, pieceLocs));
      }
    }
    return nextMoves;
  }

  // For debugging purposes
  void printBoard() {
    for (List<int> row in _aBoard)
      print(row);
  }

}

enum MoveDir {
  LEFT,
  RIGHT,
  UP,
  DOWN,
  NONE
}
