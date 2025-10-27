// Custom Cache Manager with optimized settings
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const key = 'propertyImagesCache';

  static final CustomCacheManager _instance = CustomCacheManager._();
  factory CustomCacheManager() {
    return _instance;
  }

  CustomCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30), // Keep images for 30 days
          maxNrOfCacheObjects: 200, // Store up to 200 images
          repo: JsonCacheInfoRepository(databaseName: key),
        ));
}
