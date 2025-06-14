import 'dart:io';

class DocumentParser {
  Future<String?> extractText(File file) async {
    // TODO: Implement actual text extraction logic for the document type.
    // For now, return a placeholder string.
    return 'Texto extraído de ejemplo';
  }
}

List<String> extractPhysicsFormulas(String text) {
  final formulaPatterns = [
    RegExp(r'[a-zA-Z]\s*=\s*[^=\n]+'), // Ecuaciones básicas
    RegExp(r'F\s*=\s*ma'), // Segunda ley de Newton
    RegExp(r'E\s*=\s*mc²'), // Einstein
    RegExp(r'v\s*=\s*[^=\n]+'), // Velocidad
    RegExp(r'a\s*=\s*[^=\n]+'), // Aceleración
  ];

  List<String> formulas = [];
  for (final pattern in formulaPatterns) {
    final matches = pattern.allMatches(text);
    formulas.addAll(matches.map((m) => m.group(0)!.trim()));
  }

  return formulas.toSet().toList();
}

// Extraer unidades físicas
List<String> extractPhysicsUnits(String text) {
  const units = [
    'm/s',
    'km/h',
    'm/s²',
    'N',
    'J',
    'W',
    'V',
    'A',
    'Ω',
    'Hz',
    'Pa',
    'K',
    '°C',
    'kg',
    'g',
    'm',
    'cm',
    'mm',
  ];

  List<String> foundUnits = [];
  for (final unit in units) {
    if (text.contains(unit)) {
      foundUnits.add(unit);
    }
  }

  return foundUnits;
}

// Clasificar tipo de problema de física
String classifyPhysicsProblem(String text) {
  final lowerText = text.toLowerCase();

  if (lowerText.contains('fuerza') || lowerText.contains('newton')) {
    return 'Mecánica - Fuerzas';
  } else if (lowerText.contains('velocidad') ||
      lowerText.contains('cinemática')) {
    return 'Mecánica - Cinemática';
  } else if (lowerText.contains('energía') || lowerText.contains('trabajo')) {
    return 'Mecánica - Energía';
  } else if (lowerText.contains('calor') || lowerText.contains('temperatura')) {
    return 'Termodinámica';
  } else if (lowerText.contains('onda') || lowerText.contains('frecuencia')) {
    return 'Ondas';
  } else if (lowerText.contains('corriente') || lowerText.contains('voltaje')) {
    return 'Electricidad';
  }

  return 'Física General';
}
