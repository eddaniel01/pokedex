import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'PokemonListScreen.dart';
//import 'screens/home_screen.dart'; // Asegúrate de crear este archivo y pantalla

void main() async {

  //inicializando BD Hive
  await initHiveForFlutter();

  //enlace Http a la url de la api
  final HttpLink httpLink = HttpLink(
    'https://beta.pokeapi.co/graphql/v1beta',
  );

  final GraphQLClient client = GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: HiveStore()),
  );

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final GraphQLClient client;

  MyApp({required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier(client),
      child: MaterialApp(
        title: 'Pokédex',
        theme: ThemeData(
          primaryColor: Color(0xFFFF1C1C),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Color(0xFFFFCC00),
          ),
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
          cardColor: Color(0xFFE1F5FE),
          textTheme: TextTheme(
            titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Colors.grey[800]),
          ),
        ),
        home: PokemonListScreen(),
      ),
    );
  }
}