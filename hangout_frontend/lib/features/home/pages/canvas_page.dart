import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:hangout_frontend/features/hobby/pages/hobby_page.dart';
import 'package:hangout_frontend/features/home/pages/home_page.dart';

class CanvasPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const CanvasPage(),
      );

  const CanvasPage({Key? key}) : super(key: key);

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  List<DrawingPoint?> drawingPoints = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[400]!,
                Colors.green[400]!,
              ],
            ),
          ),
        ),
        title: const Text("Canvas Area", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              setState(() {
                drawingPoints.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
          ),
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanUpdate: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanEnd: (details) {
              setState(() {
                drawingPoints.add(null);
              });
            },
            child: CustomPaint(
              painter: _DrawingPainter(drawingPoints),
              size: Size.infinite,
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorButton(Colors.black),
                    const SizedBox(width: 8),
                    _buildColorButton(Colors.red),
                    const SizedBox(width: 8),
                    _buildColorButton(Colors.blue),
                    const SizedBox(width: 8),
                    _buildColorButton(Colors.green),
                    const SizedBox(width: 8),
                    _buildColorButton(Colors.yellow),
                    const SizedBox(width: 12),
                    Icon(Icons.line_weight, size: 16, color: Colors.grey[700]),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        min: 1,
                        max: 20,
                        value: strokeWidth,
                        onChanged: (value) {
                          setState(() {
                            strokeWidth = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: height * 0.09,
        width: height * 0.10,
        child: FloatingActionButton(
          heroTag: "btn1_Canvas",
          shape: CircleBorder(),
          child: Icon(
            Icons.brush,
            size: width * 0.14,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[400],
          onPressed: () {
            setState(() {
              drawingPoints.clear();
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: height * 0.08,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.green[400]!,
            ],
          ),
        ),
        child: BottomAppBar(
          elevation: 0,
          padding: EdgeInsets.zero,
          height: height * 0.06,
          color: Colors.transparent,
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.only(left: 60),
                    minWidth: 0,
                    onPressed: () {
                      Navigator.push(context, HomePage.route());
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month,
                            size: width * 0.12, color: Colors.white),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.only(right: 60),
                    minWidth: 0,
                    onPressed: () {
                      Navigator.push(context, HobbyPage.route());
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.downhill_skiing,
                            size: width * 0.12, color: Colors.white),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.black,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i]!.offset,
          drawingPoints[i + 1]!.offset,
          drawingPoints[i]!.paint,
        );
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        canvas.drawPoints(
          ui.PointMode.points,
          [drawingPoints[i]!.offset],
          drawingPoints[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return true;
  }
}
