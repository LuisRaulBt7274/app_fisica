import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/constants.dart';

class SimulatorsScreen extends StatelessWidget {
  const SimulatorsScreen({super.key});

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir $url';
      }
    } catch (e) {
      // Manejar error de forma silenciosa o mostrar snackbar
      debugPrint('Error al abrir URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simuladores de Física'),
        centerTitle: true,
      ),
      body:
          AppConstants.physicsSimulatorUrls.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.science, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay simuladores configurados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '¡Vuelve pronto para ver simuladores interactivos de física!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: AppConstants.physicsSimulatorUrls.length,
                itemBuilder: (context, index) {
                  final entry = AppConstants.physicsSimulatorUrls.entries
                      .elementAt(index);
                  final simulatorName = entry.key;
                  final simulatorUrl = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _launchURL(simulatorUrl),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    simulatorName,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Simulaciones interactivas de física para experimentar y aprender de forma visual.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Toca para abrir',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
