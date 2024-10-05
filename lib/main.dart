
import 'package:flutter/material.dart';
import 'dart:math'; // Import for Random and pi
import 'package:confetti/confetti.dart'; // Import for confetti effect

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clickable Grid',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double _rows = 5;
  double _columns = 5;
  late List<List<bool>> _cellStates;
  int _progress = 3; // Example current progress
  int _total = 40; // Example total number
  Random _random = Random();
  int _starCount = 2; // Number of stars in AppBar
  late ConfettiController _confettiController; // Controller for confetti

  @override
  void initState() {
    super.initState();
    _initializeCellStates();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3)); // Confetti controller
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose confetti controller
    super.dispose();
  }

  void _initializeCellStates() {
    _cellStates = List.generate(_rows.toInt(), (row) {
      return List.generate(_columns.toInt(), (col) => false);
    });
  }

  void _resetCellStates(int newRows, int newColumns) {
    _cellStates = List.generate(newRows, (row) {
      return List.generate(newColumns, (col) => false);
    });
  }

  // Function to randomly update _progress and _total
  void _randomizeProgressAndTotal() {
    setState(() {
      // Generate random values between 1 and 10
      int factor1 = _random.nextInt(10) + 1; // random number between 1 and 10
      int factor2 = _random.nextInt(10) + 1; // random number between 1 and 10
      _total = factor1 * factor2;
      _progress = _random.nextInt(_total + 1); // Progress should be a valid number between 0 and _total
    });
  }


  bool _isPrime(int number) {
    if (number <= 1) return false;
    for (int i = 2; i <= sqrt(number); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  void _handleConfirm() {
    int turnedOnCells = 0;
    int totalCells = _rows.toInt() * _columns.toInt();

    // Count the number of turned-on cells
    for (var row in _cellStates) {
      for (var cell in row) {
        if (cell) turnedOnCells++;
      }
    }

    // Check if the condition is met
    if (turnedOnCells == _progress && totalCells == _total) {
      _showConfetti(); // Show confetti animation
    } else {
      _loseStar(); // Drop one star
    }
  }

  void _showConfetti() {
    _confettiController.play(); // Play confetti
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Congratulations! 🎉')));
  }

  void _loseStar() {
    if (_starCount > 0) {
      setState(() {
        _starCount--; // Decrease star count
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Try again! Lost one star.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(Icons.loop, size: 30, color: Colors.teal),
            onPressed: _randomizeProgressAndTotal,
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_starCount, (index) => Icon(Icons.star, size: 30, color: Colors.yellow)),
        ),
        actions: [SizedBox(width: 40)],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text("$_progress/$_total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                // ... Your slider and grid code here ...


                SizedBox(height: 16), // Add some space before sliders

            // Top horizontal slider for columns (points downward)
            SizedBox(
              width: 250,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: TriangleThumbShape(rotationAngle: pi),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                ),
                child: Slider(
                  value: _columns,
                  min: 1,
                  max: 10,
                  divisions: 19,
                  label: _columns.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _columns = value;
                      _resetCellStates(_rows.toInt(), _columns.toInt());
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left vertical slider for rows (points right)
                SizedBox(
                  width: 50,
                  height: 250,
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: TriangleThumbShape(rotationAngle: pi),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                      ),
                      child: Slider(
                        value: _rows,
                        min: 1,
                        max: 10,
                        divisions: 19,
                        label: _rows.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _rows = value;
                            _resetCellStates(_rows.toInt(), _columns.toInt());
                          });
                        },
                      ),
                    ),
                  ),
                ),
                // Grid container with GestureDetector
                GestureDetector(
                  behavior: HitTestBehavior.opaque, // Ensure the GestureDetector covers the area
                  onTapDown: (details) {
                    _handleTap(details.localPosition);
                  },
                  child: Container(
                    color: Colors.white,
                    height: 250,
                    width: 250,
                    child: CustomPaint(
                      painter: GridPainter(_rows.toInt(), _columns.toInt(), _cellStates),
                    ),
                  ),
                ),
                // Right vertical slider for rows (points left)
                SizedBox(
                  width: 50,
                  height: 250,
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: TriangleThumbShape(rotationAngle: 0),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                      ),
                      child: Slider(
                        value: _rows,
                        min: 1,
                        max: 10,
                        divisions: 19,
                        label: _rows.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _rows = value;
                            _resetCellStates(_rows.toInt(), _columns.toInt());
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Bottom horizontal slider for columns (points upwards)
            SizedBox(
              width: 250,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: TriangleThumbShape(),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                ),
                child: Slider(
                  value: _columns,
                  min: 1,
                  max: 10,
                  divisions: 19,
                  label: _columns.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _columns = value;
                      _resetCellStates(_rows.toInt(), _columns.toInt());
                    });
                  },
                ),
              ),
            ),
//




                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _handleConfirm,
                  icon: Icon(Icons.check, size: 30),
                  label: Text('Confirm', style: TextStyle(fontSize: 24)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          // Confetti widget overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.blue, Colors.red, Colors.yellow, Colors.green],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(Offset position) {
    double cellWidth = 250 / _columns;
    double cellHeight = 250 / _rows;
    int column = (position.dx / cellWidth).floor();
    int row = (position.dy / cellHeight).floor();

    if (row >= 0 && row < _rows.toInt() && column >= 0 && column < _columns.toInt()) {
      setState(() {
        _cellStates[row][column] = !_cellStates[row][column];
      });
    }
  }
}


// CustomPainter for drawing the grid
class GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final List<List<bool>> cellStates;

  GridPainter(this.rows, this.columns, this.cellStates);

  @override
  void paint(Canvas canvas, Size size) {
    double rowHeight = size.height / rows;
    double columnWidth = size.width / columns;

    // Draw cells based on their state
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        Rect cellRect = Rect.fromLTWH(
            col * columnWidth, row * rowHeight, columnWidth, rowHeight);
        Paint cellPaint = Paint()
          ..color = cellStates[row][col] ? Colors.green : Colors.red;
        canvas.drawRect(cellRect, cellPaint);
      }
    }

    // Draw grid lines
    Paint gridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      double dy = i * rowHeight;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    // Draw vertical lines
    for (int i = 0; i <= columns; i++) {
      double dx = i * columnWidth;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Always repaint on each frame
  }
}

// Custom shape for the triangle thumb
class TriangleThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double rotationAngle;

  TriangleThumbShape({this.thumbRadius = 6.0, this.rotationAngle = 0.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter? labelPainter,
        required RenderBox? parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()..color = sliderTheme.thumbColor ?? Colors.blue;

    // Draw an equilateral triangle centered on the thumb
    final Path path = Path();
    double height = thumbRadius * 2;
    double base = thumbRadius * 2;

    path.moveTo(center.dx, center.dy - height / 2);
    path.lineTo(center.dx - base / 2, center.dy + height / 2);
    path.lineTo(center.dx + base / 2, center.dy + height / 2);
    path.close();

    // Rotate the triangle if needed
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawPath(path, paint);
    canvas.restore();
  }
}
