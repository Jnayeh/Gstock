// main.dart
import 'package:flutter/material.dart';
import 'package:gstock/DatabaseHandler/ComposantEmpruntHelper.dart';
import 'package:gstock/DatabaseHandler/ComposantHelper.dart';
import 'package:gstock/DatabaseHandler/EmpruntHelper.dart';
import 'package:gstock/DatabaseHandler/MembreHelper.dart';
import 'package:gstock/Model/ComposantEmprunt.dart';
import 'package:gstock/Model/Emprunt.dart';
import 'package:numberpicker/numberpicker.dart';
import 'drawer.dart';

class EmpruntScreen extends StatefulWidget {
  const EmpruntScreen({Key? key}) : super(key: key);

  @override
  _EmpruntScreenState createState() => _EmpruntScreenState();
}

class _EmpruntScreenState extends State<EmpruntScreen> {
  // All emprunts
  List<Map<String, dynamic>> _emprunts = [];
  List<Map<String, dynamic>> _emprunt_composants = [];
  List<Map<String, dynamic>> _membres = [];
  List<Map<String, dynamic>> _composants = [];
  String _selectedMembre = "Select membre";
  String _selectedComposant = "Select composant";
  bool _isLoading = true;
  bool _LoadingEmprunts = true;

  final TextEditingController _membreController = TextEditingController();
  int _quantityValue = 0;
  final TextEditingController _empruntController = TextEditingController();
  final TextEditingController _composantController = TextEditingController();

  int _value = 0;

  // get all Emprunts from the database
  void _refreshEmprunts() async {
    final data = await EMPRUNTHelper.getAll();
    setState(() {
      _emprunts = data;
      _isLoading = false;
    });
  }

  // get all Emprunt_Composants from the database
  Future<void> _refreshEmprunt_Composants(int id) async {
    final data = await COMPOSANT_EMPRUNTHelper.getAllByID(id);
    setState(() {
      _emprunt_composants = data;
      _LoadingEmprunts = false;
    });
  }

  // fetch all Membres from the database
  void _getMembres() async {
    await MEMBREHelper.getItems().then((listMap) {
      _membres = listMap;
    });
  }

  // fetch all Composants from the database
  void _getComposants() async {
    await COMPOSANTHelper.getItems().then((listMap) {
      _composants = listMap;
    });
  }

  // Gets membre's name using the ID
  getMembreForDropDown(id) {
    _membres.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        _selectedMembre = element['nom'];
      }
    });
  }

  getComposantForDropDown(id) {
    _composants.forEach((element) {
      if (element['matricule'].toString() == id.toString()) {
        _selectedComposant = element['nom'];
      }
    });
  }

  // Gets membre using the ID
  String getMembreName(id) {
    var membre;
    _membres.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        membre = element['nom'];
      }
    });

    return membre;
  }

  // Gets membre using the ID
  Map<String, dynamic> getMembre(id) {
    var membre;
    _membres.forEach((element) {
      if (element['id'].toString() == id.toString()) {
        membre = element;
      }
    });

    return membre;
  }

  // Gets composant using the ID
  Map<String, dynamic> getComposant(id) {
    var cmp;
    _composants.forEach((element) {
      if (element['matricule'].toString() == id.toString()) {
        cmp = element;
      }
    });
    return cmp;
  }

// Insert a new emprunt to the database
  Future<int?> _addEmprunt() async {
    if (_membreController.text == '') {
      EmpruntDialogError();
    } else {
      Emprunt emp = Emprunt(int.parse(_membreController.text));
      var id = await EMPRUNTHelper.create(emp);
      _refreshEmprunts();
      return id;
    }
  }

  // Update an existing emprunt
  Future<void> _updateEmprunt(int id) async {
    Emprunt emp = Emprunt(int.parse(_membreController.text));
    await EMPRUNTHelper.update(id, emp);
    _refreshEmprunts();
  }

  // Delete a emprunt
  void _deleteEmprunt(int id) async {
    await EMPRUNTHelper.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a composant!'),
    ));
    _refreshEmprunts();
  }

// Insert a new emprunt composant to the database
  Future<int?> _addEmpruntItem() async {
    if (_composantController.text == '' || _quantityValue == 0) {
      ItemDialogError();
    } else {
      ComposantEmprunt emp = ComposantEmprunt(
          int.parse(_composantController.text),
          int.parse(_empruntController.text),
          _quantityValue);
      var id = await COMPOSANT_EMPRUNTHelper.create(emp);
      // Close the bottom sheet
      Navigator.of(context).pop();
      return id;
    }
  }

  // Update an existing emprunt composant
  Future<void> _updateEmpruntItem(int id) async {
    if (_composantController.text == '' || _quantityValue == 0) {
      ItemDialogError();
    } else {
      ComposantEmprunt emp = ComposantEmprunt(
          int.parse(_composantController.text),
          int.parse(_empruntController.text),
          _quantityValue);
      await COMPOSANT_EMPRUNTHelper.update(id, emp);
      // Close the bottom sheet
      Navigator.of(context).pop();
    }
  }

  // Delete an emprunt composant
  void _deleteEmpruntItem(int id, StateSetter parentState) async {
    await COMPOSANT_EMPRUNTHelper.delete(id);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Deleted!!"),
            content: Text('Successfully deleted the emprunt composant!'),
            elevation: 10,
          );
        });
    /*ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      elevation: 10,
      content: Text('Successfully deleted the emprunt composant!'),
    ));*/
    await _refreshEmprunt_Composants(int.parse(_empruntController.text));
    var list = _emprunt_composants;
    parentState(() {
      _emprunt_composants = list;
    });
  }

  // Error Dialog
  ItemDialogError() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur!!"),
            content: Text(
                'You must select a composant and a quantity higher than 0 !'),
            elevation: 10,
          );
        });
  }

  // Error Dialog
  EmpruntDialogError() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur!!"),
            content: Text('Emprunt must have a membre!'),
            elevation: 10,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _getMembres();
    _refreshEmprunts(); // Loading the list when the app starts
    _getComposants();
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingEmprunt =
          _emprunts.firstWhere((element) => element['id'] == id);
      _membreController.text = existingEmprunt['idMembre'].toString();
      //Initialize the emprunt ID to be used by all actions
      _empruntController.text = id.toString();
      getMembreForDropDown(_membreController.text);
      await _refreshEmprunt_Composants(id);
    }

    showModalBottomSheet(
      context: context,
      elevation: 1,
      builder: (BuildContext context) {
        return BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, ParentState) => Container(
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      height: 700,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Center(
                              child: DropdownButton(
                                hint: Text(_selectedMembre),
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 1,
                                style: const TextStyle(color: Colors.blue),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blueAccent,
                                ),
                                onChanged: (value) {
                                  // Refresh UI
                                  ParentState(() {
                                    // Change Hint by getting the categorie's value
                                    getMembreForDropDown(value);
                                    //Change the ID value
                                    _membreController.text = value.toString();
                                  });
                                },
                                items: _membres.map((item) {
                                  // Maps the membres from database to Dropdown Items
                                  return DropdownMenuItem<String>(
                                      value: item['id'].toString(),
                                      child: Text(item['nom']));
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ))),
                              onPressed: () async {
                                // Save new emprunt
                                if (id == null) {
                                  var E_ID = await _addEmprunt();

                                  E_ID != null
                                      ? await _refreshEmprunt_Composants(E_ID)
                                      : id;

                                  ParentState(() {
                                    id = E_ID;
                                    id != null
                                        ? _empruntController.text =
                                            id.toString()
                                        : id;
                                  });
                                }

                                if (id != null) {
                                  await _updateEmprunt(id!);
                                }
                              },
                              child: Text(id == null ? 'Create New' : 'Update'),
                            ),
                            // List of composants as well the ability to add more
                            id != null
                                ? Column(children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          )),
                                          alignment: Alignment.center),
                                      onPressed: () =>
                                          _addComposantForm(null, ParentState),
                                      child: Text('Add composant'),
                                    ),
                                    _LoadingEmprunts
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                _emprunt_composants.length,
                                            itemBuilder: (context, index) =>
                                                Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              color: Colors.grey[300],
                                              margin: const EdgeInsets.all(10),
                                              child: ListTile(
                                                  title: Text("Composant: " +
                                                      getComposant(
                                                              _emprunt_composants[
                                                                      index][
                                                                  'idComposant'])[
                                                          'nom']),
                                                  subtitle: Text("Quantité: " +
                                                      _emprunt_composants[index]
                                                              ['qte']
                                                          .toString()),
                                                  trailing: SizedBox(
                                                    width: 100,
                                                    child: Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.edit),
                                                          onPressed: () =>
                                                              _addComposantForm(
                                                                  _emprunt_composants[
                                                                          index]
                                                                      ['id'],
                                                                  ParentState),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.delete),
                                                          onPressed: () =>
                                                              _deleteEmpruntItem(
                                                                  _emprunt_composants[
                                                                          index]
                                                                      ['id'],
                                                                  ParentState),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          )
                                  ])
                                : Text(''),
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

        _membreController.text = '';
        _selectedMembre = "Select membre";
      });
    });
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _addComposantForm(int? id, StateSetter parentState) async {
    _getComposants();
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingComposantEmprunt =
          _emprunt_composants.firstWhere((element) => element['id'] == id);
      _composantController.text =
          existingComposantEmprunt['idComposant'].toString();
      _quantityValue = existingComposantEmprunt['qte'];
      _value = _quantityValue;
      getComposantForDropDown(_composantController.text);
    }

    showModalBottomSheet(
      context: context,
      elevation: 2,
      builder: (BuildContext context) {
        return BottomSheet(
          onClosing: () {},
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, setState) => Container(
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      height: 330,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Center(
                              child: DropdownButton(
                                hint: Text(_selectedComposant),
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 1,
                                style: const TextStyle(color: Colors.blue),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blueAccent,
                                ),
                                onChanged: (value) {
                                  // Refresh UI
                                  setState(() {
                                    // Change Hint by getting the categorie's value
                                    getComposantForDropDown(value);
                                    // Return Value to 0
                                    _quantityValue = 0;
                                    //Change the ID value
                                    _composantController.text =
                                        value.toString();
                                  });
                                },
                                items: _composants.map((item) {
                                  // Maps the composants from database to Dropdown Items
                                  return DropdownMenuItem<String>(
                                      value: item['matricule'].toString(),
                                      child: Text(item['nom']));
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: NumberPicker(
                                value: _quantityValue,
                                minValue: 0,
                                maxValue: _composantController.text == ''
                                    ? 0
                                    : getComposant(
                                            _composantController.text)['qte'] +
                                        _value,
                                onChanged: (value) =>
                                    setState(() => _quantityValue = value),
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
                                borderRadius: BorderRadius.circular(16.0),
                              ))),
                              onPressed: () async {
                                // Save new emprunt
                                if (id == null) {
                                  await _addEmpruntItem();
                                }

                                if (id != null) {
                                  await _updateEmpruntItem(id);
                                }
                              },
                              child: Text(id == null ? 'Create New' : 'Update'),
                            ),
                          ],
                        ),
                      ),
                    ));
          },
        );
      },
    ).whenComplete(() async {
      setState(() {
        // Clear the text fields
        _composantController.text = '';
        _quantityValue = 0;
        _value = 0;
        _selectedComposant = "Select composant";
      });
      await _refreshEmprunt_Composants(int.parse(_empruntController.text));

      var list = _emprunt_composants;
      //Refresh Parent Widget from child widget
      parentState(() {
        _emprunt_composants = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text('Emprunts'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _emprunts.length,
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                color: Colors.grey[300],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                    title: Text(_emprunts[index]['id'].toString()+" - Membre: " +
                        getMembreName(_emprunts[index]['idMembre']).toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_emprunts[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteEmprunt(_emprunts[index]['id']),
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

  // Maps the categories from database to Dropdown Items
/*  DropdownMenuItem<String> getDropDownWidget(Map<String, dynamic> map) {
    return DropdownMenuItem<String>(
      value: map['id'].toString(),
      child: Text(map['categorie']),
    );
  }*/

}
