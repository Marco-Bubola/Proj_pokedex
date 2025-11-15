import 'dart:math' as math;
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
  bool _isShiny = false;
  bool _showAllMoves = false;
  final int _movesPreviewLimit = 20;

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
        // mostrar toda a cadeia menos o próprio Pokémon (evita auto-navegação)
        evolutions = pokemon.evolutions.where((e) => e.id != pokemon.id).toList();
        speciesInfo = species;
        isLoadingEvolutions = false;
      });

    }
      debugPrint('DEBUG: Pokemon ${currentPokemon.name} abilities count=${currentPokemon.abilities.length}');
      debugPrint('DEBUG: abilities=${currentPokemon.abilities}');
      debugPrint('DEBUG: evolutions count=${evolutions.length}');
      debugPrint('DEBUG: evolutions=${evolutions.map((e) => e.name).toList()}');
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
    final displayImageUrl = (_isShiny && currentPokemon.imageShinyUrl.isNotEmpty)
      ? currentPokemon.imageShinyUrl
      : currentPokemon.imageUrl;

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
                      primaryColor.withAlpha((0.7 * 255).round()),
                    ],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    if (isWide) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 24),
                          // Left: imagem do Pokémon
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 24),
                                displayImageUrl.isNotEmpty
                                    ? LayoutBuilder(builder: (ctx, imgConstraints) {
                                        // calcula altura máxima disponível para a imagem (evita overflow)
                                        final maxImgHeight = math.max(80.0, imgConstraints.maxHeight * 0.6);
                                        final imgHeight = math.min(200.0, maxImgHeight);
                                        return SizedBox(
                                          height: imgHeight + 8, // espaço para badge
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned.fill(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Image.network(
                                                    displayImageUrl,
                                                    height: imgHeight,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Icon(
                                                        Icons.catching_pokemon,
                                                        size: 120,
                                                        color: Colors.white.withAlpha((0.8 * 255).round()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              // botão de shiny posicionado sobre a imagem (não aumenta altura)
                                              Positioned(
                                                right: 8,
                                                bottom: 8,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      tooltip: _isShiny ? 'Desativar Shiny' : 'Ativar Shiny',
                                                      icon: Icon(Icons.auto_awesome, color: _isShiny ? Colors.yellowAccent : Colors.white),
                                                      onPressed: () {
                                                        if (currentPokemon.imageShinyUrl.isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Shiny não disponível para este Pokémon.')),
                                                          );
                                                          return;
                                                        }
                                                        setState(() {
                                                          _isShiny = !_isShiny;
                                                        });
                                                      },
                                                    ),
                                                    if (_isShiny)
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withAlpha((0.15 * 255).round()),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Text('SHINY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                    : Icon(
                                        Icons.catching_pokemon,
                                        size: 120,
                                        color: Colors.white.withAlpha((0.8 * 255).round()),
                                      ),
                                const SizedBox(height: 12),
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

                          // Right: Evoluções
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Evoluções',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (evolutions.isEmpty) ...[
                                  const Text('Sem evoluções visíveis', style: TextStyle(color: Colors.white70)),
                                ] else ...[
                                  SizedBox(
                                    height: 180,
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: evolutions.length,
                                      itemBuilder: (context, index) {
                                        final evo = evolutions[index];
                                        return GestureDetector(
                                          onTap: () => navigateToPokemon(evo.id),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 64,
                                                  height: 64,
                                                  child: Image.network(
                                                    evo.imageUrl,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (c, e, s) => Icon(Icons.catching_pokemon, color: Colors.white.withAlpha((0.9 * 255).round())),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(evo.formattedName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 4),
                                                      Text(evo.formattedId, style: TextStyle(color: Colors.white70, fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
                          const SizedBox(width: 24),
                        ],
                      );
                    }

                    // Narrow layout: keep image centered and evolutions below
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        displayImageUrl.isNotEmpty
                            ? LayoutBuilder(builder: (ctx, imgConstraints) {
                                final maxImgHeight = math.max(64.0, imgConstraints.maxHeight * 0.6);
                                final imgHeight = math.min(160.0, maxImgHeight);
                                return SizedBox(
                                  height: imgHeight + 8,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Image.network(
                                            displayImageUrl,
                                            height: imgHeight,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.catching_pokemon,
                                                size: 120,
                                                color: Colors.white.withAlpha((0.8 * 255).round()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: _isShiny ? 'Desativar Shiny' : 'Ativar Shiny',
                                              icon: Icon(Icons.auto_awesome, color: _isShiny ? Colors.yellowAccent : Colors.white),
                                              onPressed: () {
                                                if (currentPokemon.imageShinyUrl.isEmpty) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Shiny não disponível para este Pokémon.')),
                                                  );
                                                  return;
                                                }
                                                setState(() {
                                                  _isShiny = !_isShiny;
                                                });
                                              },
                                            ),
                                            if (_isShiny)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withAlpha((0.15 * 255).round()),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text('SHINY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                            : Icon(
                                Icons.catching_pokemon,
                                size: 120,
                                color: Colors.white.withAlpha((0.8 * 255).round()),
                              ),
                        const SizedBox(height: 12),
                        Text(
                          currentPokemon.formattedId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (evolutions.isNotEmpty) ...[
                          const Text('Evoluções', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: evolutions.length,
                              itemBuilder: (context, index) {
                                final evo = evolutions[index];
                                return GestureDetector(
                                  onTap: () => navigateToPokemon(evo.id),
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Image.network(
                                            evo.imageUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (c, e, s) => Icon(Icons.catching_pokemon, color: Colors.white.withAlpha((0.9 * 255).round())),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(evo.formattedName, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  },
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

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                            color: Colors.amber.withAlpha((0.2 * 255).round()),
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
                                      // descrição removida daqui para exibir em largura total abaixo
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Descrição (largura total) com visual mais moderno
                  if (speciesInfo != null && speciesInfo!['description'] != null && speciesInfo!['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descrição',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              speciesInfo!['description'],
                              style: const TextStyle(fontSize: 14, height: 1.4),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

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
                      return ActionChip(
                        label: Text(ability.replaceAll('-', ' ').toUpperCase()),
                        backgroundColor: primaryColor.withAlpha((0.12 * 255).round()),
                        labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        onPressed: () async {
                          // Captura o contexto antes do await para evitar o lint
                          final localContext = context;
                          showDialog(
                            context: localContext,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          final effect = await PokemonService.getAbilityEffect(ability);

                          if (!mounted) return;
                          Navigator.of(localContext).pop();

                          showDialog(
                            context: localContext,
                            builder: (c) => AlertDialog(
                              title: Text(ability.replaceAll('-', ' ').toUpperCase()),
                              content: SingleChildScrollView(child: Text(effect ?? 'Descrição não disponível.')),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(localContext).pop(), child: const Text('Fechar')),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Movimentos
                  const Text(
                    'Movimentos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final moves = currentPokemon.moves;
                    final displayedMoves = _showAllMoves ? moves : moves.take(_movesPreviewLimit).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: displayedMoves.map((move) {
                            return Chip(
                              label: Text(move.replaceAll('-', ' ').toUpperCase()),
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            );
                          }).toList(),
                        ),
                        if (moves.length > _movesPreviewLimit) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showAllMoves = !_showAllMoves;
                                });
                              },
                              child: Text(_showAllMoves
                                  ? 'Mostrar menos'
                                  : 'Mostrar todos (${moves.length})'),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}