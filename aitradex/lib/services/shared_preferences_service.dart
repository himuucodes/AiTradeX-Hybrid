import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/signup_model.dart';

class SharedPreferencesService {
  SharedPreferencesService._();

  static const String _signupKey = "signup_data";
  static const String _isLoggedInKey = "is_logged_in";
  static const String _userIdKey = "user_id";
  static const String _authTokenKey = "auth_token";

  // -------------------------------
  // Save Complete Signup Data
  // -------------------------------
  static Future<void> saveSignupData(SignupModel model) async {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(model.toJson());

    await prefs.setString(_signupKey, json);
  }

  // -------------------------------
  // Get Saved Signup Data
  // -------------------------------
  static Future<SignupModel?> getSignupData() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(_signupKey);

    if (json == null || json.isEmpty) {
      return null;
    }

    return SignupModel.fromJson(jsonDecode(json));
  }

  // -------------------------------
  // Check Draft Exists
  // -------------------------------
  static Future<bool> hasSignupData() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_signupKey);
  }

  // -------------------------------
  // Remove Signup Draft
  // -------------------------------
  static Future<void> clearSignupData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_signupKey);
  }

  // -------------------------------
  // Login Status
  // -------------------------------
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // -------------------------------
  // User ID
  // -------------------------------
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userIdKey, id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userIdKey);
  }

  // -------------------------------
  // Auth Token (JWT)
  // -------------------------------
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_authTokenKey);
  }

  // -------------------------------
  // Logout
  // -------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_signupKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_isLoggedInKey);
  }

  // -------------------------------
  // Clear Everything
  // -------------------------------
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}