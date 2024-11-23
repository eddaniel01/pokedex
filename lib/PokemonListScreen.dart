import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'pokemonTypeColors.dart';
import 'PokemonDetailScreen.dart';

const String getPokemonList = """
query {
  pokemon_v2_pokemon(limit: 600) {
    id
    name
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
    pokemon_v2_pokemonspecy {
      generation_id
    }
  }
}
""";

const String getPokemonTypes = """
query {
  pokemon_v2_type {
    name
  }
}
""";

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  String? _selectedType;
  int? _filterGeneration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar tipos
          Query(
            options: QueryOptions(document: gql(getPokemonTypes)),
            builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.isLoading) return Center(child: CircularProgressIndicator());
              if (result.hasException) return Center(child: Text(result.exception.toString()));

              final List types = result.data?['pokemon_v2_type'];

              // Agregar "Todos los Tipos" al inicio de la lista
              final allTypes = [
                {'name': 'Todos los Tipos'},
                ...types,
              ];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  hint: Text("Selecciona un tipo"),
                  value: _selectedType,
                  items: allTypes.map<DropdownMenuItem<String>>((type) {
                    final typeName = type['name'];
                    return DropdownMenuItem<String>(
                      value: typeName == 'Todos los Tipos' ? null : typeName,
                      child: Text(
                        typeName[0].toUpperCase() + typeName.substring(1),
                        style: TextStyle(
                          color: typeName == 'Todos los Tipos'
                              ? Colors.black
                              : pokemonTypeColors[typeName] ?? Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedType = value; // Actualizar el tipo seleccionado
                    });
                  },
                  isExpanded: true,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Query(
              options: QueryOptions(document: gql(getPokemonList)),
              builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.isLoading) return Center(child: CircularProgressIndicator());

                if (result.hasException) return Center(child: Text(result.exception.toString()));

                final List pokemons = result.data?['pokemon_v2_pokemon'];

                // Filtrar la lista de Pokémon
                final filteredPokemons = pokemons.where((pokemon) {
                  final types = pokemon['pokemon_v2_pokemontypes']
                      .map((type) => type['pokemon_v2_type']['name'])
                      .toList();
                  final generationId = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];

                  bool matchesType = _selectedType == null || types.contains(_selectedType);
                  bool matchesGeneration = _filterGeneration == null || generationId == _filterGeneration;
                  return matchesType && matchesGeneration;
                }).toList();

                // Mostrar Pokémon en una cuadrícula
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: filteredPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = filteredPokemons[index];
                    final name = pokemon['name'];
                    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png';
                    final types = pokemon['pokemon_v2_pokemontypes']
                        .map((type) => type['pokemon_v2_type']['name'])
                        .toList();
                    final primaryType = types[0];
                    final primaryColor = pokemonTypeColors[primaryType] ?? Colors.grey;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PokemonDetailScreen(id: pokemon['id']),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: primaryColor,
                        elevation: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.5),
                              radius: 50,
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                            SizedBox(height: 10),
                            Text(
                              name[0].toUpperCase() + name.substring(1),
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              primaryType.toUpperCase(),
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
