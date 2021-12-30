import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gstock/DatabaseHandler/ComposantEmpruntHelper.dart';
import 'package:gstock/DatabaseHandler/ComposantHelper.dart';
import 'package:gstock/DatabaseHandler/MembreHelper.dart';
import 'package:gstock/DatabaseHandler/RetourHelper.dart';
import 'package:gstock/Model/Retour.dart';
import 'package:numberpicker/numberpicker.dart';

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

  List<Map<String, dynamic>> _emprunts = [];

  String _selectedComposant = "composant";
  String _selectedMembre = "membre";
  final List<String> etats = <String>[
    "intact",
    "endommagé",
    "gravement endommagé"
  ];
  List<Map<String, dynamic>> _membres = [];

  bool _isLoading = true;
  String? _etat;
  int _value = 0;

  int _quantityValue = 0;
  int _quantityToReturn = 0;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _etatController = TextEditingController();
  final TextEditingController _composantController = TextEditingController();
  final TextEditingController _membreController = TextEditingController();

  // get all retours from the database
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

  void _getEmprunts() async {
    await COMPOSANT_EMPRUNTHelper.getAllEmprunt().then((listMap) {
      setState(() {
        _emprunts = listMap;
      });
    });
  }

  void _getQte(int idComposant, int idMembre) async {
    setState(() {
      _quantityToReturn = 0;
      _emprunts.forEach((element) {
        if (element['idComposant'] == idComposant &&
            element['idMembre'] == idMembre) {
          print(element);
          _quantityToReturn = _quantityToReturn + element['qte'] as int;
        }
      });
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
                'You must select a membre, a composant, the etat and the quantity!'),
            elevation: 10,
          );
        });
  }

// Insert a new Retour to the database
  Future<void> _addItem() async {
    if (_etatController.text == '' ||
        _quantityValue == 0 ||
        _membreController.text == '' ||
        _composantController.text == '') {
      DialogError();
    } else {
      Retour rtr = Retour(
          _dateController.text,
          _etatController.text,
          _quantityValue,
          int.parse(_membreController.text),
          int.parse(_composantController.text));

      await RetourHelper.createRetour(rtr);
      // Close the bottom sheet
      Navigator.of(context).pop();
    }

    _refreshRetours();
  }

  // Update an existing Retour
  Future<void> _updateItem(int id) async {
    if (_etatController.text == '' ||
        _quantityValue == 0 ||
        _membreController.text == '' ||
        _composantController.text == '') {
      DialogError();
    } else {
      Retour rtr = Retour(
          _dateController.text,
          _etatController.text,
          _quantityValue,
          int.parse(_membreController.text),
          int.parse(_composantController.text));

      await RetourHelper.updateRetour(id, rtr);
      // Close the bottom sheet
      Navigator.of(context).pop();
    }

    _refreshRetours();
  }

  // Delete a Retour
  void _deleteItem(int id) async {
    await RetourHelper.deleteRetour(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted the retour!'),
    ));
    _refreshRetours();
  }

  // Gets categorie's value using the ID
  getComposantNom(id) {
    _composants.forEach((element) {
      if (element['matricule'].toString() == id.toString()) {
        _selectedComposant = element['nom'];
      }
    });
  }

  getMembreNom(id) {
    _membres.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        _selectedMembre = element['nom'];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    RetourHelper.db();
    _getComposants();
    _getMembres();
    _getEmprunts();
    _refreshRetours(); // Loading the list when the app starts
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingRetour =
          _retours.firstWhere((element) => element['id'] == id);
      _dateController.text = existingRetour['dateRetour'];
      _etatController.text = existingRetour['etat'];
      _quantityValue = existingRetour['qte'];
      _value = _quantityValue;
      _membreController.text = existingRetour['idMembre'].toString();
      _composantController.text = existingRetour['idComposant'].toString();

      _getQte(existingRetour['idComposant'], existingRetour['idMembre']);
      getComposantNom(_composantController.text);
      getMembreNom(_membreController.text);
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      builder: (BuildContext context) {
        return BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                      width: double.infinity,
                      height: 360,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Center(
                              child: DropdownButton(
                                hint: Text("Etat"),
                                value: _etat,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.blue),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blueAccent,
                                ),
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
                                    _quantityValue = 0;
                                    // Change Hint by getting the categorie's value
                                    getComposantNom(value);

                                    //Change the ID value
                                    _composantController.text =
                                        value.toString();
                                    if (_composantController.text != '' &&
                                        _membreController.text != '') {
                                      _getQte(
                                          int.parse(_composantController.text),
                                          int.parse(_membreController.text));
                                    }
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
                                    _quantityValue = 0;
                                    // Change Hint by getting the categorie's value
                                    getMembreNom(value);

                                    //Change the ID value
                                    _membreController.text = value.toString();
                                    if (_composantController.text != '' &&
                                        _membreController.text != '') {
                                      _getQte(
                                          int.parse(_composantController.text),
                                          int.parse(_membreController.text));
                                    }
                                  });
                                },
                                items: _membres.map((item) {
                                  return DropdownMenuItem<String>(
                                      value: item['id'].toString(),
                                      child: Text(item['nom']));
                                }).toList(),
                              ),
                            ),
                            Center(
                              child: NumberPicker(
                                value: _quantityValue,
                                minValue: 0,
                                maxValue: _composantController.text == '' ||
                                        _membreController.text == ''
                                    ? 0
                                    : _quantityToReturn + _value,
                                onChanged: (value) =>
                                    setState(() => _quantityValue = value),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
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
        _etat = null;
        _dateController.text = '';
        _etatController.text = '';
        _quantityValue = 0;
        _value = 0;
        _membreController.text = '';
        _composantController.text = '';
        _selectedComposant = "Composant";
        _selectedMembre = "membre";
      });
    });
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
                    title: Text("Quantite : " +
                        _retours[index]['qte'].toString() +
                        "\nDate de Retour : " +
                        _retours[index]['dateRetour'].toString()),
                    subtitle: Text("Etat : " + _retours[index]['etat']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_retours[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteItem(_retours[index]['id']),
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
