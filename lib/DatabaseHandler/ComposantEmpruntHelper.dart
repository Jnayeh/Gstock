
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:gstock/DatabaseHandler/ComposantHelper.dart';
import 'package:gstock/Model/Composant.dart';
import 'package:gstock/Model/ComposantEmprunt.dart';
import 'package:sqflite/sqflite.dart' as sql ;
import 'package:path/path.dart';
import 'dart:io' as io;


class COMPOSANT_EMPRUNTHelper {
  static get table => 'composant_emprunts';
  static get id => 'id';
  static get qte => 'qte';
  static get idComposant => 'idComposant';
  static get idEmprunt => 'idEmprunt';
  static const String DB_Name = 'gstock.db';

  static Future<void> createTable(sql.Database database) async {

    await database.execute("""CREATE TABLE IF NOT EXISTS $table (
        $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        $qte INTEGER,
        $idComposant INTEGER,
        $idEmprunt INTEGER,
        FOREIGN KEY ($idComposant) REFERENCES composants (matricule) ON DELETE CASCADE
        FOREIGN KEY ($idEmprunt) REFERENCES emprunts (id) ON DELETE CASCADE
      )
      """);
  }

  static Future _onConfigure(sql.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // id: the id of a Categorie
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    return sql.openDatabase(
      path,
      version: 2,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
      onConfigure: _onConfigure
    );
  }

  // Read all emprunts
  static Future<List<Map<String, dynamic>>> getAll() async {

    final db = await COMPOSANT_EMPRUNTHelper.db();
    await createTable(db);
    return db.query(table, orderBy: id);

  }

  // Read all emprunts By ID
  static Future<List<Map<String, dynamic>>> getAllByID(int id) async {
    final db = await COMPOSANT_EMPRUNTHelper.db();
    /*db.execute("DROP TABLE $table;");*/
    await createTable(db);
    return db.query(table, where: "idEmprunt = ?", whereArgs: [id]);

  }

  // Read a single emprunt by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<Map<String, dynamic>?> getOne(int id) async {
    var db = await COMPOSANT_EMPRUNTHelper.db();
    var res = await  db.query(table, where: "id = ?", whereArgs: [id], limit: 1);
    if (res.isNotEmpty) {
      return res.first;
    }
  }

  // Create new emprunt
  static Future<int> create(ComposantEmprunt emprunt) async {
    final db = await COMPOSANT_EMPRUNTHelper.db();
    Composant? composant = await COMPOSANTHelper.getItem(emprunt.idComposant!) ;
    if(composant!= null){
      composant.qte= composant.qte! - emprunt.qte!;
    }
    final id = await db.insert(table, emprunt.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    COMPOSANTHelper.updateComposant(composant!.matricule!, composant);
    return id;
  }

  // Update an emprunt by id
  static Future<int> update(
      int id, ComposantEmprunt emprunt) async {
    final db = await COMPOSANT_EMPRUNTHelper.db();

    Map<String, dynamic>? emt = await COMPOSANT_EMPRUNTHelper.getOne(id);
    Composant? composant = await COMPOSANTHelper.getItem(emt!['idComposant']!) ;
    if(composant!= null && emt!= null ){
      int diff = emt['qte'] - emprunt.qte;
      composant.qte= (composant.qte! + diff) as int;
      COMPOSANTHelper.updateComposant(composant.matricule!, composant);
    }

    emprunt.id=id;
    final result = await db.update(table, emprunt.toMap(), where: "id = ?", whereArgs: [id]);

    return result;
  }

  // Delete
  static Future<void> delete(int id) async {
    final db = await COMPOSANT_EMPRUNTHelper.db();
    try {
      Map<String, dynamic>? emprunt = await COMPOSANT_EMPRUNTHelper.getOne(id);
      await db.delete(table, where: "id = ?", whereArgs: [id]);
      Composant? composant = await COMPOSANTHelper.getItem(emprunt!['idComposant']!) ;
      if(composant!= null && emprunt!= null ){
        composant.qte= (composant.qte! + emprunt[qte]!) as int;
        COMPOSANTHelper.updateComposant(composant.matricule!, composant);
      }
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}