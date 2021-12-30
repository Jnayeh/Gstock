class Composant{
  int? matricule;
  String? nom;
  String? description;
  int? qte;
  int? idCategory;

  Composant(this.nom,this.description,this.qte,this.idCategory);

  Map<String,dynamic> toMap(){ // used when inserting data to the database
    return <String,dynamic>{
      "matricule" : matricule,
      "nom" : nom,
      "description" : description,
      "qte" : qte,
      "idCategory" : idCategory,
    };
  }

  Composant.fromMap(Map<String, dynamic> map) {
    matricule = (map['matricule']) as int;
    nom = map['nom'];
    description = map['description'];
    qte = map['qte'] as int ;
    idCategory = map['idCategory'] as int ;
  }
}