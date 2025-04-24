import 'package:flutter/material.dart';
import '../home/home.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("My Library"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.folder, color: Colors.blue),
            title: Text("My Documents"),
            subtitle: Text("View your saved study materials"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/documents',
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add, color: Colors.green),
            title: Text("Add New Study Material"),
            subtitle: Text("Find and save new study materials"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/search',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: buildNavBar(context, "/home"),
    );
  }
}
