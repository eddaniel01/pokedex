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
    pokemon_v2_pokemonabilities {
      pokemon_v2_ability {
        name
      }
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

const String getPokemonAbilities = """
query {
  pokemon_v2_ability(order_by: {name: asc}) {
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
  String? _selectedAbility;
  String _searchQuery = '';
  String _sortBy = "id"; // Criterio de ordenación: "id" o "name"
  bool _isAscendingOrder = true; // Orden ascendente o descendente
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

  /// Mostrar filtros en un BottomSheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filtro por tipo
                Query(
                  options: QueryOptions(document: gql(getPokemonTypes)),
                  builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.isLoading) return Center(child: CircularProgressIndicator());
                    if (result.hasException) return Center(child: Text(result.exception.toString()));

                    final List types = result.data?['pokemon_v2_type'];
                    final allTypes = [{'name': 'Todos los Tipos'}, ...types];

                    return DropdownButton<String>(
                      hint: Text("Filtrar por Tipo"),
                      value: _selectedType,
                      items: allTypes.map<DropdownMenuItem<String>>((type) {
                        final typeName = type['name'];
                        return DropdownMenuItem<String>(
                          value: typeName == 'Todos los Tipos' ? null : typeName,
                          child: Text(typeName[0].toUpperCase() + typeName.substring(1)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setBottomSheetState(() {
                          _selectedType = value;
                        });
                      },
                      isExpanded: true,
                    );
                  },
                ),
                SizedBox(height: 16.0),
                // Filtro por generación
                DropdownButton<int>(
                  hint: Text("Filtrar por Generación"),
                  value: _selectedGeneration,
                  items: [
                    DropdownMenuItem<int>(value: null, child: Text("Todas las Generaciones")),
                    for (int generation = 1; generation <= 8; generation++)
                      DropdownMenuItem<int>(
                        value: generation,
                        child: Text("Generación $generation"),
                      ),
                  ],
                  onChanged: (int? value) {
                    setBottomSheetState(() {
                      _selectedGeneration = value;
                    });
                  },
                  isExpanded: true,
                ),
                SizedBox(height: 16.0),
                // Filtro por habilidad
                Query(
                  options: QueryOptions(document: gql(getPokemonAbilities)),
                  builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.isLoading) return Center(child: CircularProgressIndicator());
                    if (result.hasException) return Center(child: Text(result.exception.toString()));

                    final List abilities = result.data?['pokemon_v2_ability'];
                    final allAbilities = [{'name': 'Todas las Habilidades'}, ...abilities];

                    return DropdownButton<String>(
                      hint: Text("Filtrar por Habilidad"),
                      value: _selectedAbility,
                      items: allAbilities.map<DropdownMenuItem<String>>((ability) {
                        final abilityName = ability['name'];
                        return DropdownMenuItem<String>(
                          value: abilityName == 'Todas las Habilidades' ? null : abilityName,
                          child: Text(abilityName[0].toUpperCase() + abilityName.substring(1)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setBottomSheetState(() {
                          _selectedAbility = value;
                        });
                      },
                      isExpanded: true,
                    );
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el BottomSheet
                    setState(() {}); // Aplicar los filtros seleccionados
                  },
                  child: Text("Aplicar Filtros"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "id", child: Text("Ordenar por ID")),
              PopupMenuItem(value: "name", child: Text("Ordenar por Nombre")),
            ],
          ),
          IconButton(
            icon: Icon(_isAscendingOrder ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: "Ordenar de manera ascendente/descendente",
            onPressed: () {
              setState(() {
                _isAscendingOrder = !_isAscendingOrder; // Alternar el orden
              });
            },
          ),
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
          Expanded(
            child: Query(
              options: QueryOptions(document: gql(getPokemonList)),
              builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.isLoading) return Center(child: CircularProgressIndicator());
                if (result.hasException) return Center(child: Text(result.exception.toString()));

                var filteredPokemons = result.data?['pokemon_v2_pokemon'];

                // Filtrar Pokémon
                filteredPokemons = filteredPokemons.where((pokemon) {
                  final name = pokemon['name'].toLowerCase();
                  final id = pokemon['id'].toString();
                  final types = (pokemon['pokemon_v2_pokemontypes'] as List)
                      .map((type) => type['pokemon_v2_type']['name'])
                      .toList();
                  final generationId = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];
                  final abilities = (pokemon['pokemon_v2_pokemonabilities'] as List)
                      .map((ability) => ability['pokemon_v2_ability']['name'])
                      .toList();

                  return (_searchQuery.isEmpty || name.contains(_searchQuery) || id.contains(_searchQuery)) &&
                      (_selectedType == null || types.contains(_selectedType)) &&
                      (_selectedGeneration == null || generationId == _selectedGeneration) &&
                      (_selectedAbility == null || abilities.contains(_selectedAbility));
                }).toList();

                // Ordenar Pokémon según el criterio seleccionado
                filteredPokemons.sort((a, b) {
                  if (_sortBy == "id") {
                    final idA = a['id'] as int;
                    final idB = b['id'] as int;
                    return _isAscendingOrder ? idA.compareTo(idB) : idB.compareTo(idA);
                  } else if (_sortBy == "name") {
                    final nameA = a['name'] as String;
                    final nameB = b['name'] as String;
                    return _isAscendingOrder ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
                  }
                  return 0;
                });

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
                              "#${id.toString().padLeft(3, '0')}",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        child: Icon(Icons.filter_alt),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
