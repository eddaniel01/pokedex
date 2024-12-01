import 'package:flutter/material.dart';

class PokemonCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String type;
  final double height;
  final double weight;
  final String abilityName;
  final String abilityDescription;
  final Color backgroundColor;

  const PokemonCard({
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.height,
    required this.weight,
    required this.abilityName,
    required this.abilityDescription,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: backgroundColor, width: 6), // Borde del color del tipo
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen del Pokémon
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor.withOpacity(0.2),
            ),
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                imageUrl,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 120),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nombre del Pokémon
          Text(
            name[0].toUpperCase() + name.substring(1),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: backgroundColor,
            ),
          ),

          // Tipo
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Type: ${type[0].toUpperCase()}${type.substring(1)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Altura y Peso
          Text(
            "Height: ${height.toStringAsFixed(1)} m  |  Weight: ${weight.toStringAsFixed(1)} kg",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Sección de Habilidad Especial
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Ability: ${abilityName[0].toUpperCase()}${abilityName.substring(1)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  abilityDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
