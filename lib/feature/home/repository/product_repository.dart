import 'package:proplus/core/network/dio_client.dart';
import 'package:proplus/feature/home/models/product.dart';

class ProductRepository {
  final DioClient dioClient;

  ProductRepository(this.dioClient);

  /// Fetch all products with pagination
  Future<ProductListResponse> getProducts({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await dioClient.get(
        '/products',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );
      return ProductListResponse.fromJson(response.data ?? {});
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single product by ID
  Future<Product> getProductById(int id) async {
    try {
      final response = await dioClient.get(
        '/products/$id',
      );
      return Product.fromJson(response.data ?? {});
    } catch (e) {
      rethrow;
    }
  }

  /// Search products by keyword
  Future<ProductListResponse> searchProducts({
    required String query,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await dioClient.get(
        '/products/search',
        queryParameters: {
          'q': query,
          'skip': skip,
          'limit': limit,
        },
      );
      return ProductListResponse.fromJson(response.data ?? {});
    } catch (e) {
      rethrow;
    }
  }
}

