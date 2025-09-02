class PerformanceConfig {
  // ListView optimization
  static const double cacheExtent = 1000.0;
  static const int maxMessageCache = 500; // Limit cached messages
  
  // Contact loading optimization  
  static const int contactBatchSize = 50;
  static const Duration debounceDelay = Duration(milliseconds: 300);
  
  // Image optimization
  static const double maxImageWidth = 800.0;
  static const double maxImageHeight = 600.0;
  static const int imageQuality = 85;
  
  // Animation optimization
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 200);
  
  // Memory optimization
  static const int maxCachedContacts = 1000;
  static const Duration cacheExpiry = Duration(hours: 1);
}

class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();
  
  // Clear unused data periodically
  void clearUnusedCache() {
    // Implement cache clearing logic here
  }
  
  // Optimize images
  void optimizeImages() {
    // Implement image optimization logic here
  }
}
