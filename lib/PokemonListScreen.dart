import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Para jsonEncode y jsonDecode
import 'PokemonDetailScreen.dart';
import 'FavoritesScreen.dart';
import 'pokemonTypeColors.dart';

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
  int? _selectedGeneration;
  String _searchQuery = '';
  List<Map<String, dynamic>> _favoritePokemons = []; // Lista de favoritos con detalles

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Cargar favoritos desde SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getString('favorites');
    if (savedFavorites != null) {
      setState(() {
        _favoritePokemons = List<Map<String, dynamic>>.from(jsonDecode(savedFavorites));
      });
    }
  }

  /// Guardar favoritos en SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', jsonEncode(_favoritePokemons));
  }

  /// Alternar estado de favorito
  Future<void> _toggleFavorite(Map<String, dynamic> pokemon) async {
    setState(() {
      final index = _favoritePokemons.indexWhere((p) => p['id'] == pokemon['id']);
      if (index != -1) {
        _favoritePokemons.removeAt(index);
      } else {
        _favoritePokemons.add(pokemon);
      }
    });
    await _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(favoritePokemons: _favoritePokemons),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Filtros de tipo y generación
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Dropdown para seleccionar tipos
                Expanded(
                  child: Query(
                    options: QueryOptions(document: gql(getPokemonTypes)),
                    builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (result.isLoading) return Center(child: CircularProgressIndicator());
                      if (result.hasException) return Center(child: Text(result.exception.toString()));

                      final List types = result.data?['pokemon_v2_type'];
                      final allTypes = [{'name': 'Todos los Tipos'}, ...types];

                      return DropdownButton<String>(
                        hint: Text("Tipo"),
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
                            _selectedType = value;
                          });
                        },
                        isExpanded: true,
                        underline: SizedBox(),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                // Dropdown para seleccionar generación
                Expanded(
                  child: DropdownButton<int>(
                    hint: Text("Generación"),
                    value: _selectedGeneration,
                    items: [
                      DropdownMenuItem<int>(value: null, child: Text("Generación")),
                      for (int generation = 1; generation <= 8; generation++)
                        DropdownMenuItem<int>(
                          value: generation,
                          child: Text("Gen $generation"),
                        ),
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        _selectedGeneration = value;
                      });
                    },
                    isExpanded: true,
                    underline: SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Query(
              options: QueryOptions(document: gql(getPokemonList)),
              builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.isLoading) return Center(child: CircularProgressIndicator());
                if (result.hasException) return Center(child: Text(result.exception.toString()));

                final List pokemons = result.data?['pokemon_v2_pokemon'];

                final filteredPokemons = pokemons.where((pokemon) {
                  final name = pokemon['name'].toLowerCase();
                  final types = (pokemon['pokemon_v2_pokemontypes'] as List)
                      .map((type) => type['pokemon_v2_type']['name'])
                      .toList();
                  final generationId = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];

                  return (_searchQuery.isEmpty || name.contains(_searchQuery)) &&
                      (_selectedType == null || types.contains(_selectedType)) &&
                      (_selectedGeneration == null || generationId == _selectedGeneration);
                }).toList();

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
                    final id = pokemon['id'];
                    final name = pokemon['name'];
                    final types = (pokemon['pokemon_v2_pokemontypes'] as List)
                        .map((type) => type['pokemon_v2_type']['name'])
                        .toList();
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: pokemonTypeColors[types[0]] ?? Colors.grey,
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
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: types.map((type) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: pokemonTypeColors[type] ?? Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                            ),
                            IconButton(
                              icon: Icon(
                                _favoritePokemons.any((p) => p['id'] == id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _favoritePokemons.any((p) => p['id'] == id) ? Colors.red : Colors.white,
                              ),
                              iconSize: 20,
                              onPressed: () {
                                _toggleFavorite({
                                  'id': id,
                                  'name': name,
                                  'types': types,
                                  'imageUrl': imageUrl,
                                });
                              },
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
