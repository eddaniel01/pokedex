import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
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

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterType = '';
  int? _filterGeneration;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokemon',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if(int.tryParse(value) != null){
                    _filterGeneration = int.parse(value);
                    _filterType = '';
                  } else {
                    _filterType = value.toLowerCase();
                    _filterGeneration = null;
                  }
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

                final List pokemons = result.data?['pokemon_v2_pokemon'];

                // Filtrar la lista de Pokémon por tipo o generacion
                final filteredPokemons = pokemons.where((pokemon) {
                  final types = pokemon['pokemon_v2_pokemontypes']
                      .map((type) => type['pokemon_v2_type']['name'].toLowerCase())
                      .toList();
                  final generationId = pokemon['pokemon_v2_pokemonspecy']?['generation_id'];

                  bool matchesType = types.contains(_filterType) || _filterType.isEmpty;
                  bool matchesGeneration = _filterGeneration == null || generationId == _filterGeneration;
                  return matchesType && matchesGeneration;
                }).toList();

                return ListView.builder(
                  itemCount: filteredPokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = filteredPokemons[index];
                    final name = pokemon['name'];
                    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png';
                    final types = pokemon['pokemon_v2_pokemontypes']
                        .map((type) => type['pokemon_v2_type']['name'])
                        .join(', ');
                    final generationId = pokemon['pokemon_v2_pokemonspecy']['generation_id'];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Theme.of(context).cardColor,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Hero(
                          tag: 'pokemon-image-${pokemon['id']}',
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          )
                        ),
                        title: Text(
                          name[0].toUpperCase() + name.substring(1),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          '$types | Generación: $generationId',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.secondary),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => PokemonDetailScreen(id: pokemon['id']),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
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
