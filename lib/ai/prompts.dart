class PromptTemplates {
  static String examPrompt({
    required String difficulty,
    required int questionCount,
    required String topics,
  }) {
    return '''
Actúa como un experto profesor de Física. Crea un examen de nivel $difficulty con $questionCount preguntas sobre los siguientes temas: $topics.

Instrucciones:
- Incluye diferentes tipos de preguntas: opción múltiple, verdadero/falso, respuesta corta y desarrollo
- Proporciona las respuestas correctas al final
- Asegúrate de que las preguntas sean apropiadas para el nivel $difficulty
- Incluye explicaciones breves para las respuestas

Formato de respuesta:
## EXAMEN DE Física

### Pregunta 1 (Opción múltiple)
[Pregunta]
a) [Opción A]
b) [Opción B]
c) [Opción C]
d) [Opción D]

[Continúa con el resto de preguntas...]

## RESPUESTAS
1. [Respuesta correcta] - [Breve explicación]
[Continúa con el resto de respuestas...]
''';
  }

  static String exerciseSolverPrompt({
    required String exercise,
    required String subject,
  }) {
    return '''
Actúa como un tutor experto en Física. Ayuda a resolver el siguiente ejercicio paso a paso:

EJERCICIO:
$exercise

Instrucciones:
- Explica cada paso detalladamente
- Muestra todas las fórmulas y cálculos necesarios
- Proporciona consejos útiles para problemas similares
- Si hay gráficos o diagramas necesarios, descríbelos claramente
- Verifica la respuesta final

Formato de respuesta:
## SOLUCIÓN PASO A PASO

### Paso 1: [Nombre del paso]
[Explicación detallada]

### Paso 2: [Nombre del paso]
[Explicación detallada]

[Continúa con los pasos necesarios...]

### Respuesta Final:
[Respuesta con unidades si aplica]

### Consejos:
- [Consejo 1]
- [Consejo 2]
''';
  }

  static String flashcardsPrompt({
    required String topic,
    required int cardCount,
    required String difficulty,
  }) {
    return '''
Crea $cardCount flashcards sobre el tema: $topic con nivel de dificultad $difficulty.

Instrucciones:
- Cada flashcard debe tener una pregunta/concepto en el frente y la respuesta/explicación en el reverso
- Las preguntas deben ser claras y concisas
- Las respuestas deben ser completas pero fáciles de memorizar
- Incluye ejemplos cuando sea apropiado
- Varía el tipo de preguntas (definiciones, ejemplos, aplicaciones, etc.)

Formato de respuesta:
## FLASHCARDS: $topic

### Tarjeta 1
**Frente:** [Pregunta o concepto]
**Reverso:** [Respuesta o explicación]

### Tarjeta 2
**Frente:** [Pregunta o concepto]
**Reverso:** [Respuesta o explicación]

[Continúa con el resto de tarjetas...]
''';
  }

  static String documentAnalysisPrompt({
    required String content,
    required String analysisType,
  }) {
    return '''
Analiza el siguiente documento y proporciona un análisis de tipo: $analysisType

DOCUMENTO:
$content

Instrucciones según el tipo de análisis:
- Resumen: Crea un resumen conciso de los puntos principales
- Conceptos clave: Identifica y explica los conceptos más importantes
- Preguntas de estudio: Genera preguntas que ayuden a estudiar el material
- Puntos importantes: Lista los elementos más relevantes para recordar

Proporciona un análisis completo y estructurado que sea útil para el estudio.
''';
  }

  static String examFromDocumentPrompt({
    required String content,
    required String difficulty,
    required int questionCount,
  }) {
    return '''
Basándote en el siguiente documento, crea un examen de nivel $difficulty con $questionCount preguntas:

DOCUMENTO:
$content

Instrucciones:
- Las preguntas deben basarse únicamente en el contenido del documento
- Incluye diferentes tipos de preguntas
- Asegúrate de cubrir los puntos más importantes del documento
- Proporciona respuestas con explicaciones

Sigue el formato estándar de examen con preguntas numeradas y sección de respuestas al final.
''';
  }

  static String flashcardsFromDocumentPrompt({
    required String content,
    required int cardCount,
  }) {
    return '''
Crea $cardCount flashcards basadas en el siguiente documento:

DOCUMENTO:
$content

Instrucciones:
- Extrae los conceptos más importantes del documento
- Crea preguntas que ayuden a memorizar la información clave
- Las respuestas deben ser precisas y basadas en el documento
- Incluye definiciones, fechas, nombres importantes, etc.

Usa el formato estándar de flashcards con frente y reverso claramente marcados.
''';
  }

  static String conceptExplanationPrompt({
    required String concept,
    required String subject,
    required String level,
  }) {
    return '''
Explica el concepto "$concept" en el área de Física para un nivel $level.

Instrucciones:
- Proporciona una explicación clara y comprensible
- Incluye ejemplos prácticos cuando sea posible
- Menciona aplicaciones del concepto
- Si es apropiado, incluye fórmulas o diagramas descritos en texto
- Ajusta el nivel de complejidad según el nivel especificado

La explicación debe ser educativa y fácil de entender para el nivel indicado.
''';
  }
}
