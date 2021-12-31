import 'package:gstock/Model/Composant.dart';
import 'package:gstock/Model/Retour.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'dart:io' as io;

import 'ComposantHelper.dart';

class RetourHelper {
  static get table => 'retours';

  static get id => 'id';

  static get dateRetour => 'dateRetour';

  static get etat => 'etat';

  static get qte => 'qte';

  static get idMembre => 'idMembre';

  static get idComposant => 'idComposant';
  static const String DB_Name = 'gstock.db';

  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $table (
        $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        $etat TEXT,
        $qte INTEGER,
        $idMembre INTEGER,
        $idComposant INTEGER,
        $dateRetour DATE DEFAULT (datetime('now','localtime')),
       
        FOREIGN KEY ($idMembre)  REFERENCES membres (id) ON DELETE NO ACTION ON UPDATE NO ACTION
        FOREIGN KEY ($idComposant)  REFERENCES composants (matricule) ON DELETE NO ACTION ON UPDATE NO ACTION
      )
      """);
  }

  static Future _onConfigure(sql.Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

// id: the id of a Composant
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_Name);
    return sql.openDatabase(path, version: 2,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    }, onConfigure: _onConfigure);
  }

  // Read all Composants (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await RetourHelper.db();
    await createTable(db);
    return db.query(table, orderBy:  id+' DESC');
  }

  // Read a single Composant by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<Map<String, dynamic>?> getItem(int id) async {
    var db = await RetourHelper.db();
    var res = await db.query(table, where: "id = ?", whereArgs: [id], limit: 1);
    if (res.isNotEmpty) {
      return res.first;
    }
  }

  // Create new Composant (journal)
  static Future<int> createRetour(Retour retour) async {
    final db = await RetourHelper.db();
    retour.dateRetour = DateTime.now().toString();

    retour.dateRetour = retour.dateRetour!.substring(0, 16);
    Composant? composant = await COMPOSANTHelper.getItem(retour.idComposant!);
    if (composant != null) {
      composant.qte = composant.qte! + retour.qte!;
    }
    final id = await db.insert(table, retour.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    COMPOSANTHelper.updateComposant(composant!.matricule!, composant);

    return id;
  }

  // Update a Composant by id
  static Future<int> updateRetour(int id, Retour retour) async {
    final db = await RetourHelper.db();
    //Change quantity in Composant Table
    Map<String, dynamic>? ret = await RetourHelper.getItem(id);
    Composant? composant = await COMPOSANTHelper.getItem(ret!['idComposant']!);
    if (composant != null && ret != null) {
      int diff = ret['qte'] - retour.qte;
      composant.qte = (composant.qte! - diff) as int;
    }

    retour.id = id;
    final result = await db
        .update(table, retour.toMap(), where: "id = ?", whereArgs: [id]);
    //If update successful then update composant
    COMPOSANTHelper.updateComposant(composant!.matricule!, composant);
    return result;
  }

  // Delete
  static Future<void> deleteRetour(int id) async {
    final db = await RetourHelper.db();
    try {
      Map<String, dynamic>? rtr = await RetourHelper.getItem(id);

      await db.delete(table, where: "id = ?", whereArgs: [id]);
      Composant? composant =
          await COMPOSANTHelper.getItem(rtr!['idComposant']!);
      if (composant != null && rtr != null) {
        composant.qte = (composant.qte! - rtr[qte]!) as int;
        //If deleated successfully then updated composant
        COMPOSANTHelper.updateComposant(composant.matricule!, composant);
      }
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
