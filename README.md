Documentacion.

Esta app Pokedex, desarrollada en Flutter, permite explorar información detallada de Pokemon utilizando la API de PokeAPI mediante consultas GraphQL. Con funcionalidades como búsqueda, filtrado por tipos, generación, habilidades, y una lista de favoritos, la aplicación ofrece una experiencia interactiva y personalizable. Su interfaz incluye tarjetas visuales para mostrar estadísticas, habilidades, y cadenas evolutivas de manera clara y dinámica.

El uso de GraphQL como tecnología central permite optimizar la carga de datos al realizar consultas específicas y en tiempo real. La aplicación está configurada con un cliente GraphQL que utiliza HttpLink para la conexión y Hive como almacenamiento en caché. Consultas predefinidas como la obtención de listas de Pokémon y detalles individuales permiten acceder a los datos necesarios con eficiencia y flexibilidad, evitando solicitudes redundantes.

La estructura modular del código organiza la lógica en clases específicas: PokemonListScreen para la lista principal, PokemonDetailScreen para detalles individuales, y FavoritesScreen para gestionar favoritos. Widgets como PokemonCard y EvolutionTree mejoran la reutilización de componentes visuales. Además, la aplicación persiste datos de favoritos usando SharedPreferences y permite compartir tarjetas de Pokémon con imágenes personalizadas.

La integración de un diseño atractivo y colores basados en los tipos de Pokémon mejora la experiencia del usuario. Las decisiones de diseño centradas en la modularidad garantizan una aplicación escalable y fácil de mantener, con funcionalidades que pueden ampliarse sin afectar la estabilidad del sistema. En resumen, Pokédex combina tecnologías modernas y una interfaz intuitiva para ofrecer una herramienta informativa y entretenida.
