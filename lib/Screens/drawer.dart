import 'package:flutter/material.dart';
import 'package:gstock/Screens/CategoryScreen.dart';
import 'package:gstock/Screens/ComposantARetourScreen.dart';
import 'package:gstock/Screens/EmpruntScreen.dart';
import 'package:gstock/Screens/LoginForm.dart';
import 'package:gstock/Screens/MembreScreen.dart';

import 'ComposantScreen.dart';
import 'HomeForm.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text(
              "Home",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.home,
              color: Colors.blueAccent,
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HomeForm()));
            },
          ),
          Divider(
            height: 5,
            color: Colors.grey,
          ),
          ListTile(
            title: Text(
              "Membres",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.assignment_ind ,
              color: Colors.blueAccent,
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MembreScreen()));
            },
          ),
          Divider(
            height: 5,
            color: Colors.grey,
          ),
          ListTile(
            title: Text(
              "Categories",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.category,
              color: Colors.blueAccent,
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CategorieScreen()));
            },
          ),
          Divider(
            height: 5,
            color: Colors.grey,
          ),
          ListTile(
            title: Text(
              "Composants",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.view_list,
              color: Colors.blueAccent,
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ComposantScreen()));
            },
          ),
          Divider(
            height: 5,
            color: Colors.grey,
          ),
          ListTile(
            title: Text(
              "Emprunts",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.wysiwyg,
              color: Colors.blueAccent,
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => EmpruntScreen()));
            },
          ),
          Divider(
            height: 5,
            color: Colors.grey,
          ),
          ListTile(
            title: Text(
              "Composants à retour",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.web_outlined,
              color: Colors.blueAccent,
            ),
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ComposantARetourScreen()));
            },
          ),
          Divider(
            height: 5,
            color: Colors.grey,
          ),
          ListTile(
            title: Text(
              "Deconnexion",
              style: TextStyle(fontSize: 15),
            ),
            leading: Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginForm()),
                  (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
