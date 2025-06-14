// lib/tools/free_body_diagram_screen.dart
import 'package:flutter/material.dart';

class FreeBodyDiagramScreen extends StatelessWidget {
  const FreeBodyDiagramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagrama de Cuerpo Libre'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.line_weight,
                size: 80,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
              const SizedBox(height: 24),
              Text(
                'Crea tus Diagramas de Cuerpo Libre',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Aquí podrás dibujar fuerzas, vectores y objetos para analizar sistemas físicos. ¡La funcionalidad de dibujo interactivo estará disponible pronto!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 32),
              // Placeholder for the drawing canvas area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'Área de Dibujo (Próximamente)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
