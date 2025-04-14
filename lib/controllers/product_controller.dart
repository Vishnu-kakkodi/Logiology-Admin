import 'package:get/get.dart';
import 'package:logiology_admin/models/product_model.dart';
import 'package:logiology_admin/services/api_service.dart';

class ProductController extends GetxController {
  var allProducts = <Product>[].obs;
  var products = <Product>[].obs;
  var isLoading = true.obs;

  var currentPage = 1.obs;
  var itemsPerPage = 8.obs;
  var totalPages = 1.obs;

  List<Product> get paginatedProducts {
    final startIndex = (currentPage.value - 1) * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value;

    if (startIndex >= products.length) return [];
    if (endIndex > products.length) return products.sublist(startIndex);

    return products.sublist(startIndex, endIndex);
  }

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  void fetchProducts() async {
    isLoading.value = true;
    try {
      final fetched = await ApiService.getProducts();
      allProducts.assignAll(fetched);
      products.assignAll(fetched);
      _updateTotalPages();
    } catch (e) {
      Get.snackbar("Fetching Failed", "Error fetching the products");
    }
    isLoading.value = false;
  }

  void applyPriceFilter({required double minPrice, required double maxPrice}) {
    var filtered =
        allProducts.where((product) {
          return product.price >= minPrice && product.price <= maxPrice;
        }).toList();

    products.assignAll(filtered);
    _updateTotalPages();
    currentPage.value = 1;
  }

  void applyFilters({
    required String category,
    required String tag,
    required double minPrice,
    required double maxPrice,
  }) {
    var filtered =
        allProducts.where((product) {
          final matchCategory =
              category == 'All' || product.category == category;
          final matchTag = tag == 'All' || product.tags.contains(tag);
          final matchPrice =
              product.price >= minPrice && product.price <= maxPrice;

          return matchCategory && matchTag && matchPrice;
        }).toList();

    products.assignAll(filtered);
    _updateTotalPages();
    currentPage.value = 1;
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      products.assignAll(allProducts);
    } else {
      final filtered =
          allProducts
              .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
      products.assignAll(filtered);
    }
    _updateTotalPages();
    currentPage.value = 1;
  }

  void _updateTotalPages() {
    totalPages.value = (products.length / itemsPerPage.value).ceil();
    if (totalPages.value == 0) totalPages.value = 1;

    if (currentPage.value > totalPages.value && totalPages.value > 0) {
      currentPage.value = totalPages.value;
    }
  }

  void changePage(int page) {
    if (page > 0 && page <= totalPages.value) {
      currentPage.value = page;
      update();
    }
  }
}
