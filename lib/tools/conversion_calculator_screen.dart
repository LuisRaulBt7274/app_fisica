// lib/tools/conversion_calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversionCalculatorController extends GetxController {
  final TextEditingController inputValueController = TextEditingController();
  final RxString selectedInputUnit = 'Metros'.obs;
  final RxString selectedOutputUnit = 'Kilómetros'.obs;
  final RxString result = ''.obs;

  final Map<String, Map<String, double>> conversionFactors = {
    // Length
    'Metros': {
      'Metros': 1.0,
      'Kilómetros': 0.001,
      'Centímetros': 100.0,
      'Millas': 0.000621371,
      'Pies': 3.28084,
    },
    'Kilómetros': {
      'Metros': 1000.0,
      'Kilómetros': 1.0,
      'Centímetros': 100000.0,
      'Millas': 0.621371,
      'Pies': 3280.84,
    },
    'Centímetros': {
      'Metros': 0.01,
      'Kilómetros': 0.00001,
      'Centímetros': 1.0,
      'Millas': 0.0000062137,
      'Pies': 0.0328084,
    },
    'Millas': {
      'Metros': 1609.34,
      'Kilómetros': 1.60934,
      'Centímetros': 160934.0,
      'Millas': 1.0,
      'Pies': 5280.0,
    },
    'Pies': {
      'Metros': 0.3048,
      'Kilómetros': 0.0003048,
      'Centímetros': 30.48,
      'Millas': 0.000189394,
      'Pies': 1.0,
    },
    // Mass
    'Kilogramos': {'Kilogramos': 1.0, 'Gramos': 1000.0, 'Libras': 2.20462},
    'Gramos': {'Kilogramos': 0.001, 'Gramos': 1.0, 'Libras': 0.00220462},
    'Libras': {'Kilogramos': 0.453592, 'Gramos': 453.592, 'Libras': 1.0},
    // Time
    'Segundos': {'Segundos': 1.0, 'Minutos': 1 / 60, 'Horas': 1 / 3600},
    'Minutos': {'Segundos': 60.0, 'Minutos': 1.0, 'Horas': 1 / 60},
    'Horas': {'Segundos': 3600.0, 'Minutos': 60.0, 'Horas': 1.0},
    // Force (Newtons, Dynes, Pound-force)
    'Newtons': {'Newtons': 1.0, 'Dinas': 100000.0, 'Libras-fuerza': 0.224809},
    'Dinas': {'Newtons': 0.00001, 'Dinas': 1.0, 'Libras-fuerza': 0.0000022481},
    'Libras-fuerza': {
      'Newtons': 4.44822,
      'Dinas': 444822.0,
      'Libras-fuerza': 1.0,
    },
    // Energy (Joules, Calories, Electron Volts)
    'Joules': {
      'Joules': 1.0,
      'Calorías': 0.239006,
      'Electron-voltios': 6.242e18,
    },
    'Calorías': {
      'Joules': 4.184,
      'Calorías': 1.0,
      'Electron-voltios': 2.613e19,
    },
    'Electron-voltios': {
      'Joules': 1.602e-19,
      'Calorías': 3.829e-20,
      'Electron-voltios': 1.0,
    },
    // Pressure (Pascals, Atmospheres, PSI)
    'Pascals': {
      'Pascals': 1.0,
      'Atmósferas': 0.00000986923,
      'PSI': 0.000145038,
    },
    'Atmósferas': {'Pascals': 101325.0, 'Atmósferas': 1.0, 'PSI': 14.6959},
    'PSI': {'Pascals': 6894.76, 'Atmósferas': 0.068046, 'PSI': 1.0},
  };

  @override
  void onInit() {
    super.onInit();
    inputValueController.addListener(convertUnits);
  }

  @override
  void onClose() {
    inputValueController.removeListener(convertUnits);
    inputValueController.dispose();
    super.onClose();
  }

  List<String> get availableUnits {
    // Get all unique units from the conversionFactors map
    Set<String> units = {};
    conversionFactors.forEach((key, value) {
      units.add(key);
      units.addAll(value.keys);
    });
    return units.toList()..sort();
  }

  void convertUnits() {
    final double? inputValue = double.tryParse(inputValueController.text);

    if (inputValue == null || inputValueController.text.isEmpty) {
      result.value = 'Ingrese un valor numérico';
      return;
    }

    final String fromUnit = selectedInputUnit.value;
    final String toUnit = selectedOutputUnit.value;

    if (fromUnit == toUnit) {
      result.value = '$inputValue $toUnit';
      return;
    }

    final double? factorFromBase = conversionFactors[fromUnit]?[fromUnit];
    final double? factorToBase = conversionFactors[fromUnit]?[toUnit];

    if (factorToBase != null) {
      // Direct conversion if available
      final double convertedValue = inputValue * factorToBase;
      result.value = '${convertedValue.toStringAsFixed(6)} $toUnit';
    } else {
      // Try indirect conversion via a common base unit (e.g., meters, kilograms, seconds)
      // This is a simplified approach; a more robust solution would map all units to a single SI base.
      // For now, if a direct conversion isn't found under the 'fromUnit' key,
      // we assume the 'fromUnit' itself *is* a base unit for its category
      // and we just need the 'toUnit' factor from *its* base unit.
      // This part requires careful mapping or a more complex graph traversal.

      // A more robust approach: Find a common base for conversion.
      // This requires knowing which unit belongs to which category (e.g., Length, Mass).
      // For simplicity in this example, we'll try to find a base unit factor if direct fails.

      // Heuristic: If we are converting within the same 'type' of unit (e.g., both length),
      // we can try to find a common intermediary.
      // This example will only do direct conversions listed for simplicity.
      result.value =
          'Conversión no soportada para $fromUnit a $toUnit. Revise las unidades o intente una categoría diferente.';
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

    // Ensure initial dropdown values are set to avoid null errors on first render
    if (controller.selectedInputUnit.value.isEmpty &&
        controller.availableUnits.isNotEmpty) {
      controller.selectedInputUnit.value = controller.availableUnits.first;
    }
    if (controller.selectedOutputUnit.value.isEmpty &&
        controller.availableUnits.isNotEmpty) {
      controller.selectedOutputUnit.value =
          controller.availableUnits.last; // Default to last for variety
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertidor de Unidades'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.inputValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor a convertir',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.selectedInputUnit.value,
                      decoration: const InputDecoration(
                        labelText: 'De',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          controller.availableUnits.map((String unit) {
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
                      value: controller.selectedOutputUnit.value,
                      decoration: const InputDecoration(
                        labelText: 'A',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          controller.availableUnits.map((String unit) {
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
            Obx(
              () => Text(
                'Resultado: ${controller.result.value}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nota: Este convertidor soporta unidades comunes de Longitud, Masa, Tiempo, Fuerza, Energía y Presión. Para conversiones más complejas, se recomienda una herramienta especializada.',
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
