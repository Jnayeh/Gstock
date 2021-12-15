// main.dart
import 'package:flutter/material.dart';
import 'package:projet/DatabaseHandler/ComposantHelper.dart';
import 'package:projet/Model/Composant.dart';

import 'drawer.dart';

class ComposantScreen extends StatefulWidget {
  const ComposantScreen({Key? key}) : super(key: key);

  @override
  _ComposantScreenState createState() => _ComposantScreenState();
}

class _ComposantScreenState extends State<ComposantScreen> {
  // All journals
  List<Map<String, dynamic>> _composants = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshComposants() async {
    final data = await COMPOSANTHelper.getItems();
    setState(() {
      _composants = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    COMPOSANTHelper.db();
    _refreshComposants(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _composants.firstWhere((element) => element['matricule'] == id);
      _titleController.text = existingJournal['nom'];
      _descriptionController.text = existingJournal['description'];
      _quantityController.text = existingJournal['qte'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(hintText: 'Nom'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(hintText: 'Quantité'),
                        keyboardType: TextInputType.number),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ))),
                      onPressed: () async {
                        // Save new journal
                        if (id == null) {
                          await _addItem();
                        }

                        if (id != null) {
                          await _updateItem(id);
                        }

                        // Clear the text fields
                        _titleController.text = '';
                        _descriptionController.text = '';
                        _quantityController.text = '';

                        // Close the bottom sheet
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

// Insert a new item to the database
  Future<void> _addItem() async {
    Composant cmp = Composant(_titleController.text,
        _descriptionController.text, int.parse(_quantityController.text));
    await COMPOSANTHelper.createComposant(cmp);
    _refreshComposants();
  }

  // Update an existing item
  Future<void> _updateItem(int id) async {
    Composant cmp = Composant(_titleController.text,
        _descriptionController.text, int.parse(_quantityController.text));
    await COMPOSANTHelper.updateComposant(id, cmp);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text('Composants'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _composants.length,
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                color: Colors.grey[300],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                    title: Text(_composants[index]['qte'].toString() +
                        " " +
                        _composants[index]['nom']),
                    subtitle: Text(_composants[index]['description']),
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
