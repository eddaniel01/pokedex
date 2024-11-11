import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pokemonTypeColors.dart';

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
    pokemon_v2_pokemonspecy {
      generation_id
    }
  }
}
""";

class PokemonInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> content;

  PokemonInfoSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(),
            ...content,
          ],
        ),
      ),
    );
  }
}


class PokemonDetailScreen extends StatelessWidget {
  final int id;

  PokemonDetailScreen({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Query(
          options: QueryOptions(document: gql(getPokemonDetail(id))),
          builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.isLoading) return AppBar(title: Text('Cargando...'));
            if (result.hasException) return AppBar(title: Text('Error'));

            final pokemon = result.data?['pokemon_v2_pokemon_by_pk'];
            final types = pokemon['pokemon_v2_pokemontypes']
                .map((type) => type['pokemon_v2_type']['name'])
                .toList();
            final primaryColor = pokemonTypeColors[types[0]] ?? Colors.blue;

            return AppBar(
              title: Text('Detalles de Pokémon', style: TextStyle(color: Colors.white)),
              backgroundColor: primaryColor,
            );
          },
        ),
      ),
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
              .toList();
          final stats = pokemon['pokemon_v2_pokemonstats'];
          final moves = pokemon['pokemon_v2_pokemonmoves']
              .map((move) => move['pokemon_v2_move']['name'])
              .toList();
          final generationId = pokemon['pokemon_v2_pokemonspecy']['generation_id'];
          final primaryColor = pokemonTypeColors[types.split(',')[0]] ?? Colors.blue;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name[0].toUpperCase() + name.substring(1),
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Tipo: $types',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          Text(
                            'Generación: $generationId',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Hero(
                        tag: 'pokemon-image-$id',
                        child: Image.network(
                          imageUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: Column(
                              children: [
                                PokemonInfoSection(
                                  title: "Información Básica",
                                  content: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.height, color: Colors.grey),
                                        Text("Altura:     ${pokemon['height']} m"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.line_weight, color: Colors.grey),
                                        Text("Peso:   ${pokemon['weight']} kg"),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 350,
                            child: PokemonInfoSection(
                              title: "Estadísticas",
                              content: stats.map<Widget>((stat) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(stat['pokemon_v2_stat']['name']),
                                    Text("${stat['base_stat']}"),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: PokemonInfoSection(
                              title: "Habilidades",
                              content: abilities.map<Widget>((ability) {
                                return ListTile(
                                  leading: Icon(Icons.flash_on, color: Colors.amber),
                                  title: Text(ability),
                                );
                              }).toList(),
                            ),
                          ),
                          Container(
                            height: 350,
                            child: PokemonInfoSection(
                              title: "Movimientos",
                              content: moves.map<Widget>((move) {
                                return ListTile(
                                  leading: Icon(Icons.swap_horiz, color: Colors.green),
                                  title: Text(move),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

