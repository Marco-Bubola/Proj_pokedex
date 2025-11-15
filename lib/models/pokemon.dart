class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<PokemonStat> stats;
  final List<String> abilities;
  final List<String> moves;
  final String? species;
  final String? habitat;
  final String? color;
  final int baseExperience;
  final List<PokemonEvolution> evolutions;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
    required this.moves,
    this.species,
    this.habitat,
    this.color,
    required this.baseExperience,
    required this.evolutions,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json, {List<PokemonEvolution>? evolutions}) {
    final List<String> typesList = [];
    for (var type in json['types']) {
      typesList.add(type['type']['name']);
    }

    final List<PokemonStat> statsList = [];
    for (var stat in json['stats']) {
      statsList.add(PokemonStat.fromJson(stat));
    }

    final List<String> abilitiesList = [];
    for (var ability in json['abilities']) {
      abilitiesList.add(ability['ability']['name']);
    }

    final List<String> movesList = [];
    for (var m in json['moves']) {
      movesList.add(m['move']['name']);
    }

    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ?? 
                json['sprites']['front_default'] ?? '',
      types: typesList,
      height: json['height'],
      weight: json['weight'],
      stats: statsList,
      abilities: abilitiesList,
      moves: movesList,
      baseExperience: json['base_experience'] ?? 0,
      evolutions: evolutions ?? [],
    );
  }

  String get formattedName {
    return name[0].toUpperCase() + name.substring(1);
  }

  String get formattedId {
    return '#${id.toString().padLeft(3, '0')}';
  }

  double get heightInMeters {
    return height / 10.0;
  }

  double get weightInKg {
    return weight / 10.0;
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({
    required this.name,
    required this.baseStat,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'],
      baseStat: json['base_stat'],
    );
  }

  String get formattedName {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Ataque';
      case 'defense':
        return 'Defesa';
      case 'special-attack':
        return 'Ataque Especial';
      case 'special-defense':
        return 'Defesa Especial';
      case 'speed':
        return 'Velocidade';
      default:
        return name;
    }
  }
}

class PokemonEvolution {
  final int id;
  final String name;
  final String imageUrl;
  final String? evolutionTrigger;
  final int? minLevel;

  PokemonEvolution({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.evolutionTrigger,
    this.minLevel,
  });

  String get formattedName {
    return name[0].toUpperCase() + name.substring(1);
  }

  String get formattedId {
    return '#${id.toString().padLeft(3, '0')}';
  }
}