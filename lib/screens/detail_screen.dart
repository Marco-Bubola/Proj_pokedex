import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class DetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Pokemon currentPokemon;
  List<PokemonEvolution> evolutions = [];
  Map<String, dynamic>? speciesInfo;
  bool isLoadingEvolutions = true;

  @override
  void initState() {
    super.initState();
    currentPokemon = widget.pokemon;
    loadPokemonDetails();
  }

  Future<void> loadPokemonDetails() async {
    setState(() => isLoadingEvolutions = true);
    
    // Buscar Pokémon completo com evoluções
    final pokemon = await PokemonService.getPokemonById(currentPokemon.id, includeEvolutions: true);
    final species = await PokemonService.getPokemonSpeciesInfo(currentPokemon.id);
    
    if (pokemon != null) {
      setState(() {
        currentPokemon = pokemon;
        evolutions = pokemon.evolutions;
        speciesInfo = species;
        isLoadingEvolutions = false;
      });
    }
  }

  Future<void> navigateToPokemon(int pokemonId) async {
    final pokemon = await PokemonService.getPokemonById(pokemonId);
    if (pokemon != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(pokemon: pokemon),
        ),
      );
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow[700]!;
      case 'psychic':
        return Colors.pink;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.brown;
      case 'fairy':
        return Colors.pink[200]!;
      case 'normal':
        return Colors.grey;
      case 'fighting':
        return Colors.red[800]!;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.orange[800]!;
      case 'flying':
        return Colors.blue[300]!;
      case 'bug':
        return Colors.green[400]!;
      case 'rock':
        return Colors.brown[400]!;
      case 'ghost':
        return Colors.purple[300]!;
      case 'steel':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatGrowthRate(String rate) {
    switch (rate) {
      case 'slow':
        return 'Lento';
      case 'medium':
        return 'Médio';
      case 'medium-slow':
        return 'Médio-Lento';
      case 'fast':
        return 'Rápido';
      case 'slow-then-very-fast':
        return 'Lento depois Muito Rápido';
      case 'fast-then-very-slow':
        return 'Rápido depois Muito Lento';
      default:
        return _capitalizeFirst(rate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = getTypeColor(currentPokemon.types.first);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // Botão para Pokémon anterior
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: currentPokemon.id > 1
                    ? () => navigateToPokemon(currentPokemon.id - 1)
                    : null,
                tooltip: 'Pokémon Anterior',
              ),
              // Botão para próximo Pokémon
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: currentPokemon.id < 1025
                    ? () => navigateToPokemon(currentPokemon.id + 1)
                    : null,
                tooltip: 'Próximo Pokémon',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                currentPokemon.formattedName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      currentPokemon.imageUrl.isNotEmpty
                          ? Image.network(
                              currentPokemon.imageUrl,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.catching_pokemon,
                                  size: 120,
                                  color: Colors.white.withOpacity(0.8),
                                );
                              },
                            )
                          : Icon(
                              Icons.catching_pokemon,
                              size: 120,
                              color: Colors.white.withOpacity(0.8),
                            ),
                      const SizedBox(height: 16),
                      Text(
                        currentPokemon.formattedId,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipos
                  const Text(
                    'Tipos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: currentPokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: getTypeColor(type),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Informações Físicas
                  const Text(
                    'Informações Físicas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.height,
                                  size: 32,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Altura',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentPokemon.heightInMeters.toStringAsFixed(1)} m',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 32,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Peso',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${currentPokemon.weightInKg.toStringAsFixed(1)} kg',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Estatísticas
                  const Text(
                    'Estatísticas Base',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...currentPokemon.stats.map((stat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                stat.formattedName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                stat.baseStat.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: stat.baseStat / 255,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),

                  // Habilidades
                  const Text(
                    'Habilidades',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: currentPokemon.abilities.map((ability) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ability.replaceAll('-', ' ').toUpperCase(),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Informações Adicionais
                  const Text(
                    'Informações Adicionais',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Experiência Base:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${currentPokemon.baseExperience} XP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (speciesInfo != null) ...[
                            const Divider(height: 24),
                            _buildInfoRow('Taxa de Captura:', '${speciesInfo!['capture_rate']}/255'),
                            const SizedBox(height: 8),
                            _buildInfoRow('Felicidade Base:', '${speciesInfo!['base_happiness']}/255'),
                            const SizedBox(height: 8),
                            _buildInfoRow('Crescimento:', _formatGrowthRate(speciesInfo!['growth_rate'])),
                            const SizedBox(height: 8),
                            _buildInfoRow('Habitat:', _capitalizeFirst(speciesInfo!['habitat'])),
                            const SizedBox(height: 8),
                            _buildInfoRow('Gênero:', speciesInfo!['gender_rate']),
                            const SizedBox(height: 8),
                            _buildInfoRow('Geração:', _capitalizeFirst(speciesInfo!['generation']).replaceAll('-', ' ')),
                            if (speciesInfo!['is_legendary'] == true || speciesInfo!['is_mythical'] == true) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  border: Border.all(color: Colors.amber),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      speciesInfo!['is_legendary'] == true ? 'LENDÁRIO' : 'MÍTICO',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (speciesInfo!['description'] != null && speciesInfo!['description'].toString().isNotEmpty) ...[
                              const Divider(height: 24),
                              const Text(
                                'Descrição:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                speciesInfo!['description'],
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Evoluções
                  if (evolutions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Evoluções',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoadingEvolutions)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: evolutions.length,
                        itemBuilder: (context, index) {
                          final evolution = evolutions[index];
                          return GestureDetector(
                            onTap: () => navigateToPokemon(evolution.id),
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        evolution.formattedId,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Image.network(
                                        evolution.imageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.catching_pokemon,
                                            size: 64,
                                            color: primaryColor,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      evolution.formattedName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (evolution.minLevel != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Nível ${evolution.minLevel}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}