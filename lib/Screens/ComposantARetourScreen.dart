// main.dart
import 'package:flutter/material.dart';
import 'package:gstock/DatabaseHandler/CategoryHelper.dart';
import 'package:gstock/DatabaseHandler/ComposantEmpruntHelper.dart';
import 'package:gstock/DatabaseHandler/ComposantHelper.dart';
import 'package:gstock/DatabaseHandler/EmpruntHelper.dart';
import 'package:gstock/DatabaseHandler/MembreHelper.dart';

import 'drawer.dart';

class ComposantARetourScreen extends StatefulWidget {
  const ComposantARetourScreen({Key? key}) : super(key: key);

  @override
  _ComposantARetourScreenState createState() => _ComposantARetourScreenState();
}

class _ComposantARetourScreenState extends State<ComposantARetourScreen> {
  // All composants
  List<Map<String, dynamic>> _composants = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _membres = [];
  List<Map<String, dynamic>> _emprunts = [];
  List<Map<String, dynamic>> _emprunt_composants = [];
  bool _isLoading = true;

  late Map<String, dynamic> _existingComposant;
  late Map<String, dynamic> _existingEmpruntComposant;
  late Map<String, dynamic> _existingMembre;

  // fetch all categories from the database
  void _getCategories() async {
    await CATEGORYHelper.getAll().then((listMap) {
      _categories = listMap;
    });
  }

  // get all Emprunts from the database
  void _getEmprunts() async {
    final data = await EMPRUNTHelper.getAll();
    setState(() {
      _emprunts = data;
    });
  }

  // get all Emprunt_Composants from the database
  Future<void> _getEmpruntComposants() async {
    final data = await COMPOSANT_EMPRUNTHelper.getAll();
    setState(() {
      _emprunt_composants = data;
      _isLoading = false;
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

  // Returns membre  ID using the membreID in Emprunt
  int getMembreID(idEmprunt) {
    var membreID;
    _emprunts.forEach((element) {
      if (element['id'].toString() == idEmprunt.toString()) {
        membreID = element['idMembre'];
      }
    });

    return membreID;
  }

  // Gets composant using the ID
  Map<String, dynamic> getComposant(idComposant) {
    var cmp;
    _composants.forEach((element) {
      if (element['matricule'].toString() == idComposant.toString()) {
        cmp = element;
      }
    });
    return cmp;
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
    // Loading the lists when the app starts
    _getCategories();
    _getComposants();
    _getMembres();
    _getEmprunts();
    _getEmpruntComposants();
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      _existingEmpruntComposant =
          _emprunt_composants.firstWhere((element) => element['id'] == id);
      _existingComposant = _composants.firstWhere((element) =>
          element['matricule'] == _existingEmpruntComposant['idComposant']);
      _existingMembre = getMembre(getMembreID(_existingEmpruntComposant['idEmprunt']));
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
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      height: 350,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Composant détails: ",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                            Wrap(
                              spacing: 5,
                              children: [
                                Chip( label: Text("Nom Compsant: "+_existingComposant['nom'].toString()),),

                                Chip( label: Text("Description: "+_existingComposant['description']),),

                                Chip( label: Text("Category: "+getCategorie(_existingComposant['idCategory'])),),

                                Chip( label: Text("Quantity: "+_existingEmpruntComposant['qte'].toString()),),
                              ],
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            Text("Membre détails: ",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                            Wrap(
                              spacing: 5,
                              children: [
                                Chip( label: Text("Nom: "+_existingMembre['nom'].toString()),),

                                Chip( label: Text("Email: "+_existingMembre['email'].toString()),),

                                Chip( label: Text("Premier numéro: "+_existingMembre['telephone_1'].toString()),),

                                _existingMembre['telephone_2']!=null ? Chip( label: Text("Deuxième numéro:: "+_existingMembre['tel_2'].toString()),) : Text(""),


                              ],
                            ),
                          ],
                        )
                      ),
                    ));
          },
        );
      },
    ).whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text('Composants à retouner'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _emprunt_composants.length,
              itemBuilder: (context, index) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                color: Colors.grey[300],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                    title: Text(_emprunt_composants[index]['qte'].toString() +" " +
                        getCategorie(getComposant(_emprunt_composants[index]['idComposant'])['idCategory'])+
                        " " +
                        getComposant(_emprunt_composants[index]['idComposant'])['nom']),
                    subtitle: Text("A retouner par:  "+ getMembre(getMembreID(_emprunt_composants[index]['idEmprunt']))['nom']),
                    trailing: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.wysiwyg),
                            onPressed: () =>
                                _showForm(_emprunt_composants[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
    );
  }


}
