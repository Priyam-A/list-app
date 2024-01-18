import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_5/data/categories.dart';
import 'package:project_5/models/grocery_item.dart';
import 'package:project_5/screens/new_item_screen.dart';
import 'package:project_5/widgets/grocery_tile.dart';
import 'package:http/http.dart' as http;

class GroceryListScreen extends StatefulWidget {
  GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  //final void Function() onPressed;
  List<GroceryItem> groceryItems = [];
  var isLoading = true;
  var ifError = false;
  final pika = 500;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadItem();
  }

  void loadItem() async {
    try{
    final response = await http.get(Uri.https(
        'learn-a5129-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json'));
    if (response.body == 'null') {
      setState(() {
        isLoading = false;
      });
      return;
    }
    if (response.statusCode >= 400) {
      setState(() {
        isLoading = false;
        ifError = true;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    List<GroceryItem> groceryItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      groceryItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      this.groceryItems = groceryItems;
      isLoading = false;
    });
    
    } catch(error){
      setState(() {
        ifError=true;
      });
    }
  }

  void addItem() async {
    try{
    var newItem = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => NewItemScreen()));
    setState(() {
      groceryItems.add(newItem);
    });
    } catch(error){
      setState(() {
        ifError=true;
      });
    }
  }

  void removeItem(GroceryItem grocery) async {
    try{
    final index = groceryItems.indexOf(grocery);
    setState(() {
      groceryItems.remove(grocery);
    });
    final response = await http.delete(Uri.https(
        'learn-a5129-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${grocery.id}.json'));
    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong")));
      setState(() {
        groceryItems.insert(index, grocery);
      });
    }
    }catch(error){
      setState(() {
        ifError=true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget content = Center(
        child: Text(
      "Wow such empty...",
      style: TextStyle(fontSize: 25),
    ));
    if (ifError) {
      content = Center(child: Text("Something went wrong..."));
    } else if (isLoading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    } else if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemBuilder: (ctx, i) => Dismissible(
          child: GroceryTile(groceryItem: groceryItems[i]),
          key: ValueKey(groceryItems[i].id),
          onDismissed: (direction) {
            removeItem(groceryItems[i]);
          },
        ),
        itemCount: groceryItems.length,
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Your groceries",
            style: TextStyle(fontSize: 28),
          ),
          actions: [IconButton(onPressed: addItem, icon: Icon(Icons.add))],
        ),
        body: content);
  }
}
