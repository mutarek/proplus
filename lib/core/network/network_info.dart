/// Simple network information helper
/// Provides useful methods to handle network-related errors
class NetworkInfo {
  /// Get human readable connection status message
  Future<String> get connectionStatusMessage async {
    return 'Please check your internet connection and try again';
  }

  /// Check if device has internet connection
  /// Note: This is a basic implementation. For production, use connectivity_plus package
  Future<bool> get isConnected async {
    // In a real app, implement proper connectivity check
    // For now, return true and let the API call fail with proper error
    return true;
  }
}

