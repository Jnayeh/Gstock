// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:gstock/DatabaseHandler/CategoryHelper.dart';
import 'package:gstock/DatabaseHandler/ComposantHelper.dart';
import 'package:gstock/Model/Composant.dart';

import 'drawer.dart';

class ComposantScreen extends StatefulWidget {
  const ComposantScreen({Key? key}) : super(key: key);

  @override
  _ComposantScreenState createState() => _ComposantScreenState();
}

class _ComposantScreenState extends State<ComposantScreen> {
  // All composants
  List<Map<String, dynamic>> _composants = [];
  List<Map<String, dynamic>> _savedComposants = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategorie = "Select categorie";
  bool _isLoading = true;

  // get all data from the database
  void _refreshComposants() async {
    final data = await COMPOSANTHelper.getItems();
    setState(() {
      _composants = data;
      _savedComposants = data;
      _isLoading = false;
    });
  }

  void _search(String value) {
    List<Map<String, dynamic>> _searchResult=[];
    _composants=_savedComposants;
      if (value.length>0){
        _composants.forEach((composant) {
          if (composant['nom'].toString().toUpperCase().contains(value.toUpperCase())){
            _searchResult.add(composant);
          }
        });
        setState(() {
          _composants=_searchResult;
        });
      }

  }

  // fetch all categories from the database
  void _getCategories() async {
    await CATEGORYHelper.getAll().then((listMap) {
      _categories = listMap;
    });
  }

  // Error Dialog
  DialogError() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur!!"),
            content: Text(
                'Composantt must have a name, a description and a quantity and a category!'),
            elevation: 10,
          );
        });
  }

// Insert a new item to the database
  Future<void> _addItem() async {
    if (_nomController.text == '' ||
        _descriptionController.text == '' ||
        _quantityController.text == '' ||
        int.parse(_quantityController.text) == 0 ||
        _categoryController.text == '') {
      DialogError();
    } else {
      Composant cmp = Composant(
          _nomController.text,
          _descriptionController.text,
          int.parse(_quantityController.text),
          int.parse(_categoryController.text));
      await COMPOSANTHelper.createComposant(cmp);
      // Close the bottom sheet
      Navigator.of(context).pop();
    }

    _refreshComposants();
  }

  // Update an existing item
  Future<void> _updateItem(int id) async {
    if (_nomController.text == '' ||
        _descriptionController.text == '' ||
        _quantityController.text == '' ||
        _categoryController.text == '') {
      DialogError();
    } else {
      Composant cmp = Composant(
          _nomController.text,
          _descriptionController.text,
          int.parse(_quantityController.text),
          int.parse(_categoryController.text));
      await COMPOSANTHelper.updateComposant(id, cmp);
      // Close the bottom sheet
      Navigator.of(context).pop();
    }

    _refreshComposants();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await COMPOSANTHelper.deleteComposant(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a composant!'),
    ));
    _refreshComposants();
  }

  // Gets categorie's name using the ID
  selectCategorie(id) {
    _categories.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        _selectedCategorie = element['categorie'];
      }
    });
  }

  // Gets categorie's value using the ID
  String getCategorie(id) {
    var cat = '';
    _categories.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        cat = element['categorie'];
      }
    });
    return cat;
  }

  @override
  void initState() {
    super.initState();
    _initializeSearchBar();
    COMPOSANTHelper.db();
    _refreshComposants(); // Loading the list when the app starts
    _getCategories();
  }

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingComposant =
      _composants.firstWhere((element) => element['matricule'] == id);
      _nomController.text = existingComposant['nom'];
      _descriptionController.text = existingComposant['description'];
      _quantityController.text = existingComposant['qte'].toString();
      _categoryController.text = existingComposant['idCategory'].toString();

      selectCategorie(_categoryController.text);
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      builder: (BuildContext context) {
        return BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, setState) =>
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      height: 350,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _nomController,
                              decoration:
                              const InputDecoration(hintText: 'Nom'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              maxLines: null,
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                  hintText: 'Description'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                                controller: _quantityController,
                                decoration:
                                const InputDecoration(hintText: 'Quantité'),
                                keyboardType: TextInputType.number),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: DropdownButton(
                                hint: Text(_selectedCategorie),
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.blue),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blueAccent,
                                ),
                                onChanged: (value) {
                                  // Refresh UI
                                  setState(() {
                                    // Change Hint by getting the categorie's value
                                    selectCategorie(value);
                                    //Change the ID value
                                    _categoryController.text = value.toString();
                                  });
                                },
                                items: _categories.map((item) {
                                  // Maps the categories from database to Dropdown Items
                                  return DropdownMenuItem<String>(
                                      value: item['id'].toString(),
                                      child: Text(item['categorie']));
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            16.0),
                                      ))),
                              onPressed: () async {
                                // Save new composant
                                if (id == null) {
                                  await _addItem();
                                }

                                if (id != null) {
                                  await _updateItem(id);
                                }
                              },
                              child: Text(id == null ? 'Create New' : 'Update'),
                            )
                          ],
                        ),
                      ),
                    ));
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        // Clear the text fields
        _nomController.text = '';
        _descriptionController.text = '';
        _quantityController.text = '';
        _categoryController.text = '';
        _selectedCategorie = "Select categorie";
      });
    });
  }

  var searchBar;

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('Composants'),
        actions: [searchBar.getSearchAction(context)]
    );
  }

  _initializeSearchBar() {
    searchBar = SearchBar(
        inBar: false,
        setState: setState,
        onChanged: (value) {
          _search(value);
        },
        onClosed:() {
          _composants=_savedComposants;
        },
        onCleared: () {
          _composants=_savedComposants;
        },
        buildDefaultAppBar: buildAppBar
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: searchBar.build(context),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _composants.length,
        itemBuilder: (context, index) =>
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              color: Colors.grey[300],
              margin: const EdgeInsets.all(10),
              child: ListTile(
                  title: Text(_composants[index]['qte'].toString() +
                      " " +
                      getCategorie(_composants[index]['idCategory']) +
                      " " +
                      _composants[index]['nom']),
                  subtitle: Text("Aquisition: "+_composants[index]['createdAt']+"\n \nDescription: "+_composants[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _showForm(_composants[index]['matricule']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _deleteItem(_composants[index]['matricule']),
                        ),
                      ],
                    ),
                  )),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }


}