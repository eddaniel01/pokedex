import 'package:flutter/material.dart';

class EvolutionTree extends StatelessWidget {
  final List<Map<String, dynamic>> evolutions;
  final int evolutionChainId;

  EvolutionTree({required this.evolutions, required this.evolutionChainId});

  @override
  Widget build(BuildContext context) {
    // Filtrar evoluciones que pertenezcan al mismo evolution_chain_id.
    final filteredEvolutions = evolutions
        .where((evo) => evo['evolution_chain_id'] == evolutionChainId)
        .toList();

    if (filteredEvolutions.isEmpty) {
      return Center(
        child: Text(
          "No hay evoluciones disponibles.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Crear el árbol de evoluciones usando evolves_from_species_id.
    final evolutionHierarchy = _buildHierarchy(filteredEvolutions);

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(40.0),
      minScale: 0.8,
      maxScale: 3.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildEvolutionTree(evolutionHierarchy),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la jerarquía de evoluciones.
  Map<String, dynamic> _buildHierarchy(List<Map<String, dynamic>> evolutions) {
    final evolutionMap = {for (var e in evolutions) e['id']: {...e, 'children': []}};

    // Crear relaciones padre-hijo.
    for (var evo in evolutions) {
      final parentId = evo['evolves_from_species_id'];
      if (parentId != null && evolutionMap.containsKey(parentId)) {
        (evolutionMap[parentId]!['children'] as List).add(evolutionMap[evo['id']]!);
      }
    }

    // Retornar el nodo raíz (el que no tiene evolves_from_species_id).
    return evolutionMap.values.firstWhere((evo) => evo['evolves_from_species_id'] == null);
  }

  /// Construir el árbol visualmente.
  Widget _buildEvolutionTree(Map<String, dynamic> node) {
    final children = node['children'] as List<dynamic>? ?? [];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(child: _buildPokemonNode(node)), // Nodo principal centrado.
        if (children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      CustomPaint(
                        size: Size(80, 40),
                        painter: LinePainter(),
                      ),
                      _buildEvolutionTree(child),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// Construir un nodo de Pokémon.
  Widget _buildPokemonNode(Map<String, dynamic> pokemon) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(pokemon['image']),
          radius: 60,
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 8),
        Text(
          pokemon['name'][0].toUpperCase() + pokemon['name'].substring(1),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          "#${pokemon['id'].toString().padLeft(3, '0')}",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    // Dibujar una línea curva.
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(size.width / 2, size.height / 2, size.width / 2, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
