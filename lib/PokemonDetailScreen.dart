
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pokedex_app/widgets/EvolutionTree.dart';
import 'package:pokedex_app/widgets/MoveCard.dart';
import 'package:pokedex_app/widgets/PokemonCard.dart';
import 'package:share_plus/share_plus.dart';
import 'pokemonTypeColors.dart';
import 'package:path_provider/path_provider.dart';

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
        pokemon_v2_abilityeffecttexts(where: {language_id: {_eq: 9}}) {
          short_effect
        }
      }
    }
    pokemon_v2_pokemonstats {
      base_stat
      pokemon_v2_stat {
        name
      }
    }
     pokemon_v2_pokemonmoves(where: {pokemon_id: {_eq: $id}}) {
      level
      pokemon_v2_move {
        name
        power
        accuracy
        pp
        damage_class: pokemon_v2_movedamageclass {
          name
        }
        pokemon_v2_type {
          name
        }
      }
    }
    pokemon_v2_pokemonspecy {
      generation_id
      pokemon_v2_pokemonspeciesflavortexts(where: {language_id: {_eq: 9}}, limit: 1) {
        flavor_text
      }
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          name
          id
          generation_id
          evolves_from_species_id
          evolution_chain_id
        }
      }
    }
  }
}
""";

class PokemonDetailScreen extends StatelessWidget {
  final int id;

  final GlobalKey _cardKey = GlobalKey(); // Clave para capturar el RepaintBoundary.

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

          // final client = GraphQLProvider.of(context).value;
          // final cacheData = client.cache.readQuery(
          //   Request(
          //     operation: Operation(
          //       document: gql(getPokemonDetail(id)),
          //     ),
          //   ),
          // );
          //
          // print("Datos del caché: $cacheData");

          if (result.hasException) {
            return Center(
              child: Text("Ocurrió un error al cargar los datos: ${result.exception.toString()}"),
            );
          }
          if (result.data == null) {
            return Center(child: Text("No se encontraron datos para este Pokémon."));
          }
          final pokemon = result.data?['pokemon_v2_pokemon_by_pk'];
          if (pokemon == null) {
            return Center(child: Text("El Pokémon no tiene datos disponibles."));
          }
          final name = pokemon['name'] ?? "Desconocido";
          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${id}.png';

          final types = (pokemon['pokemon_v2_pokemontypes'] as List)
              .map((type) => type['pokemon_v2_type']['name'])
              .toList();
          final primaryType = types.isNotEmpty ? types[0] : "Unknown";
          final primaryColor = pokemonTypeColors[types[0]] ?? Colors.blue;

          final height = pokemon['height' ?? 0] / 10;
          final weight = pokemon['weight'?? 0 ] / 10;

          final abilities = (pokemon['pokemon_v2_pokemonabilities'] as List?)
              ?.map((abilityData) {
            final ability = abilityData['pokemon_v2_ability'];
            final effectTexts = ability?['pokemon_v2_abilityeffecttexts'] as List?;
            return {
              'name': ability?['name'] ?? "Unknown",
              'effect': effectTexts != null && effectTexts.isNotEmpty
                  ? effectTexts[0]['short_effect']
                  : 'No effect available.',
            };
          }).toList() ?? [];
          final firstAbility = (abilities.isNotEmpty
              ? {
            'name': abilities[0]['name'] as String,
            'effect': abilities[0]['effect'] as String,
          }
              : {'name': 'Unknown', 'effect': 'No description available.'});

          final stats = pokemon['pokemon_v2_pokemonstats'] as List;

          final moves = (pokemon['pokemon_v2_pokemonmoves'] as List).map((moveData) {
            final move = moveData['pokemon_v2_move'];
            return {
              'level': moveData['level'] ?? 0,
              'name': move?['name'] ?? "Unknown",
              'type': move?['pokemon_v2_type']?['name'] ?? "Unknown",
              'damage_class': move?['damage_class']?['name'] ?? "Unknown",
              'power': move?['power']?.toString() ?? "—",
              'accuracy': move?['accuracy']?.toString() ?? "—",
              'pp': move?['pp']?.toString() ?? "—",
            };
          }).toList();

          // Eliminar duplicados exactos por nombre y nivel
          final uniqueMoves = moves.fold<List<Map<String, dynamic>>>([], (filtered, move) {
            if (!filtered.any((m) => m['name'] == move['name'])) {
              filtered.add(move);
            }
            return filtered;
          });

        //ordenar movimientos
        //   uniqueMoves.sort((a, b) => a['level'].compareTo(b['level']));

          final evolutionChainId = pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_evolutionchain']
          ['pokemon_v2_pokemonspecies'][0]['evolution_chain_id'];

          final evolutions = (pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_evolutionchain']
          ['pokemon_v2_pokemonspecies'] as List<dynamic>)
              .map((evo) => {
            'id': evo['id'],
            'name': evo['name'],
            'evolves_from_species_id': evo['evolves_from_species_id'],
            'evolution_chain_id': evo['evolution_chain_id'],
            'image':
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${evo['id']}.png',
          })
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
                                padding: const EdgeInsets.all(16.0),
                                children: [
                                  // Descripción
                                  PokemonInfoSection(
                                    title: "Description",
                                    primaryColor: primaryColor,
                                    content: [
                                      Container(
                                        padding: const EdgeInsets.all(12.0),
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
                                        child: Text(
                                          pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_pokemonspeciesflavortexts'][0]['flavor_text']
                                              .replaceAll("\n", " ")
                                              .replaceAll("\f", " "),
                                          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Detalles (Altura y Peso)
                                  PokemonInfoSection(
                                    title: "Details",
                                    primaryColor: primaryColor,
                                    content: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          DetailCard(title: "Height", value: "${height} m"),
                                          DetailCard(title: "Weight", value: "${weight} kg"),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Habilidades
                                  PokemonInfoSection(
                                    title: "Abilities",
                                    primaryColor: primaryColor,
                                    content: abilities.map((ability) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12.0),
                                        padding: const EdgeInsets.all(12.0),
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ability['name'][0].toUpperCase() + ability['name'].substring(1),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              ability['effect'],
                                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
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
                                                AlwaysStoppedAnimation<Color>(primaryColor),
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
                              EvolutionTree(evolutions: evolutions,evolutionChainId: evolutionChainId),
                              PokemonMovesTab(moves: uniqueMoves),
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
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    generateAndShareCard(
                      context,
                      _cardKey,
                      name,
                      imageUrl,
                      primaryType,
                      height,
                      weight,
                      firstAbility,
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: "Share Pokémon Card",
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
  final Color primaryColor;

  PokemonInfoSection(
      {required this.title, required this.content,required this.primaryColor, this.minHeight});

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
                color: primaryColor,
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

class DetailCard extends StatelessWidget {
  final String title;
  final String value;

  const DetailCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonMovesTab extends StatelessWidget {
  final List<dynamic> moves;

  PokemonMovesTab({required this.moves});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: moves.length,
      itemBuilder: (context, index) {
        final move = moves[index];

        return MoveCard(
          level: move['level'],
          name: move['name'],
          type: move['type'],
          damageClass: move['damage_class'],
          power: move['power'],
          accuracy: move['accuracy'],
          pp: move['pp'],
        );
      },
    );
  }
}

Future<void> generateAndShareCard(
    BuildContext context,
    GlobalKey cardKey,
    String name,
    String imageUrl,
    String type,
    double height,
    double weight,
    Map<String, String> ability) async {
  try {
    final Color cardColor = pokemonTypeColors[type.toLowerCase()] ?? Colors.grey;

    // Renderiza la tarjeta en un Overlay temporal
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 400,
            child: RepaintBoundary(
              key: cardKey,
              child: PokemonCard(
                name: name,
                imageUrl: imageUrl,
                type: type,
                height: height,
                weight: weight,
                abilityName: ability['name']!,
                abilityDescription: ability['effect']!,
                backgroundColor: cardColor,
              ),
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    // Espera para que el widget se renderice completamente
    await Future.delayed(const Duration(milliseconds: 500));

    final boundary = cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      print("No se pudo capturar la tarjeta.");
      overlayEntry.remove();
      return;
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      print("No se pudo capturar la tarjeta.");
      overlayEntry.remove();
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$name.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    overlayEntry.remove();

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Check out this Pokémon card: $name!",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enviando con éxito!'),
        backgroundColor: Colors.black12.withOpacity(0.3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    print("Error al compartir la tarjeta: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al compartir la imagen. Inténtalo nuevamente.'),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}