import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logiology_admin/controllers/product_controller.dart';

void showFilterSheet(BuildContext context) {
  final ProductController controller = Get.find();

  String selectedCategory = 'All';
  String selectedTag = 'All';
  double minPrice = 0;
  double maxPrice = double.infinity;
  RxBool isFirstRangeSelected = true.obs;

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Filter Products",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              items:
                  ['All', 'smartphones', 'laptops', 'fragrances', 'groceries']
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) {
                selectedCategory = val!;
              },
              decoration: InputDecoration(labelText: "Category"),
            ),

            SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedTag,
              items:
                  ['All', 'new', 'trending', 'best-seller']
                      .map(
                        (tag) => DropdownMenuItem(value: tag, child: Text(tag)),
                      )
                      .toList(),
              onChanged: (val) {
                selectedTag = val!;
              },
              decoration: InputDecoration(labelText: "Tag"),
            ),

            SizedBox(height: 16),

            Text(
              "Price Range:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      minPrice = 0;
                      maxPrice = 100;
                      isFirstRangeSelected.value = true;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFirstRangeSelected.value
                              ? Colors.indigo[600]
                              : Colors.grey[300],
                      foregroundColor:
                          isFirstRangeSelected.value
                              ? Colors.white
                              : Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("0 - 100"),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      minPrice = 100;
                      maxPrice = double.infinity;
                      isFirstRangeSelected.value = false;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !isFirstRangeSelected.value
                              ? Colors.indigo[600]
                              : Colors.grey[300],
                      foregroundColor:
                          !isFirstRangeSelected.value
                              ? Colors.white
                              : Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("100+"),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.applyFilters(
                  category: selectedCategory,
                  tag: selectedTag,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[800],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text("Apply Filters"),
            ),
          ],
        ),
      );
    },
  );
}
