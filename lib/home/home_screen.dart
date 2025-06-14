import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Métodos de navegación directos
  void _navigateToExams() => context.go('/exams');
  void _navigateToExercises() => context.go('/exercises');
  void _navigateToFlashcards() => context.go('/flashcards');
  void _navigateToDocuments() => context.go('/documents');
  void _navigateToSimulators() => context.go('/simulators');
  void _navigateToFreeBodyDiagram() => context.go('/free-body-diagram');
  void _navigateToConversionCalculator() =>
      context.go('/conversion-calculator');

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Estudiante';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $userName'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                await _signOut();
                if (mounted) context.go('/login');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Configuración'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header mejorado para física
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido a PhysicsAI!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tu asistente inteligente para dominar la Física',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Herramientas de Estudio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  'Exámenes de Física',
                  'Genera exámenes personalizados con problemas de mecánica, termodinámica y más.',
                  Icons.assignment,
                  Colors.blue,
                  _navigateToExams,
                ),
                _buildFeatureCard(
                  'Resolver Problemas',
                  'Resuelve paso a paso problemas de física con explicaciones detalladas.',
                  Icons.calculate,
                  Colors.orange,
                  _navigateToExercises,
                ),
                _buildFeatureCard(
                  'Flashcards Físicas',
                  'Tarjetas de estudio con fórmulas, conceptos y leyes físicas.',
                  Icons.style,
                  Colors.purple,
                  _navigateToFlashcards,
                ),
                _buildFeatureCard(
                  'Analizar Documentos',
                  'Sube libros, apuntes o papers de física para análisis con IA.',
                  Icons.upload_file,
                  Colors.green,
                  _navigateToDocuments,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Simuladores y Calculadoras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildToolTile(
              'Simuladores de Física',
              'Experimenta con simulaciones de péndulos, ondas, circuitos y más.',
              Icons.science,
              Colors.red,
              _navigateToSimulators,
            ),
            _buildToolTile(
              'Diagrama de Cuerpo Libre',
              'Crea diagramas DCL para resolver problemas de estática y dinámica.',
              Icons.precision_manufacturing,
              Colors.teal,
              _navigateToFreeBodyDiagram,
            ),
            _buildToolTile(
              'Conversor de Unidades',
              'Convierte entre sistemas de unidades físicas (SI, CGS, Imperial).',
              Icons.swap_horiz,
              Colors.indigo,
              _navigateToConversionCalculator,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Agregar sección de progreso del estudiante
  Widget _buildProgressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu Progreso en Física',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildProgressItem('Mecánica Clásica', 0.75, Colors.blue),
            _buildProgressItem('Termodinámica', 0.45, Colors.red),
            _buildProgressItem('Electromagnetismo', 0.60, Colors.green),
            _buildProgressItem('Física Moderna', 0.30, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String topic, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(topic, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text('${(progress * 100).toInt()}%'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
