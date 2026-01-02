import 'package:flutter/material.dart';
import 'package:supergithr/views/colors.dart';

class Todo {
  String title;
  bool isDone;
  Todo({required this.title, this.isDone = false});
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Todo> todos = [];
  final TextEditingController _controller = TextEditingController();
  bool _markAllDone = false; // Add to your _TodoAppState

  void _addTodo() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        todos.add(Todo(title: _controller.text.trim()));
        _controller.clear();
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
  }

  void _deleteTodoWithConfirmation(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Delete Task"),
            content: const Text("Are you sure you want to delete this task?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  setState(() => todos.removeAt(index));
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("ToDo List"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "Total: ${todos.length}",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Section
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Enter your task",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: primaryColor),
                      onPressed: _addTodo,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            todos.length > 1
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                      value: _markAllDone,
                      onChanged: (value) {
                        setState(() {
                          _markAllDone = value!;
                          for (var task in todos) {
                            task.isDone = _markAllDone;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Mark all as done",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                : Container(),
            const SizedBox(height: 10),
            // Task List
            Expanded(
              child:
                  todos.isEmpty
                      ? Center(
                        child: Text(
                          "No tasks yet!",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      )
                      : ListView.separated(
                        itemCount: todos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final todo = todos[index];
                          return Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _toggleTodo(index),
                                    child: Icon(
                                      todo.isDone
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color:
                                          todo.isDone
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        decoration:
                                            todo.isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                        color:
                                            todo.isDone
                                                ? Colors.grey
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed:
                                        () =>
                                            _deleteTodoWithConfirmation(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
