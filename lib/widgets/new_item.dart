import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
//import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey =
      GlobalKey<FormState>(); // use globalkeys when working with forms

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('flutter-prep-24426-default-rtdb.firebaseio.com',
          /* PATH NAME */ 'shopping-list.json');
      final response = await http.post(url,
          headers: {
            // http usually takes some time
            'Content-Type':
                'application/json', // how the data send will be formatted
          },
          body: json.encode({
            // content type
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
            // not passing id bcz firebase will generate a unique id
          }));

      //print(response.body);
      //print(response.statusCode);

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'], // to obtain id ( 'name' : 'dfdgdhdhdhjdj23')
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
    // validate() will reach out to all the FormFields and execute its validator function
    // validate() will return bool value . 1 if all validator function passed . 0 if atleast one validator function fails
    // save will execute the onSaved parameter
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          // for handling user input efficiently
          key: _formKey, // used for validation purpose
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  // value parameter is passed by flutter & function returns String as a value else returns null
                  // the value will be the same value which is entered in the TextFormField i.e as Name
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ), // instead of TextField() as we are using Form()
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '1', // initial value displayed
                      validator: (value) {
                        // value parameter is passed by flutter & function returns String as a value else returns null
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(
                            value!); // parse converts string to number
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories
                              .entries) // categories is a map and .entries converts map into iterable which contains map , keys value pairs into list
                            DropdownMenuItem(
                              value: category
                                  .value, // executed whenever the user selects the dropdownmenu
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        } // everytime the user selects different item & it will recieve automatically the item's value as input(i.e value parameter)
                        ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // horizontal is main alignment
                children: [
                  TextButton(
                    onPressed:
                        _isSending // if sending the request , making the button disable
                            ? null
                            : () {
                                _formKey.currentState!
                                    .reset(); // reset is a build-in widget
                              },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending
                        ? null
                        : _saveItem, // if sending request , making button disable
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
