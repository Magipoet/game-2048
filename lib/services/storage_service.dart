import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_mode.dart';

class StorageService {
  static const String _timedNormalHighestScoreKey = 'timed_normal_highest_score';
  static const String _timedFunHighestScoreKey = 'timed_fun_highest_score';
  static const String _unlimitedNormalHighestScoreKey =
      'unlimited_normal_highest_score';
  static const String _unlimitedFunHighestScoreKey =
      'unlimited_fun_highest_score';
  static const String _unlimitedNormalBestTimeKey =
      'unlimited_normal_best_time';
  static const String _unlimitedFunBestTimeKey = 'unlimited_fun_best_time';
  static const String _gameStateKey = 'game_state';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  String _highestScoreKey(GameMode mode, GameVariant variant) {
    if (mode == GameMode.timed) {
      return variant == GameVariant.fun
          ? _timedFunHighestScoreKey
          : _timedNormalHighestScoreKey;
    }
    return variant == GameVariant.fun
        ? _unlimitedFunHighestScoreKey
        : _unlimitedNormalHighestScoreKey;
  }

  String _bestTimeKey(GameVariant variant) {
    return variant == GameVariant.fun
        ? _unlimitedFunBestTimeKey
        : _unlimitedNormalBestTimeKey;
  }

  int getHighestScore(GameMode mode, GameVariant variant) {
    return _prefs.getInt(_highestScoreKey(mode, variant)) ?? 0;
  }

  Future<void> setHighestScore(
      GameMode mode, GameVariant variant, int score) async {
    try {
      String key = _highestScoreKey(mode, variant);
      int currentHighest = getHighestScore(mode, variant);
      if (score > currentHighest) {
        await _prefs.setInt(key, score);
      }
    } catch (e) {
      print('Error saving highest score: $e');
    }
  }

  int getBestTime(GameVariant variant) {
    return _prefs.getInt(_bestTimeKey(variant)) ?? 0;
  }

  Future<void> setBestTime(GameVariant variant, int timeInSeconds) async {
    try {
      String key = _bestTimeKey(variant);
      int currentBest = getBestTime(variant);
      if (currentBest == 0 || timeInSeconds < currentBest) {
        await _prefs.setInt(key, timeInSeconds);
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
