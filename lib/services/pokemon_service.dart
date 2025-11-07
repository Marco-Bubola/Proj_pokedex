import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  static Future<List<Pokemon>> getPokemons({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        List<Pokemon> pokemons = [];
        for (var result in results) {
          final pokemon = await getPokemonByUrl(result['url']);
          if (pokemon != null) {
            pokemons.add(pokemon);
          }
        }
        return pokemons;
      } else {
        throw Exception('Falha ao carregar Pokémons');
      }
    } catch (e) {
      throw Exception('Erro de rede: $e');
    }
  }

  static Future<Pokemon?> getPokemonByUrl(String url, {bool includeEvolutions = false}) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<PokemonEvolution> evolutions = [];
        
        if (includeEvolutions) {
          evolutions = await getEvolutionChain(data['id']);
        }
        
        return Pokemon.fromJson(data, evolutions: evolutions);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Pokemon?> getPokemonById(int id, {bool includeEvolutions = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<PokemonEvolution> evolutions = [];
        
        if (includeEvolutions) {
          evolutions = await getEvolutionChain(id);
        }
        
        return Pokemon.fromJson(data, evolutions: evolutions);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PokemonEvolution>> getEvolutionChain(int pokemonId) async {
    try {
      // Buscar species para pegar evolution chain
      final speciesResponse = await http.get(
        Uri.parse('$baseUrl/pokemon-species/$pokemonId'),
      );

      if (speciesResponse.statusCode != 200) return [];

      final speciesData = json.decode(speciesResponse.body);
      final evolutionChainUrl = speciesData['evolution_chain']['url'];

      // Buscar evolution chain
      final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
      
      if (evolutionResponse.statusCode != 200) return [];

      final evolutionData = json.decode(evolutionResponse.body);
      return _parseEvolutionChain(evolutionData['chain']);
    } catch (e) {
      return [];
    }
  }

  static List<PokemonEvolution> _parseEvolutionChain(Map<String, dynamic> chain) {
    List<PokemonEvolution> evolutions = [];
    
    void parseChain(Map<String, dynamic> currentChain) {
      if (currentChain['evolves_to'] != null && currentChain['evolves_to'].isNotEmpty) {
        for (var evolution in currentChain['evolves_to']) {
          final pokemonName = evolution['species']['name'];
          final pokemonUrl = evolution['species']['url'];
          final pokemonId = int.parse(pokemonUrl.split('/').where((s) => s.isNotEmpty).last);
          
          String? trigger;
          int? minLevel;
          
          if (evolution['evolution_details'] != null && evolution['evolution_details'].isNotEmpty) {
            final details = evolution['evolution_details'][0];
            trigger = details['trigger']['name'];
            minLevel = details['min_level'];
          }

          evolutions.add(PokemonEvolution(
            id: pokemonId,
            name: pokemonName,
            imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png',
            evolutionTrigger: trigger,
            minLevel: minLevel,
          ));

          // Recursão para evoluções em cadeia
          parseChain(evolution);
        }
      }
    }

    parseChain(chain);
    return evolutions;
  }

  static Future<Map<String, dynamic>?> getPokemonSpeciesInfo(int pokemonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon-species/$pokemonId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Buscar descrição em português ou inglês
        String description = '';
        for (var entry in data['flavor_text_entries']) {
          if (entry['language']['name'] == 'en') {
            description = entry['flavor_text'].toString().replaceAll('\n', ' ').replaceAll('\f', ' ');
            break;
          }
        }

        // Buscar gênero
        String genderRate = 'Desconhecido';
        if (data['gender_rate'] != null) {
          int rate = data['gender_rate'];
          if (rate == -1) {
            genderRate = 'Sem Gênero';
          } else {
            int femalePercent = ((rate / 8) * 100).round();
            int malePercent = 100 - femalePercent;
            genderRate = '♂ $malePercent% / ♀ $femalePercent%';
          }
        }

        return {
          'description': description,
          'capture_rate': data['capture_rate'],
          'base_happiness': data['base_happiness'],
          'growth_rate': data['growth_rate']['name'],
          'habitat': data['habitat']?['name'] ?? 'Desconhecido',
          'generation': data['generation']['name'],
          'is_legendary': data['is_legendary'],
          'is_mythical': data['is_mythical'],
          'gender_rate': genderRate,
          'egg_groups': (data['egg_groups'] as List).map((e) => e['name']).toList(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}