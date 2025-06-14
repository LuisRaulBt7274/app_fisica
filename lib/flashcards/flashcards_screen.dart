import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';
import 'flashcard_model.dart';
import 'flashcards_service.dart';

class FlashcardsController extends GetxController {
  final FlashcardsService _flashcardsService = FlashcardsService();
  
  var isLoading = false.obs;
  var flashcardSets = <FlashcardSet>[].obs;
  var currentSet = Rxn<FlashcardSet>();
  var currentCardIndex = 0.obs;
  var isFlipped = false.obs;
  var studyMode = StudyMode.review.obs;
  var correctAnswers = 0.obs;
  var incorrectAnswers = 0.obs;
  var sessionCompleted = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadFlashcardSets();
  }
  
  void loadFlashcardSets() async {
    isLoading.value = true;
    try {
      flashcardSets.value = await _flashcardsService.getFlashcardSets();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las flashcards');
    } finally {
      isLoading.value = false;
    }
  }
  
  void startStudySession(FlashcardSet set, StudyMode mode) {
    currentSet.value = set;
    studyMode.value = mode;
    currentCardIndex.value = 0;
    isFlipped.value = false;
    correctAnswers.value = 0;
    incorrectAnswers.value = 0;
    sessionCompleted.value = false;
    
    // Mezclar cartas si está en modo de prueba
    if (mode == StudyMode.test) {
      currentSet.value!.flashcards.shuffle();
    }
  }
  
  void flipCard() {
    isFlipped.value = !isFlipped.value;
  }
  
  void nextCard() {
    if (currentCardIndex.value < currentSet.value!.flashcards.length - 1) {
      currentCardIndex.value++;
      isFlipped.value = false;
    } else {
      sessionCompleted.value = true;
    }
  }
  
  void previousCard() {
    if (currentCardIndex.value > 0) {
      currentCardIndex.value--;
      isFlipped.value = false;
    }
  }
  
  void markAnswer(bool isCorrect) {
    if (isCorrect) {
      correctAnswers.value++;
    } else {
      incorrectAnswers.value++;
    }
    
    // Marcar progreso de la carta
    currentSet.value!.flashcards[currentCardIndex.value].lastReviewed = DateTime.now();
    currentSet.value!.flashcards[currentCardIndex.value].isKnown = isCorrect;
    
    nextCard();
  }
  
  void resetSession() {
    currentCardIndex.value = 0;
    isFlipped.value = false;
    correctAnswers.value = 0;
    incorrectAnswers.value = 0;
    sessionCompleted.value = false;
  }
  
  void createNewSet(String title, String description) async {
    isLoading.value = true;
    try {
      final newSet = FlashcardSet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        flashcards: [],
        createdAt: DateTime.now(),
        lastStudied: null,
      );
      
      await _flashcardsService.createFlashcardSet(newSet);
      loadFlashcardSets();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el set de flashcards');
    } finally {
      isLoading.value = false;
    }
  }
}

enum StudyMode { review, test }

class FlashcardsScreen extends StatelessWidget {
  final FlashcardsController controller = Get.put(FlashcardsController());
  
  FlashcardsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards'),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateSetDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: LoadingIndicator());
        }
        
        if (controller.currentSet.value != null) {
          return _buildStudyView();
        }
        
        return _buildSetListView();
      }),
    );
  }
  
  Widget _buildSetListView() {
    if (controller.flashcardSets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No tienes sets de flashcards',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Crea tu primer set para comenzar a estudiar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Crear Set',
              onPressed: _showCreateSetDialog,
              backgroundColor: Colors.purple,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.flashcardSets.length,
      itemBuilder: (context, index) {
        final set = controller.flashcardSets[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                set.flashcards.length.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              set.title,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(set.description),
                SizedBox(height: 4),
                Text(
                  'Última revisión: ${set.lastStudied != null ? _formatDate(set.lastStudied!) : 'Nunca'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.play_arrow),
                    title: Text('Estudiar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: 'study',
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.quiz),
                    title: Text('Modo Prueba'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: 'test',
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: 'edit',
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Eliminar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: 'delete',
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'study':
                    controller.startStudySession(set, StudyMode.review);
                    break;
                  case 'test':
                    controller.startStudySession(set, StudyMode.test);
                    break;
                  case 'edit':
                    Get.toNamed('/flashcards/edit', arguments: set);
                    break;
                  case 'delete':
                    _showDeleteDialog(set);
                    break;
                }
              },
            ),
            onTap: () => controller.startStudySession(set, StudyMode.review),
          ),
        );
      },
    );
  }
  
  Widget _buildStudyView() {
    if (controller.sessionCompleted.value) {
      return _buildCompletionView();
    }
    
    final set = controller.currentSet.value!;
    final currentCard = set.flashcards[controller.currentCardIndex.value];
    
    return Column(
      children: [
        // Header con progreso
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.purple,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => controller.currentSet.value = null,
                    ),
                    Text(
                      set.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.currentCardIndex.value + 1} / ${set.flashcards.length}',
                      style: TextStyle(color: Colors.white),
                    ),
                    if (controller.studyMode.value == StudyMode.test)
                      Text(
                        'Correctas: ${controller.correctAnswers.value} | Incorrectas: ${controller.incorrectAnswers.value}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (controller.currentCardIndex.value + 1) / set.flashcards.length,
                  backgroundColor: Colors.purple[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
        
        // Flashcard
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: GestureDetector(
                onTap: controller.flipCard,
                child: Obx(() => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.isFlipped.value 
                              ? Icons.lightbulb 
                              : Icons.help_outline,
                            size: 32,
                            color: Colors.purple,
                          ),
                          SizedBox(height: 16),
                          Text(
                            controller.isFlipped.value ? 'Respuesta' : 'Pregunta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: Text(
                                controller.isFlipped.value 
                                  ? currentCard.answer 
                                  : currentCard.question,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          if (!controller.isFlipped.value)
                            Text(
                              'Toca para ver la respuesta',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ),
        ),
        
        // Botones de control
        Container(
          padding: EdgeInsets.all(16),
          child: Obx(() {
            if (!controller.isFlipped.value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: controller.currentCardIndex.value > 0 
                      ? controller.previousCard 
                      : null,
                    icon: Icon(Icons.arrow_back),
                    iconSize: 32,
                  ),
                  CustomButton(
                    text: 'Ver Respuesta',
                    onPressed: controller.flipCard,
                    backgroundColor: Colors.purple,
                  ),
                  IconButton(
                    onPressed: controller.currentCardIndex.value < set.flashcards.length - 1 
                      ? controller.nextCard 
                      : null,
                    icon: Icon(Icons.arrow_forward),
                    iconSize: 32,
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  if (controller.studyMode.value == StudyMode.test) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Incorrecto',
                            onPressed: () => controller.markAnswer(false),
                            backgroundColor: Colors.red,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Correcto',
                            onPressed: () => controller.markAnswer(true),
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: controller.currentCardIndex.value > 0 
                            ? controller.previousCard 
                            : null,
                          icon: Icon(Icons.arrow_back),
                          iconSize: 32,
                        ),
                        CustomButton(
                          text: controller.currentCardIndex.value < set.flashcards.length - 1 
                            ? 'Siguiente' 
                            : 'Finalizar',
                          onPressed: controller.nextCard,
                          backgroundColor: Colors.purple,
                        ),
                        IconButton(
                          onPressed: controller.currentCardIndex.value < set.flashcards.length - 1 
                            ? controller.nextCard 
                            : null,
                          icon: Icon(Icons.arrow_forward),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }
          }),
        ),
      ],
    );
  }
  
  Widget _buildCompletionView() {
    final set = controller.currentSet.value!;
    final total = set.flashcards.length;
    final correct = controller.correctAnswers.value;
    final percentage = total > 0 ? (correct / total * 100).toStringAsFixed(1) : '0.0';
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Colors.purple,
            ),
            SizedBox(height: 24),
            Text(
              '¡Sesión Completada!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              set.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 32),
            
            if (controller.studyMode.value == StudyMode.test) ...[
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Resultados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Correctas',
                          correct.toString(),
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Incorrectas',
                          controller.incorrectAnswers.value.toString(),
                          Colors.red,
                        ),
                        _buildStatItem(
                          'Porcentaje',
                          '$percentage%',
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
            
            Column(
              children: [
                CustomButton(
                  text: 'Estudiar de Nuevo',
                  onPressed: () => controller.resetSession(),
                  backgroundColor: Colors.purple,
                ),
                SizedBox(height: 12),
                CustomButton(
                  text: 'Volver a Sets',
                  onPressed: () => controller.currentSet.value = null,
                  backgroundColor: Colors.grey[300]!,
                  textColor: Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  void _showCreateSetDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('Crear Nuevo Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título del Set',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                controller.createNewSet(
                  titleController.text,
                  descriptionController.text,
                );
              }
            },
            child: Text('Crear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteDialog(FlashcardSet set) {
    Get.dialog(
      AlertDialog(
        title: Text('Eliminar Set'),
        content: Text('¿Estás seguro de que quieres eliminar "${set.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí implementarías la lógica para eliminar
              Get.back();
              Get.snackbar('Eliminado', 'Set eliminado correctamente');
            },
            child: Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }