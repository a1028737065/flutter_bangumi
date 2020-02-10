import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar.builder(
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Text(index.toString()),
        );
      },
      trailing: IconButton(icon: Icon(Icons.search), onPressed: (){}),
      drawer: Drawer(
        child: Container(),
      ),
      onChanged: (String value) {},
      onTap: () {},
      decoration: InputDecoration.collapsed(
        hintText: "Search...",
      ),
    );
  }
}
