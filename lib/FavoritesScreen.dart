import 'package:flutter/material.dart';
import 'PokemonDetailScreen.dart';
import 'pokemonTypeColors.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritePokemons;

  FavoritesScreen({required this.favoritePokemons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: favoritePokemons.isEmpty
          ? Center(
        child: Text(
          'No tienes Pokémon marcados como favoritos.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Número de columnas en la cuadrícula
          crossAxisSpacing: 10, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 10, // Espacio vertical entre tarjetas
          childAspectRatio: 3 / 4, // Relación de aspecto de las tarjetas
        ),
        itemCount: favoritePokemons.length,
        itemBuilder: (context, index) {
          final pokemon = favoritePokemons[index];
          final id = pokemon['id'];
          final name = pokemon['name'];
          final types = pokemon['types']; // Tipos del Pokémon
          final primaryType = types.isNotEmpty ? types[0] : "normal"; // Usar el primer tipo como color
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(id: id),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: pokemonTypeColors[primaryType] ?? Colors.grey, // Fondo del color del tipo principal
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen del Pokémon
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.4),
                    radius: 50,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(height: 8),
                  // Nombre del Pokémon
                  Text(
                    name[0].toUpperCase() + name.substring(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Contraste con el fondo
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  // Tipos del Pokémon
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: types.map<Widget>((type) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: pokemonTypeColors[type] ?? Colors.grey, // Color basado en el tipo
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white, // Texto blanco para contraste
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
