import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:traffic_flutter/model/board.dart';
import 'package:traffic_flutter/round_icon_button.dart';

import 'model/move_node.dart';
import 'model/piece.dart';
import 'model/piece_type.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Jam!',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black
      ),
      home: const MyHomePage(title: 'Traffic Jam! (aka. \'Klotski\')'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Board b;
  List<MoveNode> solution = [];
  List<int>? savedState;
  bool solved = false;
  bool _isSolving = false;

  _MyHomePageState() : b = Board();

  int curMove = 0;

  @override
  void initState() {
    super.initState();
    b.initBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildGrid(b),
            SizedBox(height: 25),
            Row(
                children: <Widget> [
                  RoundIconButton(
                      iconData: FontAwesomeIcons.expand,
                      onLongPressStart: (details) {
                        setState(() {
                          showSolved();
                        });
                      },
                      onLongPressEnd: (details) {
                        setState(() {
                          showSolved(revert: true);
                        });
                      },
                      onTap: () {}
                  ),
                  SizedBox(width: 10),
                  Container(
                      child: _isSolving ?
                      Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                      )
                      : RoundIconButton(
                          iconData: FontAwesomeIcons.running,
                          onTap: animateSolution
                      )
                  ),
                  SizedBox(width: 10),
                  RoundIconButton(
                      iconData: FontAwesomeIcons.dumpsterFire,
                      onTap: () {
                        setState(() {
                          b.loadFromArray(b.getStartingBoard());
                        });
                      }
                  )
                ]
            )
          ],
        ),
      ),
    );
  }

  void animateSolution() async {
    setState(() {
      _isSolving = true;
    });
    solved = await solve();
    setState(() {
      _isSolving = false;
    });

    while (curMove < solution.length - 1) {
      await Future.delayed(const Duration(milliseconds: 100), nextSolvedMove);
      print('Delaying 1/10 second before next move...: ${curMove}');
    }

  }

  void showSolved({bool revert = false}) {
    if (revert) {
      b.loadFromArray(savedState!);
      for (Piece p in b.getPieces()) b.storeMoves(p);
    } else {
      savedState = b.pieceLocs();
      b.loadFromArray(b.getSolvedBoardPIds());
    }
  }

  void _rearrange(MoveNode mn) {
    // First reposition the pieces to match the MoveNode
    b.reset(mn);

    // Calculate possible moves
    for (Piece p in b.getPieces())
      b.storeMoves(p);
  }

  Future<bool> solve() async {
    if (!solved) {
      MoveNode? solvedNode = b.solve();
      if (solvedNode != null) {
        solved = true;
        curMove = 1;
        for (MoveNode? mn = solvedNode; mn != null; mn = mn.getParent()) {
          // Add each successive move to the solution moves list
          solution.insert(0, mn);
        }
      } else solved = false;
    }
    nextSolvedMove();
    return solved;
  }

  void nextSolvedMove() {
    setState(() {
      if (curMove < solution.length -1)
        // Place the pieces in the next configuration
        _rearrange(solution[++curMove]);
      else {
        // otherwise we're at the solution layout, so clear it.
        solution.clear();
      }
    });
  }

  Widget buildGrid(Board b) {
    List<TrackSize>
      columnSizes = [],
      rowSizes = [];

    List<Widget> tiles = [];

    PieceType pt;

    for (int idx = 0; idx < b.getWidth(); ++idx) {
      columnSizes.add(1.fr);
    }
    for (int idx = 0; idx < b.getHeight(); ++idx) {
      rowSizes.add(1.fr);
    }

    for (Piece p in b.getPieces()) {
      pt = p.getType();

      tiles.add(
          GridPlacement(
            columnStart: p.getLeftPos(),
            columnSpan: pt.getWidth(),
            rowStart: p.getTopPos(),
            rowSpan: pt.getHeight(),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: generateButton(p)
            )
          )
      );
    }

    return Expanded(
      child: LayoutGrid(
          columnSizes: columnSizes,
          rowSizes: rowSizes,
          children: tiles
      ),
    );
  }

  Widget generateButton(Piece p) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onHorizontalDragEnd: (DragEndDetails dsd) {
                  print('horizontal swipe');
                  MoveDir dir = (dsd.primaryVelocity! < 0) ? MoveDir.LEFT : MoveDir.RIGHT;
                  if (p.getMoves().contains(dir))
                    setState(() {
                      b.move(p, dir);
                    });
                  solved = false;
                },
                onVerticalDragEnd: (DragEndDetails dsd) {
                  print('vertical swipe');
                  MoveDir dir = (dsd.primaryVelocity! < 0) ? MoveDir.UP : MoveDir.DOWN;
                  if (p.getMoves().contains(dir))
                    setState(() {
                      b.move(p, dir);
                    });
                  solved = false;
                },
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF0D47A1),
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}