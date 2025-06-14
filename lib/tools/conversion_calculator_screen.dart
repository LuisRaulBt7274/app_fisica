import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/constants.dart';

class ConversionCalculatorController extends GetxController {
  final TextEditingController inputValueController = TextEditingController();
  final RxString selectedCategory = 'Longitud'.obs;
  final RxString selectedInputUnit = ''.obs;
  final RxString selectedOutputUnit = ''.obs;
  final RxString result = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Inicializar con la primera categoría disponible
    if (AppConstants.physicsUnits.isNotEmpty) {
      selectedCategory.value = AppConstants.physicsUnits.keys.first;
      _updateUnitsForCategory();
    }
    inputValueController.addListener(convertUnits);
  }

  @override
  void onClose() {
    inputValueController.removeListener(convertUnits);
    inputValueController.dispose();
    super.onClose();
  }

  List<String> get availableCategories =>
      AppConstants.physicsUnits.keys.toList();

  List<String> get availableUnitsForCategory {
    final category = selectedCategory.value;
    if (AppConstants.physicsUnits.containsKey(category)) {
      return AppConstants.physicsUnits[category]!.keys.toList();
    }
    return [];
  }

  void _updateUnitsForCategory() {
    final units = availableUnitsForCategory;
    if (units.isNotEmpty) {
      selectedInputUnit.value = units.first;
      selectedOutputUnit.value = units.length > 1 ? units[1] : units.first;
    }
  }

  void updateCategory(String? category) {
    if (category != null && category != selectedCategory.value) {
      selectedCategory.value = category;
      _updateUnitsForCategory();
      convertUnits();
    }
  }

  void convertUnits() {
    final double? inputValue = double.tryParse(inputValueController.text);

    if (inputValue == null || inputValueController.text.isEmpty) {
      result.value = 'Ingrese un valor numérico';
      return;
    }

    final String category = selectedCategory.value;
    final String fromUnit = selectedInputUnit.value;
    final String toUnit = selectedOutputUnit.value;

    if (fromUnit == toUnit) {
      result.value = '${inputValue.toStringAsFixed(6)} $toUnit';
      return;
    }

    // Conversión especial para temperatura
    if (category == 'Temperatura') {
      final double convertedValue = _convertTemperature(
        inputValue,
        fromUnit,
        toUnit,
      );
      result.value = '${convertedValue.toStringAsFixed(2)} $toUnit';
      return;
    }

    // Conversión normal usando factores de conversión
    final Map<String, double>? categoryUnits =
        AppConstants.physicsUnits[category];
    if (categoryUnits != null &&
        categoryUnits.containsKey(fromUnit) &&
        categoryUnits.containsKey(toUnit)) {
      // Convertir a unidad base, luego a unidad objetivo
      final double baseValue = inputValue * categoryUnits[fromUnit]!;
      final double convertedValue = baseValue / categoryUnits[toUnit]!;

      result.value = '${convertedValue.toStringAsFixed(6)} $toUnit';
    } else {
      result.value = 'Error en la conversión';
    }
  }

  double _convertTemperature(double value, String from, String to) {
    // Convertir todo a Kelvin primero, luego a la unidad objetivo
    double kelvinValue;

    switch (from) {
      case 'K':
        kelvinValue = value;
        break;
      case 'C':
        kelvinValue = value + 273.15;
        break;
      case 'F':
        kelvinValue = (value - 32) * 5 / 9 + 273.15;
        break;
      default:
        return 0;
    }

    switch (to) {
      case 'K':
        return kelvinValue;
      case 'C':
        return kelvinValue - 273.15;
      case 'F':
        return (kelvinValue - 273.15) * 9 / 5 + 32;
      default:
        return 0;
    }
  }

  void updateInputUnit(String? unit) {
    if (unit != null) {
      selectedInputUnit.value = unit;
      convertUnits();
    }
  }

  void updateOutputUnit(String? unit) {
    if (unit != null) {
      selectedOutputUnit.value = unit;
      convertUnits();
    }
  }
}

class ConversionCalculatorScreen extends StatelessWidget {
  const ConversionCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConversionCalculatorController controller = Get.put(
      ConversionCalculatorController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertidor de Unidades Físicas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de categoría
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: const InputDecoration(
                  labelText: 'Categoría de Unidad',
                  border: OutlineInputBorder(),
                ),
                items:
                    controller.availableCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: controller.updateCategory,
              ),
            ),

            const SizedBox(height: 20),

            // Campo de entrada
            TextField(
              controller: controller.inputValueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor a convertir',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Selectores de unidades
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value:
                          controller.selectedInputUnit.value.isEmpty
                              ? null
                              : controller.selectedInputUnit.value,
                      decoration: const InputDecoration(
                        labelText: 'De',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          controller.availableUnitsForCategory.map((
                            String unit,
                          ) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: controller.updateInputUnit,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_right_alt, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value:
                          controller.selectedOutputUnit.value.isEmpty
                              ? null
                              : controller.selectedOutputUnit.value,
                      decoration: const InputDecoration(
                        labelText: 'A',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          controller.availableUnitsForCategory.map((
                            String unit,
                          ) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                      onChanged: controller.updateOutputUnit,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Resultado
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  'Resultado: ${controller.result.value}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Información adicional
            Text(
              'Convierte entre diferentes unidades físicas organizadas por categorías. Todas las conversiones son precisas y basadas en estándares internacionales.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
