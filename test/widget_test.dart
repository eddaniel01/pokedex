import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pokedex_app/main.dart';
 // Importa tu archivo principal donde está definida MyApp

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Configura el GraphQLClient simulado para pruebas
    final HttpLink httpLink = HttpLink('https://beta.pokeapi.co/graphql/v1beta');
    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()), // Usa InMemoryStore para evitar errores de Hive en pruebas
    );

    // Construye la aplicación con el cliente
    await tester.pumpWidget(MyApp(client: client));

    // Aquí puedes añadir el resto de tus pruebas
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
