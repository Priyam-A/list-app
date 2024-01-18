import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_5/data/categories.dart';
import 'package:project_5/models/category.dart';
import 'package:project_5/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItemScreen extends StatefulWidget {
  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final formKey = GlobalKey<FormState>();
  var isSending = false;
  
  void onSave() async{
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        isSending = true;
      });
      final url = Uri.https(
          'learn-a5129-default-rtdb.asia-southeast1.firebasedatabase.app',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {'name': name, 'quantity': amt, 'category': cat.title},
        ),
      );

      if (!context.mounted){
        return;
      }
      String id = json.decode(response.body)['name'];
      Navigator.of(context).pop(GroceryItem(id: id, name: name, quantity: amt, category: cat));
    }
  }

  String name = '';
  int amt = 0;
  Category cat = categories[Categories.fruit]!;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Add new item")),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              maxLength: 30,
              decoration: InputDecoration(label: Text('Name')),
              validator: (value) =>
                  (value == null || value.isEmpty || value.trim().length < 2)
                      ? 'Invalid Name'
                      : null,
              onSaved: (newValue) {
                name = newValue!;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    //maxLength: 4,
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(label: Text('Amt')),
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Invalid Qty';
                      } else {
                        int? val = int.tryParse(value.trim());
                        if (val == null || val < 1 || val > 50) {
                          return 'Enter a value between 1 and 50';
                        } else {
                          return null;
                        }
                      }
                    },
                    onSaved: (newValue) {
                      amt = int.parse(newValue!);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DropdownButtonFormField(
                    value: cat,
                    items: categories.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Row(
                              children: [
                                ColoredBox(
                                  color: e.value.color,
                                  child: SizedBox.square(
                                    dimension: 20,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(e.value.title),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        cat = val!;
                      });
                    },
                    onSaved: (newValue) {
                      cat = newValue!;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isSending? null:onSave,
                  child: Text('Add'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isSending? null:() {
                    formKey.currentState!.reset();
                  },
                  child: Text('Clear'),

                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
