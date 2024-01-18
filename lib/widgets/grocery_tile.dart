import 'package:flutter/material.dart';
import 'package:project_5/models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  GroceryTile({super.key, required this.groceryItem});
  final GroceryItem groceryItem;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: ColoredBox(
        color: groceryItem.category.color,
        child: SizedBox.square(
          dimension: 20,
        ),
      ),
      title: Text(groceryItem.name, style: TextStyle(fontSize: 20),),
      trailing: Text(groceryItem.quantity.toString(),style: TextStyle(fontSize: 20),),
    );
  }
}
