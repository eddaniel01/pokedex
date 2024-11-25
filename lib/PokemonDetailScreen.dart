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
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          name
          id
          generation_id
        }
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
      body: Query(
        options: QueryOptions(document: gql(getPokemonDetail(id))),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          final pokemon = result.data?['pokemon_v2_pokemon_by_pk'];
          if (pokemon == null) {
            return Center(
                child: Text("No se encontró información del Pokémon."));
          }

          final name = pokemon['name'] ?? "Desconocido";
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${id}.png';
          final types = (pokemon['pokemon_v2_pokemontypes'] as List)
              .map((type) => type['pokemon_v2_type']['name'])
              .toList();
          final primaryColor = pokemonTypeColors[types[0]] ?? Colors.blue;

          final height = pokemon['height'] / 10;
          final weight = pokemon['weight'] / 10;

          final abilities = (pokemon['pokemon_v2_pokemonabilities'] as List)
              .map((ability) => ability['pokemon_v2_ability']['name'])
              .toList();
          final stats = pokemon['pokemon_v2_pokemonstats'] as List;
          final moves = (pokemon['pokemon_v2_pokemonmoves'] as List)
              .map((move) => move['pokemon_v2_move']['name'])
              .toList();

          return Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withOpacity(0.4), primaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          indicatorColor: primaryColor,
                          labelColor: primaryColor,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(text: "About"),
                            Tab(text: "Stats"),
                            Tab(text: "Evolution"),
                            Tab(text: "Moves"),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ListView(
                                children: [
                                  PokemonInfoSection(
                                    title: "Details",
                                    content: [
                                      _infoCard("Height", "${height} m"),
                                      _infoCard("Weight", "${weight} kg"),
                                    ],
                                  ),
                                  PokemonInfoSection(
                                    title: "Abilities",
                                    content: abilities.isNotEmpty
                                        ? abilities
                                            .map((ability) => Text(
                                                  ability[0].toUpperCase() +
                                                      ability.substring(1),
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ))
                                            .toList()
                                        : [Text("No abilities available.")],
                                  ),
                                ],
                              ),
                              ListView(
                                padding: EdgeInsets.all(16.0),
                                children: stats.map<Widget>((stat) {
                                  final statName =
                                      stat['pokemon_v2_stat']['name'];
                                  final statValue = stat['base_stat'];
                                  final maxStatValue =
                                      200;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            statName[0].toUpperCase() +
                                                statName.substring(
                                                    1),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: LinearProgressIndicator(
                                            value: statValue /
                                                maxStatValue,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue),
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        Text(
                                          statValue.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              Center(
                                child: Text("Evolution data under development"),
                              ),
                              ListView(
                                children: moves.map((move) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      move[0].toUpperCase() + move.substring(1),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name[0].toUpperCase() + name.substring(1),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "#${id.toString().padLeft(3, '0')}",
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: types.map((type) {
                        final typeColor =
                            pokemonTypeColors[type] ?? Colors.grey;
                        return Container(
                          margin: EdgeInsets.only(right: 8.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type[0].toUpperCase() + type.substring(1),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.12,
                left: MediaQuery.of(context).size.width * 0.45,
                child: Hero(
                  tag: 'pokemon-image-$id',
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PokemonInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final double? minHeight;

  PokemonInfoSection(
      {required this.title, required this.content, this.minHeight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          minHeight: minHeight ?? 0,
        ),
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

Widget _infoCard(String title, String value) {
  return Container(
    padding: EdgeInsets.all(16.0),
    margin: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 8),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
