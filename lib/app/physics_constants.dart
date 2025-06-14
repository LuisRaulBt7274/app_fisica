class PhysicsConstants {
  // Constantes físicas fundamentales
  static const double speedOfLight = 299792458; // m/s
  static const double gravitationalConstant = 6.67430e-11; // m³/kg⋅s²
  static const double planckConstant = 6.62607015e-34; // J⋅s
  static const double elementaryCharge = 1.602176634e-19; // C
  static const double boltzmannConstant = 1.380649e-23; // J/K
  static const double avogadroNumber = 6.02214076e23; // mol⁻¹

  // Constantes terrestres
  static const double earthGravity = 9.81; // m/s²
  static const double earthRadius = 6.371e6; // m
  static const double earthMass = 5.972e24; // kg

  // Constantes electromagnéticas
  static const double permittivityOfFreeSpace = 8.854187817e-12; // F/m
  static const double permeabilityOfFreeSpace = 4e-7 * 3.14159265359; // H/m

  // Métodos útiles para conversiones
  static double celsiusToKelvin(double celsius) => celsius + 273.15;
  static double kelvinToCelsius(double kelvin) => kelvin - 273.15;
  static double degreesToRadians(double degrees) =>
      degrees * 3.14159265359 / 180;
  static double radiansToDegrees(double radians) =>
      radians * 180 / 3.14159265359;
}
