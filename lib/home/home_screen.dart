import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authController = AuthController();

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
                await _authController.signOut();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo y estadísticas rápidas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido de vuelta!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Continúa tu aprendizaje con StudyAI',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Exámenes',
                            '12',
                            Icons.quiz,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Ejercicios',
                            '45',
                            Icons.calculate,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Flashcards',
                            '89',
                            Icons.style,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Herramientas de Estudio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Grid de herramientas principales
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  'Crear Examen',
                  'Genera exámenes personalizados con IA',
                  Icons.quiz_outlined,
                  Colors.blue,
                  () => context.push('/exam/create'),
                ),
                _buildFeatureCard(
                  'Resolver Ejercicios',
                  'Ayuda paso a paso con IA',
                  Icons.calculate_outlined,
                  Colors.green,
                  () => context.push('/exercises'),
                ),
                _buildFeatureCard(
                  'Flashcards',
                  'Memoriza con tarjetas inteligentes',
                  Icons.style_outlined,
                  Colors.orange,
                  () => context.push('/flashcards'),
                ),
                _buildFeatureCard(
                  'Subir Documentos',
                  'Analiza tus documentos con IA',
                  Icons.upload_file_outlined,
                  Colors.purple,
                  () => context.push('/documents'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Herramientas Adicionales',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Lista de herramientas adicionales
            _buildToolTile(
              'Simuladores Web',
              'Accede a simuladores educativos',
              Icons.science_outlined,
              Colors.teal,
              () => context.push('/simulators'),
            ),
            const SizedBox(height: 8),
            _buildToolTile(
              'Diagramas de Cuerpo Libre',
              'Crea diagramas de física',
              Icons.account_tree_outlined,
              Colors.indigo,
              () => context.push('/free-body-diagram'),
            ),
            const SizedBox(height: 8),
            _buildToolTile(
              'Calculadora de Conversiones',
              'Convierte unidades fácilmente',
              Icons.swap_horiz_outlined,
              Colors.red,
              () => context.push('/conversion-calculator'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
