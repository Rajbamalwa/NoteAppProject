import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/utils.dart';

class AddData extends StatefulWidget {
  final Map? todo;
  const AddData({
    super.key,
    this.todo,
  });

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    detailController.dispose();
    super.dispose();
  }

  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      detailController.text = description;
    }
  }

  final titleKey = GlobalKey<FormState>();

  final detailKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey.shade200,
        title: Text(isEdit ? 'Edit Data' : 'Add Todo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 5),
            child: Form(
              key: titleKey,
              child: TextFormField(
                controller: titleController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      fontSize: 20,
                    ),
                    label: const Text('Add title'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Type Title';
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 5),
            child: Form(
              key: detailKey,
              child: TextFormField(
                controller: detailController,
                maxLines: 5,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      fontSize: 20,
                    ),
                    label: const Text('Add Detail'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Type Detail';
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
            child: ElevatedButton(
                child: SizedBox(
                    height: 50,
                    child:
                        Center(child: Text(isEdit ? 'Edit Note' : 'Add Note'))),
                onPressed: () {
                  if (isEdit == true) {
                    updateData().whenComplete(() {
                      titleController.clear();
                      detailController.clear();
                      Utils.flushBarError('Updated', context);
                    }).onError((error, stackTrace) {
                      Utils.flushBarError('Some Error Occur', context);
                    });
                  } else {
                    if (titleKey.currentState!.validate() ||
                        detailKey.currentState!.validate()) {
                      submitData().whenComplete(() {
                        titleController.clear();
                        detailController.clear();
                        Utils.flushBarError('Posted', context);
                      }).onError((error, stackTrace) {
                        Utils.flushBarError(error.toString(), context);
                      });
                    } else {
                      Utils.flushBarError(
                          'Look like you are missing something?', context);
                    }
                  }
                }),
          ),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      return;
    }
    final id = todo['_id'];
    // final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final description = detailController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {}
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final detail = detailController.text;
    final body = {
      "title": title,
      "description": detail,
      "is_completed": false,
    };
    const url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);

    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    print(response);
    if (response.statusCode == 201) {
      print('posted');
    } else {
      print(response.statusCode);
    }
  }
}
