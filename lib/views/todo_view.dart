import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/add.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Todo> _todos = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
              ),
              minLines: 5,
              maxLines: 8,
            ),
            ElevatedButton(
              onPressed: _currentIndex == -1 ? _addTodo : _updateTodo,
              child: Text(_currentIndex == -1 ? "Add Todo" : "Update Todo"),
            ),
            SizedBox(height: 20),
            _todos.isEmpty
                ? Center(child: Text("No todos"))
                : ListView.builder(
                   // shrinkWrap: true,
                   // physics: NeverScrollableScrollPhysics(), // Disable scrolling for ListView
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_todos[index].title),
                        subtitle: Text(_todos[index].description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _currentIndex = index;
                                  _titleController.text = _todos[index].title;
                                  _descriptionController.text =
                                      _todos[index].description;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteTodo(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _addTodo() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both title and description are required.")),
      );
      return;
    }
    final todo = Todo(
      title: _titleController.text,
      description: _descriptionController.text,
    );
    setState(() {
      _todos.add(todo);
      _saveTodos();
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  void _updateTodo() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both title and description are required.")),
      );
      return;
    }
    final todo = Todo(
      title: _titleController.text,
      description: _descriptionController.text,
    );
    setState(() {
      _todos[_currentIndex] = todo;
      _saveTodos();
      _titleController.clear();
      _descriptionController.clear();
      _currentIndex = -1;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
      _saveTodos();
    });
  }

  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = prefs.getStringList('todos');
    if (todos != null) {
      setState(() {
        _todos = todos
            .map((todo) => Todo.fromJson(jsonDecode(todo))) // Decode JSON
            .toList();
      });
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = _todos.map((todo) => jsonEncode(todo.toJson())).toList(); // Encode JSON
    prefs.setStringList('todos', todos);
  }
}
