import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_mode.dart';

class StorageService {
  static const String _timedHighestScoreKey = 'timed_highest_score';
  static const String _unlimitedHighestScoreKey = 'unlimited_highest_score';
  static const String _unlimitedBestTimeKey = 'unlimited_best_time';
  static const String _gameStateKey = 'game_state';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  int getHighestScore(GameMode mode) {
    String key = mode == GameMode.timed 
        ? _timedHighestScoreKey 
        : _unlimitedHighestScoreKey;
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> setHighestScore(GameMode mode, int score) async {
    try {
      String key = mode == GameMode.timed 
          ? _timedHighestScoreKey 
          : _unlimitedHighestScoreKey;
      int currentHighest = getHighestScore(mode);
      if (score > currentHighest) {
        await _prefs.setInt(key, score);
      }
    } catch (e) {
      print('Error saving highest score: $e');
    }
  }

  int getBestTime() {
    return _prefs.getInt(_unlimitedBestTimeKey) ?? 0;
  }

  Future<void> setBestTime(int timeInSeconds) async {
    try {
      int currentBest = getBestTime();
      if (currentBest == 0 || timeInSeconds < currentBest) {
        await _prefs.setInt(_unlimitedBestTimeKey, timeInSeconds);
      }
    } catch (e) {
      print('Error saving best time: $e');
    }
  }

  Future<void> saveGameState(Map<String, dynamic> gameState) async {
    try {
      gameState['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      String jsonString = jsonEncode(gameState);
      await _prefs.setString(_gameStateKey, jsonString);
    } catch (e) {
      print('Error saving game state: $e');
    }
  }

  Map<String, dynamic>? getGameState() {
    try {
      String? jsonString = _prefs.getString(_gameStateKey);
      if (jsonString == null) return null;

      Map<String, dynamic> gameState = jsonDecode(jsonString);

      int timestamp = gameState['timestamp'] ?? 0;
      const int expirationTime = 24 * 60 * 60 * 1000;
      if (DateTime.now().millisecondsSinceEpoch - timestamp > expirationTime) {
        return null;
      }

      return gameState;
    } catch (e) {
      print('Error restoring game state: $e');
      return null;
    }
  }

  Future<void> clearGameState() async {
    try {
      await _prefs.remove(_gameStateKey);
    } catch (e) {
      print('Error clearing game state: $e');
    }
  }
}

class StorageServiceProvider {
  static StorageService? _instance;

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _instance = StorageService(prefs);
    }
    return _instance!;
  }
}
