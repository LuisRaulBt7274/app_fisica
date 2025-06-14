class PromptTemplates {
  static String examPrompt({
    required String difficulty,
    required int questionCount,
    required String topics,
  }) {
    return '''
Actúa como un experto profesor de Física. Crea un examen de nivel $difficulty con $questionCount preguntas sobre los siguientes temas de FÍSICA: $topics.

Instrucciones:
- EXCLUSIVAMENTE temas de Física (mecánica, termodinámica, electromagnetismo, óptica, física moderna, etc.)
- Incluye diferentes tipos de preguntas: opción múltiple, verdadero/falso, problemas numéricos y desarrollo teórico
- Proporciona las respuestas correctas con unidades SI cuando aplique
- Asegúrate de que las preguntas sean apropiadas para el nivel $difficulty
- Incluye fórmulas físicas relevantes y explicaciones conceptuales

Formato de respuesta:
## EXAMEN DE FÍSICA - Nivel $difficulty

### Pregunta 1 (Opción múltiple)
[Pregunta de física con datos numéricos si aplica]
a) [Opción A con unidades]
b) [Opción B con unidades]
c) [Opción C con unidades]
d) [Opción D con unidades]

[Continúa con el resto de preguntas...]

## RESPUESTAS Y SOLUCIONES
1. [Respuesta correcta] - [Explicación con fórmulas y procedimiento]
[Continúa con el resto de respuestas...]
''';
  }

  static String exerciseSolverPrompt({required String exercise}) {
    return '''
Actúa como un tutor experto en Física. Resuelve el siguiente problema de física paso a paso:

PROBLEMA DE FÍSICA:
$exercise

Instrucciones:
- Identifica las variables físicas conocidas y desconocidas
- Selecciona las fórmulas físicas apropiadas
- Realiza los cálculos paso a paso con unidades SI
- Dibuja diagramas cuando sea necesario (descríbelos en texto)
- Verifica que el resultado tenga sentido físico
- Incluye análisis dimensional

Formato de respuesta:
## SOLUCIÓN DEL PROBLEMA DE FÍSICA

### Datos:
- [Variable 1]: [valor] [unidad]
- [Variable 2]: [valor] [unidad]

### Incógnita:
- [Variable a encontrar]: ? [unidad esperada]

### Fórmulas a usar:
- [Fórmula 1]: [ecuación]
- [Fórmula 2]: [ecuación]

### Paso 1: Análisis del problema
[Explicación del fenómeno físico]

### Paso 2: Aplicación de fórmulas
[Sustitución de valores]

### Paso 3: Cálculo
[Operaciones matemáticas]

### Respuesta Final:
[Resultado con unidades] 

### Verificación:
- Análisis dimensional: [verificación]
- Sentido físico: [explicación]
''';
  }

  static String flashcardsPrompt({
    required String topic,
    required int cardCount,
    required String difficulty,
  }) {
    return '''
Crea $cardCount flashcards sobre el tema de FÍSICA: $topic con nivel de dificultad $difficulty.

Instrucciones:
- Enfócate ÚNICAMENTE en conceptos de física
- Incluye fórmulas físicas importantes
- Menciona unidades SI correspondientes
- Incluye constantes físicas relevantes
- Varía entre definiciones, fórmulas, aplicaciones y conceptos

Formato de respuesta:
## FLASHCARDS DE FÍSICA: $topic

### Tarjeta 1
**Frente:** [Pregunta o concepto físico]
**Reverso:** [Respuesta con fórmulas y unidades si aplica]

### Tarjeta 2
**Frente:** [Pregunta o concepto físico]
**Reverso:** [Respuesta con fórmulas y unidades si aplica]

[Continúa con el resto de tarjetas...]
''';
  }

  static String documentAnalysisPrompt({
    required String content,
    required String analysisType,
  }) {
    return '''
Analiza el siguiente documento de FÍSICA y proporciona un análisis de tipo: $analysisType

DOCUMENTO DE FÍSICA:
$content

Instrucciones según el tipo de análisis:
- Resumen: Extrae conceptos físicos principales, fórmulas clave y aplicaciones
- Conceptos clave: Identifica leyes físicas, principios y teorías fundamentales
- Preguntas de estudio: Genera preguntas sobre fenómenos físicos y problemas numéricos
- Puntos importantes: Lista fórmulas esenciales, constantes y relaciones físicas

IMPORTANTE: Enfócate ÚNICAMENTE en contenido relacionado con física.
''';
  }

  static String conceptExplanationPrompt({
    required String concept,
    required String level,
  }) {
    return '''
Explica el concepto de FÍSICA "$concept" para un nivel académico $level.

Instrucciones:
- Proporciona definición física precisa
- Incluye fórmulas matemáticas relevantes
- Menciona unidades SI apropiadas
- Da ejemplos de aplicaciones en la vida real
- Explica el fenómeno físico subyacente
- Incluye constantes físicas si son relevantes

La explicación debe ser científicamente precisa y apropiada para el nivel $level.
''';
  }

  // Métodos con documentos mantienen la misma estructura pero con enfoque en física
  static String examFromDocumentPrompt({
    required String content,
    required String difficulty,
    required int questionCount,
  }) {
    return '''
Basándote en el siguiente documento de FÍSICA, crea un examen de nivel $difficulty con $questionCount preguntas:

DOCUMENTO DE FÍSICA:
$content

Instrucciones:
- Las preguntas deben basarse únicamente en conceptos físicos del documento
- Incluye problemas numéricos con datos del documento
- Asegúrate de incluir fórmulas físicas mencionadas
- Proporciona respuestas con procedimientos completos

Sigue el formato estándar de examen de física con preguntas numeradas y sección de respuestas.
''';
  }

  static String flashcardsFromDocumentPrompt({
    required String content,
    required int cardCount,
  }) {
    return '''
Crea $cardCount flashcards de FÍSICA basadas en el siguiente documento:

DOCUMENTO DE FÍSICA:
$content

Instrucciones:
- Extrae conceptos físicos más importantes
- Incluye fórmulas y leyes físicas del documento
- Menciona unidades y constantes relevantes
- Crea preguntas sobre aplicaciones físicas

Usa el formato estándar de flashcards enfocadas en física.
''';
  }
}
