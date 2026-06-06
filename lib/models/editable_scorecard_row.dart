import 'package:flutter/material.dart';

class EditableScorecardRow {
  final String playerName;
  final TextEditingController runsController;
  final TextEditingController ballsController;
  final TextEditingController wicketsController;
  bool isLate;
  bool isNotOut;

  EditableScorecardRow({
    required this.playerName,
    required this.runsController,
    required this.ballsController,
    required this.wicketsController,
    this.isLate = false,
    this.isNotOut = false,
  });

  factory EditableScorecardRow.fromMap(Map<String, dynamic> map) {
    return EditableScorecardRow(
      playerName: map['playerName']?.toString() ?? '',
      runsController: TextEditingController(
        text: _formatNum(map['runsScored']),
      ),
      ballsController: TextEditingController(
        text: _formatNum(map['balls']),
      ),
      wicketsController: TextEditingController(
        text: _formatNum(map['wickets']),
      ),
      isLate: map['isLate'] == true,
      isNotOut: map['isNotOut'] == true,
    );
  }

  static String _formatNum(dynamic v) {
    if (v == null) return '0';
    if (v is num) return v.toInt().toString();
    return int.tryParse(v.toString())?.toString() ?? '0';
  }

  int get runsScored => int.tryParse(runsController.text.trim()) ?? 0;
  int get balls => int.tryParse(ballsController.text.trim()) ?? 0;
  int get wickets => int.tryParse(wicketsController.text.trim()) ?? 0;

  int get adjustedRuns {
    var adjusted = runsScored;
    if (isNotOut) adjusted += 10;
    if (isLate) adjusted -= 10;
    return adjusted;
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'playerName': playerName,
      'runsScored': runsScored,
      'balls': balls,
      'wickets': wickets,
      'isLate': isLate,
      'isNotOut': isNotOut,
      'adjustedRuns': adjustedRuns,
    };
  }

  void dispose() {
    runsController.dispose();
    ballsController.dispose();
    wicketsController.dispose();
  }
}
