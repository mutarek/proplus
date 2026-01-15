import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proplus/core/network/dio_client.dart';
import 'package:proplus/feature/home/models/product.dart';
import 'package:proplus/feature/home/repository/product_repository.dart';

/// Provider for ProductRepository instance
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductRepository(dioClient);
});

/// Provider for fetching products list with pagination
final productsProvider = FutureProvider.family<ProductListResponse, int>((ref,
    page) async {
  final repository = ref.watch(productRepositoryProvider);
  final skip = (page - 1) * 10;
  return repository.getProducts(skip: skip, limit: 10);
});

/// Provider for fetching a single product by ID
final productByIdProvider = FutureProvider.family<Product, int>((ref,
    productId) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(productId);
});

/// Provider for searching products
final searchProductsProvider = FutureProvider.autoDispose.family<
    ProductListResponse,
    String>((ref, query) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.searchProducts(query: query);
});

/// AsyncNotifier for product state management (Riverpod 3.x)
class ProductNotifier extends AsyncNotifier<ProductListResponse> {
  late ProductRepository repository;
  int _currentPage = 1;

  @override
  Future<ProductListResponse> build() async {
    repository = ref.watch(productRepositoryProvider);
    return repository.getProducts(skip: 0, limit: 10);
  }

  /// Fetch products with optional page parameter
  Future<void> fetchProducts({int page = 1}) async {
    _currentPage = page;
    final skip = (page - 1) * 10;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
          () => repository.getProducts(skip: skip, limit: 10),
    );
  }

  /// Load more products (infinite scroll pagination)
  Future<void> loadMoreProducts() async {
    _currentPage++;
    final skip = (_currentPage - 1) * 10;
    final newState = await AsyncValue.guard(
          () => repository.getProducts(skip: skip, limit: 10),
    );
    state = newState.whenData((newProducts) {
      return state.maybeWhen(
        data: (currentProducts) {
          return ProductListResponse(
            products: [...currentProducts.products, ...newProducts.products],
            // This will add products to existing list
            total: newProducts.total,
            skip: newProducts.skip,
            limit: newProducts.limit,
          );
        },
        orElse: () => newProducts,
      );
    });
  }

  /// Reset to initial state
  Future<void> reset() async {
    _currentPage = 1;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
          () => repository.getProducts(skip: 0, limit: 10),
    );
  }
}

/// AsyncNotifier provider for managing product list state
final productNotifierProvider = AsyncNotifierProvider<
    ProductNotifier,
    ProductListResponse>(() {
  return ProductNotifier();
});



