import 'package:flutter/material.dart';
import 'PokemonDetailScreen.dart';

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
          : ListView.builder(
        itemCount: favoritePokemons.length,
        itemBuilder: (context, index) {
          final pokemon = favoritePokemons[index];
          final id = pokemon['id'];
          final name = pokemon['name'];
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            title: Text(name[0].toUpperCase() + name.substring(1)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetailScreen(id: id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
