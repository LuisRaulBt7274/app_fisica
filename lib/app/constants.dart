class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ulpncelmlkarergdavre.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVscG5jZWxtbGthcmVyZ2RhdnJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5Mjg0NzMsImV4cCI6MjA2NTUwNDQ3M30.1rz78YsfczjIgfbdWCGlkZZKtLn8q66tROsQOMWmL-A';

  // Gemini API Configuration
  static const String geminiApiKey = 'AIzaSyCsv2eWD2TJkLNh9OQkt4lU2YqKUKm3yII';
  static const String googleClientId = 'TU_GOOGLE_CLIENT_ID_AQUI';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // App Configuration
  static const String appName = 'PhysicsAI';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Tu asistente inteligente para dominar la Física';

  // Physics Difficulty Levels
  static const List<String> difficultyLevels = [
    'Básico',
    'Intermedio',
    'Avanzado',
    'Universitario',
  ];

  // Physics Topics
  static const List<String> physicsTopics = [
    'Mecánica Clásica',
    'Termodinámica',
    'Electromagnetismo',
    'Óptica',
    'Física Moderna',
    'Ondas y sonido',
    'Fluidos',
    'Física Cuántica',
    'Relatividad',
    'Física de Partículas',
  ];

  // Physics Subtopics (EXPANDIDO)
  static const Map<String, List<String>> physicsSubtopics = {
    'Mecánica Clásica': [
      'Cinemática',
      'Dinámica',
      'Estática',
      'Trabajo y Energía',
      'Momentum',
      'Rotación',
      'Oscilaciones',
      'Gravitación',
    ],
    'Termodinámica': [
      'Temperatura y Calor',
      'Primera Ley de la Termodinámica',
      'Segunda Ley de la Termodinámica',
      'Gases Ideales',
      'Entropía',
      'Máquinas Térmicas',
      'Ciclos Termodinámicos',
    ],
    'Electromagnetismo': [
      'Electrostática',
      'Corriente Eléctrica',
      'Magnetismo',
      'Inducción Electromagnética',
      'Ondas Electromagnéticas',
      'Circuitos DC',
      'Circuitos AC',
    ],
    'Óptica': [
      'Reflexión y Refracción',
      'Lentes y Espejos',
      'Interferencia',
      'Difracción',
      'Polarización',
      'Óptica Geométrica',
    ],
    'Física Moderna': [
      'Efecto Fotoeléctrico',
      'Modelo Atómico',
      'Dualidad Onda-Partícula',
      'Mecánica Cuántica Básica',
      'Relatividad Especial',
      'Relatividad General',
    ],
    'Ondas y sonido': [
      'Movimiento Armónico Simple',
      'Ondas Mecánicas',
      'Sonido',
      'Resonancia',
      'Superposición de Ondas',
    ],
    'Fluidos': [
      'Estática de Fluidos',
      'Dinámica de Fluidos',
      'Principio de Bernoulli',
      'Viscosidad',
    ],
  };

  // File Upload Limits
  static const int maxFileSize = 15 * 1024 * 1024; // 15MB
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'jpg',
    'jpeg',
    'png',
    'tex',
    'md',
  ];

  // Physics Simulators URLs
  static const Map<String, String> physicsSimulatorUrls = {
    'PhET Physics Simulations':
        'https://phet.colorado.edu/en/simulations/filter?subjects=physics&type=html',
    'Walter Fendt Physics Simulations':
        'https://www.walter-fendt.de/html5/phen/',
    'Physics Classroom Simulations':
        'https://www.physicsclassroom.com/Physics-Interactives',
    'Falstad Physics Simulations': 'https://www.falstad.com/mathphysics.html',
  };

  // Physics Units by Category (CORREGIDO)
  static const Map<String, Map<String, double>> physicsUnits = {
    'Longitud': {
      'm': 1.0, // metro (base)
      'cm': 0.01,
      'mm': 0.001,
      'km': 1000.0,
      'in': 0.0254,
      'ft': 0.3048,
      'yd': 0.9144,
    },
    'Masa': {
      'kg': 1.0, // kilogramo (base)
      'g': 0.001,
      'mg': 0.000001,
      'lb': 0.453592,
      'oz': 0.0283495,
    },
    'Tiempo': {
      's': 1.0, // segundo (base)
      'ms': 0.001,
      'min': 60.0,
      'h': 3600.0,
      'day': 86400.0,
    },
    'Velocidad': {
      'm/s': 1.0, // metros por segundo (base)
      'km/h': 0.277778,
      'mph': 0.44704,
      'ft/s': 0.3048,
    },
    'Fuerza': {
      'N': 1.0, // Newton (base)
      'dyn': 0.00001,
      'lbf': 4.44822,
      'kgf': 9.80665,
    },
    'Energía': {
      'J': 1.0, // Joule (base)
      'cal': 4.184,
      'eV': 1.602176634e-19,
      'kWh': 3600000.0,
      'BTU': 1055.06,
    },
    'Potencia': {
      'W': 1.0, // Watt (base)
      'kW': 1000.0,
      'hp': 745.7,
      'cal/s': 4.184,
    },
    'Presión': {
      'Pa': 1.0, // Pascal (base)
      'atm': 101325.0,
      'bar': 100000.0,
      'psi': 6894.76,
      'mmHg': 133.322,
    },
    'Temperatura': {
      'K': 1.0, // Kelvin (base)
      // Celsius y Fahrenheit requieren conversión especial
    },
  };
  static double convertTemperature(double value, String from, String to) {
    if (from == to) return value;

    // Convertir a Kelvin primero
    double kelvin;
    switch (from) {
      case 'K':
        kelvin = value;
        break;
      case 'C':
        kelvin = value + 273.15;
        break;
      case 'F':
        kelvin = (value - 32) * 5 / 9 + 273.15;
        break;
      default:
        return value;
    }

    // Convertir de Kelvin a la unidad objetivo
    switch (to) {
      case 'K':
        return kelvin;
      case 'C':
        return kelvin - 273.15;
      case 'F':
        return (kelvin - 273.15) * 9 / 5 + 32;
      default:
        return value;
    }
  }

  // Document Analysis Types
  static const List<String> documentAnalysisTypes = [
    'Resumen de Conceptos Físicos',
    'Extracción de Fórmulas',
    'Identificación de Leyes Físicas',
    'Preguntas de Estudio',
    'Problemas Numéricos',
    'Constantes Físicas',
    'Aplicaciones Prácticas',
  ];

  // Exam Types
  static const List<String> examTypes = [
    'Opción Múltiple',
    'Verdadero/Falso',
    'Problemas Numéricos',
    'Preguntas Conceptuales',
    'Desarrollo Teórico',
    'Análisis de Experimentos',
    'Mixto',
  ];

  // Problem Types
  static const List<String> problemTypes = [
    'Cinemática Lineal',
    'Cinemática Circular',
    'Dinámica de Partículas',
    'Trabajo y Energía',
    'Conservación del Momentum',
    'Oscilaciones Armónicas',
    'Ondas Mecánicas',
    'Termodinámica de Gases',
    'Circuitos Eléctricos',
    'Campos Electromagnéticos',
    'Óptica Geométrica',
    'Física Moderna',
  ];

  // AI Prompts for Physics (NUEVO)
  static const Map<String, String> aiPrompts = {
    'problemSolver': '''
Eres un asistente especializado en física. Ayuda a resolver este problema paso a paso:
1. Identifica los datos dados
2. Determina qué se pide encontrar
3. Identifica las leyes y fórmulas relevantes
4. Resuelve paso a paso
5. Verifica el resultado

Problema: {problem}
''',
    'conceptExplainer': '''
Explica este concepto de física de manera clara y didáctica:
1. Definición simple
2. Principios fundamentales
3. Ejemplos cotidianos
4. Aplicaciones prácticas
5. Fórmulas clave (si aplica)

Concepto: {concept}
''',
    'documentAnalyzer': '''
Analiza este documento relacionado con física y proporciona:
1. Resumen de conceptos principales
2. Fórmulas identificadas
3. Leyes físicas mencionadas
4. Preguntas de estudio sugeridas
5. Problemas de práctica relacionados

Documento: {document}
''',
  };
}
