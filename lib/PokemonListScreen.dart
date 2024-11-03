import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'PokemonDetailScreen.dart';

//para poner un limite de pokemones: pokemon_v2_pokemon(limit: 20) {
const String getPokemonList = """
query {
  pokemon_v2_pokemon {
    id
    name
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
  }
}
""";

class PokemonListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
        backgroundColor: Colors.red,
      ),
      body: Query(
        options: QueryOptions(document: gql(getPokemonList)),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) return Center(child: CircularProgressIndicator());

          if (result.hasException) return Center(child: Text(result.exception.toString()));

          final List pokemons = result.data?['pokemon_v2_pokemon'];

          return ListView.builder(
            itemCount: pokemons.length,
            itemBuilder: (context, index) {
              final pokemon = pokemons[index];
              final name = pokemon['name'];
              final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png';
              final types = pokemon['pokemon_v2_pokemontypes']
                  .map((type) => type['pokemon_v2_type']['name'])
                  .join(', ');

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(
                    name[0].toUpperCase() + name.substring(1),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    types,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailScreen(id: pokemon['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
