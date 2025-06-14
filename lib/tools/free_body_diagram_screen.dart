// Agregar funcionalidad básica de dibujo
import 'package:flutter/material.dart';

class FreeBodyDiagramScreen extends StatefulWidget {
  const FreeBodyDiagramScreen({super.key});

  @override
  State<FreeBodyDiagramScreen> createState() => _FreeBodyDiagramScreenState();
}

class _FreeBodyDiagramScreenState extends State<FreeBodyDiagramScreen> {
  List<Offset> points = [];
  List<String> forces = ['Peso', 'Normal', 'Fricción', 'Tensión'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagrama de Cuerpo Libre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() => points.clear()),
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDiagram),
        ],
      ),
      body: Column(
        children: [
          // Panel de herramientas de fuerzas
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forces.length,
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: Text(forces[index]),
                      onDeleted: () => _addForce(forces[index]),
                      deleteIcon: const Icon(Icons.add),
                    ),
                  ),
            ),
          ),
          // Área de dibujo
          Expanded(
            child: CustomPaint(
              painter: DiagramPainter(points),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    points.add(details.localPosition);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addForce(String force) {
    // Implementar lógica para añadir fuerzas
  }

  void _saveDiagram() {
    // Implementar guardado del diagrama
  }
}

class DiagramPainter extends CustomPainter {
  final List<Offset> points;

  DiagramPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
