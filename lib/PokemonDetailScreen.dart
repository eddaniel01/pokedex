import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String getPokemonDetail(int id) => """
query {
  pokemon_v2_pokemon_by_pk(id: $id) {
    name
    height
    weight
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
    pokemon_v2_pokemonabilities {
      pokemon_v2_ability {
        name
      }
    }
    pokemon_v2_pokemonstats {
      base_stat
      pokemon_v2_stat {
        name
      }
    }
    pokemon_v2_pokemonmoves(limit: 5) {
      pokemon_v2_move {
        name
      }
    }
  }
}
""";

class PokemonDetailScreen extends StatelessWidget {
  final int id;

  PokemonDetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Pokémon', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Query(
        options: QueryOptions(document: gql(getPokemonDetail(id))),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) return Center(child: CircularProgressIndicator());

          if (result.hasException) return Center(child: Text(result.exception.toString()));

          final pokemon = result.data?['pokemon_v2_pokemon_by_pk'];
          final name = pokemon['name'];
          final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
          final types = pokemon['pokemon_v2_pokemontypes']
              .map((type) => type['pokemon_v2_type']['name'])
              .join(', ');
          final abilities = pokemon['pokemon_v2_pokemonabilities']
              .map((ability) => ability['pokemon_v2_ability']['name'])
              .join(', ');
          final stats = pokemon['pokemon_v2_pokemonstats'];
          final moves = pokemon['pokemon_v2_pokemonmoves']
              .map((move) => move['pokemon_v2_move']['name'])
              .join(', ');

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 8),
                      Text(
                        name[0].toUpperCase() + name.substring(1),
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        'Tipo: $types',
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
                Divider(),
                _buildSectionTitle(context, "Información Básica"),
                SizedBox(height: 8),
                Text("Altura: ${pokemon['height']} decímetros"),
                Text("Peso: ${pokemon['weight']} hectogramos"),
                Divider(),
                _buildSectionTitle(context, "Habilidades"),
                Text(abilities),
                Divider(),
                _buildSectionTitle(context, "Estadísticas"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stats.map<Widget>((stat) {
                    return Text("${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}");
                  }).toList(),
                ),
                Divider(),
                _buildSectionTitle(context, "Movimientos"),
                Text(moves),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}