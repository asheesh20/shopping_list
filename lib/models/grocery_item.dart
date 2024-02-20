import 'package:shopping_list/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id, // since named arguments are optional , therefore using required
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final Category category;
}
