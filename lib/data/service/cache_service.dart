import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoshlar/data/model/auth_user.dart';
import 'package:yoshlar/data/model/category.dart';
import 'package:yoshlar/data/model/region.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  // Kesh kalitlari
  static const _regionsKey = 'cached_regions';
  static const _categoriesKey = 'cached_categories';
  static const _authUserKey = 'cached_auth_user';
  static const _timestampPrefix = 'cache_ts_';

  // Kesh muddatlari
  static const _regionsTtl = Duration(days: 7);
  static const _categoriesTtl = Duration(days: 7);
  static const _authUserTtl = Duration(hours: 24);

  // ==================== Regions ====================

  Future<List<RegionModel>?> getCachedRegions() async {
    if (_isExpired(_regionsKey, _regionsTtl)) return null;
    final json = _prefs.getString(_regionsKey);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheRegions(List<RegionModel> regions) async {
    final json = jsonEncode(regions.map((e) => e.toJson()).toList());
    await _prefs.setString(_regionsKey, json);
    _setTimestamp(_regionsKey);
  }

  // ==================== Categories ====================

  Future<List<CategoryModel>?> getCachedCategories() async {
    if (_isExpired(_categoriesKey, _categoriesTtl)) return null;
    final json = _prefs.getString(_categoriesKey);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final json = jsonEncode(categories.map((e) => e.toJson()).toList());
    await _prefs.setString(_categoriesKey, json);
    _setTimestamp(_categoriesKey);
  }

  // ==================== Auth User ====================

  Future<AuthUser?> getCachedAuthUser() async {
    if (_isExpired(_authUserKey, _authUserTtl)) return null;
    final json = _prefs.getString(_authUserKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return AuthUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheAuthUser(AuthUser user) async {
    final json = jsonEncode(user.toJson());
    await _prefs.setString(_authUserKey, json);
    _setTimestamp(_authUserKey);
  }

  // ==================== Tozalash ====================

  Future<void> clearAll() async {
    await _prefs.remove(_regionsKey);
    await _prefs.remove(_categoriesKey);
    await _prefs.remove(_authUserKey);
    await _prefs.remove('$_timestampPrefix$_regionsKey');
    await _prefs.remove('$_timestampPrefix$_categoriesKey');
    await _prefs.remove('$_timestampPrefix$_authUserKey');
  }

  // ==================== Yordamchi ====================

  bool _isExpired(String key, Duration ttl) {
    final ts = _prefs.getInt('$_timestampPrefix$key');
    if (ts == null) return true;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cachedAt) > ttl;
  }

  void _setTimestamp(String key) {
    _prefs.setInt(
      '$_timestampPrefix$key',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
