import 'package:flutter/material.dart';
import 'PokemonDetailScreen.dart';
import 'pokemonTypeColors.dart';

class FavoritesScreen extends StatelessWidget {
  final List<int> favoriteIds;

  FavoritesScreen({required this.favoriteIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: favoriteIds.isEmpty
          ? Center(
        child: Text(
          'No tienes Pokémon marcados como favoritos.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: favoriteIds.length,
        itemBuilder: (context, index) {
          final id = favoriteIds[index];
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            title: Text('Pokémon ID: $id'),
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
