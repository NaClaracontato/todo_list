import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/todo.dart';

const todoListkey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

//decodificando a lista
  Future<List<Todo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListkey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJsom(e)).toList();
  }

//codificando a lista de tarefas em json
  void saveTodoList(List<Todo> todos) {
    final jsonString = json.encode(todos);
    sharedPreferences.setString('todo_list', jsonString);
  }
}
