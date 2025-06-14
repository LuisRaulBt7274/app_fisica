import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_controller.dart';
import 'home_controller.dart'; // Import the HomeController

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authController = AuthController();
  final HomeController _homeController =
      HomeController(); // Initialize HomeController

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $userName'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await _homeController
                    .signOut(); // Use HomeController for signOut
                if (mounted) context.go('/login');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'profile', child: Text('Perfil')),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Configuración'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Cerrar Sesión'),
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
            const Text(
              '¡Bienvenido a StudyAI!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu compañero de estudio impulsado por IA.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Funciones Principales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  'Exámenes',
                  'Genera exámenes personalizados de Física.',
                  Icons.assignment,
                  Colors.blue,
                  _homeController.navigateToExams,
                ),
                _buildFeatureCard(
                  'Ejercicios',
                  'Practica con problemas de Física.',
                  Icons.lightbulb,
                  Colors.orange,
                  _homeController.navigateToExercises,
                ),
                _buildFeatureCard(
                  'Flashcards',
                  'Crea y revisa tarjetas de estudio.',
                  Icons.style,
                  Colors.purple,
                  _homeController.navigateToFlashcards,
                ),
                _buildFeatureCard(
                  'Documentos',
                  'Sube y analiza tus documentos de estudio.',
                  Icons.upload_file,
                  Colors.green,
                  _homeController.navigateToDocuments,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Herramientas Útiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildToolTile(
              'Simuladores',
              'Explora simulaciones interactivas de física.',
              Icons.science,
              Colors.red,
              _homeController.navigateToSimulators,
            ),
            _buildToolTile(
              'Diagrama de Cuerpo Libre',
              'Crea diagramas de cuerpo libre para problemas de mecánica.',
              Icons.precision_manufacturing,
              Colors.teal,
              _homeController.navigateToFreeBodyDiagram,
            ),
            _buildToolTile(
              'Calculadora de Conversión',
              'Convierte unidades rápidamente.',
              Icons.calculate,
              Colors.indigo,
              _homeController.navigateToConversionCalculator,
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

  Widget _buildToolTile(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}
