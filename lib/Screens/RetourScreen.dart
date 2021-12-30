
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gstock/DatabaseHandler/ComposantHelper.dart';
import 'package:gstock/DatabaseHandler/MembreHelper.dart';
import 'package:gstock/DatabaseHandler/RetourHelper.dart';
import 'package:gstock/Model/Retour.dart';

import 'drawer.dart';

class RetourScrean extends StatefulWidget {
  const RetourScrean({Key? key}) : super(key: key);

  @override
  _RetourScreanState createState() => _RetourScreanState();
}

class _RetourScreanState extends State<RetourScrean> {

  // All retours
  List<Map<String, dynamic>> _retours = [];
  // All composants
  List<Map<String, dynamic>> _composants = [];

  String _selectedComposant = "composant";
  String _selectedMembre = "membre";
  final List<String>etats=<String>["intact", "endommagé", "gravement endommagé"];
  List<Map<String, dynamic>> _membres = [];

  bool _isLoading = true;
  String _etat="intact";

  // get all data from the database
  void _refreshRetours() async {
    final data = await RetourHelper.getItems();
    setState(() {
      _retours = data;
      _isLoading = false;
    });
  }

  // fetch all composants from the database
  void _getComposants() async {
    await COMPOSANTHelper.getItems().then((listMap) {
      _composants = listMap;
    });
  }
  void _getMembres() async {
    await MEMBREHelper.getItems().then((listMap) {
      _membres = listMap;
    });
  }



  @override
  void initState() {
    super.initState();
    RetourHelper.db();
    _refreshRetours(); // Loading the list when the app starts
    _getComposants();
    _getMembres();
  }

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _etatController = TextEditingController();
  final TextEditingController _composantController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _membreController = TextEditingController();
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingComposant =
      _retours.firstWhere((element) => element['id'] == id);
      _dateController.text = existingComposant['dateRetour'];
      _etatController.text = existingComposant['etat'];
      _quantityController.text = existingComposant['qte'].toString();
      _membreController.text = existingComposant['idMembre'].toString();
      _composantController.text = existingComposant['idComposant'].toString();


      getComposantNom(_composantController.text);
      getMembreNom(_membreController.text);
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      builder: (BuildContext context) {
        return BottomSheet(
          onClosing: () {

          },
          builder: (BuildContext context) {

            return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
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

                        DropdownButton(
                          value: _etat,
                          onChanged: (value) {
                            setState(() {
                              _etat = value.toString();
                              _etatController.text = value.toString();
                            });
                          },
                          items: etats.map(
                                (item) {
                              return DropdownMenuItem(
                                value: item,
                                child: new Text(item),
                              );
                            },
                          ).toList(),

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
                        Center(
                          child: DropdownButton(

                            hint: Text(_selectedComposant),
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
                                getComposantNom(value);
                                //Change the ID value
                                _composantController.text = value.toString();
                              });
                            },
                            items: _composants.map((item) {
                              return DropdownMenuItem<String>(
                                  value: item['matricule'].toString(),

                                  child: Text(item['nom']));

                            }).toList(),
                          ),

                        ),
                        Center(
                          child: DropdownButton(
                            hint: Text(_selectedMembre),
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
                                getComposantNom(value);
                                //Change the ID value
                                _membreController.text = value.toString();
                              });
                            },
                            items: _membres.map((item) {
                              return DropdownMenuItem<String>(
                                  value: item['id'].toString(),
                                  child: Text(item['nom']));
                            }).toList(),
                          ),

                        ),

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
                            // Save new composant
                            if (id == null) {
                              await _addItem();
                            }

                            if (id != null) {
                              await _updateItem(id);
                            }


                            // Close the bottom sheet
                            Navigator.of(context).pop();
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
        _dateController.text = '';
        _etatController.text = '';
        _quantityController.text = '';
        _membreController.text = '';
        _composantController.text = '';
        _selectedComposant = "Composant";
        _selectedMembre = "membre";
      });
    });
  }

// Insert a new item to the database
  Future<void> _addItem() async {
    Retour rtr = Retour(

        _etatController.text,
        int.parse(_quantityController.text),
        int.parse(_membreController.text),
        int.parse(_composantController.text));

    await RetourHelper.createRetour(rtr);

    _refreshRetours();
  }

  // Update an existing item
  Future<void> _updateItem(int id) async {
    Retour cmp = Retour(

        _etatController.text,
        int.parse(_quantityController.text),
        int.parse(_membreController.text),
        int.parse(_composantController.text));

    await RetourHelper.updateRetour(id, cmp);
    _refreshRetours();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await RetourHelper.deleteRetour(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a composant!'),
    ));
    _refreshRetours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text('Retours'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _retours.length,
        itemBuilder: (context, index) => Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          color: Colors.grey[300],
          margin: const EdgeInsets.all(10),
          child: ListTile(
              title: Text("Quantite : "+_retours[index]['qte'].toString()+
                  "   date de Retour : " + _retours[index]['dateRetour']),
              subtitle: Text("Etat : " +_retours[index]['etat']),

              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showForm(_retours[index]['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteItem(_retours[index]['id']),
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

  /* // Maps the categories from database to Dropdown Items
  DropdownMenuItem<String> getDropDownWidget(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
      value: map['matricule'].toString(),
      child: Text(map['nom']),
    );
  }
*/
  // Gets categorie's value using the ID
  getComposantNom(id) {
    print(_composants);
    _composants.forEach((element) {
      if (element['matricule'].toString() == id.toString()) {
        _selectedComposant = element['nom'];
      }
    });
  }

  getMembreNom(id) {
    print(_membres);
    _membres.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        _selectedMembre = element['nom'];
      }
    });
  }














}