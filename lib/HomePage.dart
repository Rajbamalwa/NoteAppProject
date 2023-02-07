import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled/AddData.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/utils.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade700,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade700,
        elevation: 0,
        title: const Text(
          'Note App',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchList,
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.blueGrey.shade100,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade900,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            item['description'],
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'edit') {
                                navigateToEditPage(item);
                              } else if (value == 'delete') {
                                deleteTask(id);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text('Edit'),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Text('Delete'),
                                  value: 'delete',
                                )
                              ];
                            },
                          ),
                        ),
                      ),
                    );
                  }),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        backgroundColor: Colors.blueGrey.shade900,
        tooltip: 'Add Data',
        label: Text('Add Data'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddData(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchList();
  }

  void navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => AddData());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchList();
  }

  Future<void> deleteTask(String id) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      Utils.flushBarError('Task Deleted', context);
    } else {
      Utils.flushBarError('Sorry task was not delete', context);
    }
  }

  Future<void> fetchList() async {
    const url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {
      Utils.flushBarError('Some Error Occur!', context);
    }
    setState(() {
      isLoading = false;
    });
  }
}
