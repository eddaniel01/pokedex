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
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.4),
                    radius: 50,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(height: 8),
                  Text(
                    name[0].toUpperCase() + name.substring(1),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
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
