import 'package:flutter/material.dart';

void main() {
  runApp(DrawingApp());
}

class DrawingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrawingScreen(),
    );
  }
}

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawnLine> _lines = [];
  List<DrawnLine> _undoneLines = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraserActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing App'),
      ),
      body: Column(
        children: [
          // Top section: Drawing area
          Expanded(
            flex: 9,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  _lines.add(DrawnLine(
                    renderBox.globalToLocal(details.globalPosition),
                    _isEraserActive ? Colors.white : _selectedColor,
                    _strokeWidth,
                  ));
                });
              },
              onPanEnd: (details) {
                _lines.add(DrawnLine(null, _selectedColor, _strokeWidth));
                _undoneLines.clear(); // Clear the redo stack
              },
              child: CustomPaint(
                painter: DrawingPainter(_lines),
                size: Size.infinite,
              ),
            ),
          ),
          // Bottom section: Controls and centered color picker
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              children: [
                _buildControls(),
                SizedBox(
                    height: 4.0), // Space between controls and color picker
                _buildCenteredColorPicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _undo() {
    setState(() {
      if (_lines.isNotEmpty) {
        _undoneLines.add(_lines.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_undoneLines.isNotEmpty) {
        _lines.add(_undoneLines.removeLast());
      }
    });
  }

  void _toggleEraser() {
    setState(() {
      _isEraserActive = !_isEraserActive;
    });
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: _lines.isNotEmpty ? _undo : null,
        ),
        IconButton(
          icon: Icon(Icons.redo),
          onPressed: _undoneLines.isNotEmpty ? _redo : null,
        ),
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _lines.clear();
              _undoneLines.clear();
            });
          },
        ),
        IconButton(
          icon: Icon(_isEraserActive ? Icons.brush : Icons.remove_circle),
          onPressed: _toggleEraser,
        ),
      ],
    );
  }

  Widget _buildCenteredColorPicker() {
    return Container(
      height: 50, // Compact height
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorButton(Colors.black),
            _buildColorButton(Colors.red),
            _buildColorButton(Colors.green),
            _buildColorButton(Colors.blue),
            _buildColorButton(Colors.yellow),
            _buildColorButton(Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          _isEraserActive = false; // Disable eraser when selecting a new color
        });
      },
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: _selectedColor == color && !_isEraserActive
              ? Border.all(width: 2.0, color: Colors.grey)
              : null,
        ),
      ),
    );
  }
}

class DrawnLine {
  Offset? point;
  Color color;
  double strokeWidth;

  DrawnLine(this.point, this.color, this.strokeWidth);
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;

  DrawingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].point != null && lines[i + 1].point != null) {
        Paint paint = Paint()
          ..color = lines[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = lines[i].strokeWidth;
        canvas.drawLine(lines[i].point!, lines[i + 1].point!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
