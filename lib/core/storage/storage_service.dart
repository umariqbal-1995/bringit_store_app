import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final _box = GetStorage();

  static String? getToken() => _box.read(AppConstants.tokenKey);
  static void setToken(String token) => _box.write(AppConstants.tokenKey, token);
  static void clearToken() => _box.remove(AppConstants.tokenKey);

  static String? getStoreId() => _box.read(AppConstants.storeIdKey);
  static void setStoreId(String id) => _box.write(AppConstants.storeIdKey, id);

  static String? getStoreType() => _box.read(AppConstants.storeTypeKey);
  static void setStoreType(String type) => _box.write(AppConstants.storeTypeKey, type);

  static bool get isLoggedIn => getToken() != null;
  static bool get isRestaurant => getStoreType() == 'RESTAURANT';

  static void clearAll() => _box.erase();
}
