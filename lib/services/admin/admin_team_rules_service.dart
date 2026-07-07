import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import 'package:teamawesomesozeith/services/team_rules_service.dart';

class AdminTeamRulesService {
  static Future<TeamRulesData> fetchRules() =>
      TeamRulesService.fetchRulesForAdmin();

  static Future<TeamRulesData> saveRules(List<String> rules) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/team-rules'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rules': rules}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        TeamRulesService.errorMessage(
          statusCode: response.statusCode,
          body: response.body,
          forAdmin: true,
          fallback: 'Could not publish team rules. Please try again.',
        ),
      );
    }

    final json = TeamRulesService.parseJsonMap(
      response.body,
      forAdmin: true,
      fallback: 'Could not confirm rules were saved. Please try again.',
    );
    return TeamRulesData.fromJson(json);
  }
}
