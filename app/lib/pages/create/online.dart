import 'package:flutter/material.dart';
import 'package:linwood_city/models/server.dart';
import 'package:linwood_city/pages/create/server.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CreateOnlinePage extends StatelessWidget {
  final List<Server> _servers = [Server(name: "Test1", password: "abc", address: "example.com")];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose a server")),
      body: Align(
          alignment: Alignment.topCenter,
          child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(children: [
                ListTile(
                  title: Text("Europe server"),
                  subtitle: Text("The official europe server"),
                ),
                ListTile(
                  title: Text("Linwood cloud server"),
                  subtitle: Text("Play games and save your stats in the linwood database"),
                ),
                Divider(thickness: 1.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _servers.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(_servers[index].name!), subtitle: Text(_servers[index].address!)),
                )
              ]))),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Add server"),
        icon: Icon(PhosphorIcons.plusLight),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateServerPage()));
        },
      ),
    );
  }
}
