import 'package:flutter/material.dart';
import '../pokemonTypeColors.dart';

class MoveCard extends StatelessWidget {
  final int level;
  final String name;
  final String type;
  final String damageClass;
  final String power;
  final String accuracy;
  final String pp;

  const MoveCard({
    required this.level,
    required this.name,
    required this.type,
    required this.damageClass,
    required this.power,
    required this.accuracy,
    required this.pp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título: Nivel y Nombre
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Level $level",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      name[0].toUpperCase() + name.substring(1),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _statColumn("Power", power),
                    _statColumn("Acc.", accuracy),
                    _statColumn("PP", pp),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            // Chips: Tipo y Clase de Daño
            Row(
              children: [
                _typeChip(type),
                SizedBox(width: 8),
                _damageClassChip(damageClass),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    return Chip(
      label: Text(
        type.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: pokemonTypeColors[type] ?? Colors.grey[400],
    );
  }

  Widget _damageClassChip(String damageClass) {
    final color = damageClass.toLowerCase() == "physical"
        ? Color(0xFFF85888)
        : damageClass.toLowerCase() == "special"
        ? Color(0xFF6890F0)
        : Color(0xFFA8A878);

    return Chip(
      label: Text(
        damageClass.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
    );
  }

  Widget _statColumn(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}