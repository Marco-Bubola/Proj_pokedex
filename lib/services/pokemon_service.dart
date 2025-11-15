import 'dart:convert';
import 'package:flutter/foundation.dart';
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
            debugPrint('DEBUG getPokemonByUrl: evolutions returned count=${evolutions.length} names=${evolutions.map((e) => e.name).toList()}');
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
            debugPrint('DEBUG getPokemonById: evolutions returned count=${evolutions.length} names=${evolutions.map((e) => e.name).toList()}');
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

      debugPrint('DEBUG getEvolutionChain: pokemonId=$pokemonId status=${speciesResponse.statusCode}');
      if (speciesResponse.statusCode != 200) return [];

      final speciesData = json.decode(speciesResponse.body);
      final evolutionChainUrl = speciesData['evolution_chain']['url'];
      debugPrint('DEBUG evolutionChainUrl=$evolutionChainUrl');

      // Buscar evolution chain
      final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl));
      
      debugPrint('DEBUG evolutionResponse status=${evolutionResponse.statusCode}');
      if (evolutionResponse.statusCode != 200) return [];

      final evolutionData = json.decode(evolutionResponse.body);
      debugPrint('DEBUG evolutionChain root=${evolutionData['chain']?['species']?['name']}');
      final parsed = _parseEvolutionChain(evolutionData['chain']);
      debugPrint('DEBUG parsed evolutions count=${parsed.length}');
      debugPrint('DEBUG parsed evolutions names=${parsed.map((e) => e.name).toList()}');
      return parsed;
    } catch (e) {
      return [];
    }
  }

  static List<PokemonEvolution> _parseEvolutionChain(Map<String, dynamic> chain) {
    List<PokemonEvolution> evolutions = [];

    void parseNode(Map<String, dynamic> node, {String? trigger, int? minLevel}) {
      try {
        debugPrint('DEBUG parseNode: species=${node['species']?['name']}');
        final species = node['species'];
        final pokemonName = species['name'];
        final pokemonUrl = species['url'];
        // Extrair id da URL, usando o penúltimo segmento para evitar problemas com barras finais
        final parts = pokemonUrl.split('/');
        final idSegment = parts.length >= 2 ? parts[parts.length - 2] : parts.last;
        final pokemonId = int.parse(idSegment);

        evolutions.add(PokemonEvolution(
          id: pokemonId,
          name: pokemonName,
          imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png',
          evolutionTrigger: trigger,
          minLevel: minLevel,
        ));
        debugPrint('DEBUG parseNode: added id=$pokemonId name=$pokemonName');

        if (node['evolves_to'] != null && node['evolves_to'].isNotEmpty) {
          for (var evo in node['evolves_to']) {
            String? nextTrigger;
            int? nextMinLevel;
            if (evo['evolution_details'] != null && evo['evolution_details'].isNotEmpty) {
              final details = evo['evolution_details'][0];
              nextTrigger = details['trigger']?['name'];
              nextMinLevel = details['min_level'];
            }
            parseNode(evo, trigger: nextTrigger, minLevel: nextMinLevel);
          }
        }
      } catch (e, st) {
        debugPrint('ERROR parseNode exception: $e');
        debugPrint('$st');
      }
    }

    parseNode(chain);
    return evolutions;
  }

  static Future<Map<String, dynamic>?> getPokemonSpeciesInfo(int pokemonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon-species/$pokemonId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Buscar descrição: preferir Português (pt) e usar Inglês (en) como fallback
        String description = '';
        for (var entry in data['flavor_text_entries']) {
          if (entry['language'] != null && entry['language']['name'] == 'pt') {
            description = entry['flavor_text'].toString().replaceAll('\n', ' ').replaceAll('\f', ' ');
            break;
          }
        }
        if (description.isEmpty) {
          for (var entry in data['flavor_text_entries']) {
            if (entry['language'] != null && entry['language']['name'] == 'en') {
              description = entry['flavor_text'].toString().replaceAll('\n', ' ').replaceAll('\f', ' ');
              break;
            }
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

    static Future<String?> getAbilityEffect(String abilityName) async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/ability/$abilityName'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Buscar descrição: preferir Português (pt), fallback Inglês (en)
          String? effect;
          for (var entry in data['effect_entries']) {
            if (entry['language'] != null && entry['language']['name'] == 'pt') {
              effect = entry['effect'].toString().replaceAll('\n', ' ').replaceAll('\f', ' ');
              break;
            }
          }
          if (effect == null) {
            for (var entry in data['effect_entries']) {
              if (entry['language'] != null && entry['language']['name'] == 'en') {
                effect = entry['effect'].toString().replaceAll('\n', ' ').replaceAll('\f', ' ');
                break;
              }
            }
          }
          if (effect == null) {
            // fallback para short_effect
            for (var entry in data['effect_entries']) {
              if (entry['language'] != null && entry['language']['name'] == 'en') {
                effect = entry['short_effect']?.toString();
                break;
              }
            }
          }
          return effect;
        }
        return null;
      } catch (e) {
        return null;
      }
    }
}