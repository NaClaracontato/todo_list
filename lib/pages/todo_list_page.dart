import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  //controlador da caixa de texto
  final TextEditingController todoControler = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  //lista para tarefas
  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffb7a1f9), Color(0xff54328b)],
              stops: [0.25, 0.75],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              height: size.height / 1.3,
              width: 370,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Lista de Tarefas',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          //caixa de texto
                          child: TextField(
                            controller: todoControler,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Adicione uma tarefa',
                              hintText: 'Ex: Estudar Flutter',
                              errorText: errorText,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(167, 99, 221, 1),
                                  width: 2,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: Color.fromRGBO(167, 99, 221, 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            String text = todoControler.text;

                            if (text.trim().isEmpty) {
                              setState(() {
                                errorText = 'O titulo não pode ser vazio';
                              });
                              return;
                            }

                            setState(
                              () {
                                Todo newTodo = Todo(
                                  title: text,
                                  dateTime: DateTime.now(),
                                );
                                todos.add(newTodo);
                                errorText = null;
                              },
                            );
                            //limpar campo de texto
                            todoControler.clear();
                            //salvando texto
                            todoRepository.saveTodoList(todos);
                          },
                          //botão de adicionar itens
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(167, 99, 221, 1),
                            padding: EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: size.height / (kIsWeb ? 2.4 : 2.3),
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: todos.length,
                        itemBuilder: (context, index) => TodoListItem(
                          todo: todos[index],
                          onDelete: () => onDelete(todos[index]),
                        ),
                        shrinkWrap: true,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        //menssagem de quantidade de tarefas pendentes
                        Expanded(
                          child: Text(
                            'Você possui ${todos.length} tarefas pendentes',
                          ),
                        ),
                        //botão de deletar tudo
                        ElevatedButton(
                          onPressed: showDeleteTodosConfirmationDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(167, 99, 221, 1),
                            padding: EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Limpar tudo',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //deletar item da lista
  void onDelete(Todo todo) {
    //guardando na memoria o item da lista
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(
      () {
        todos.remove(todo);
      },
    );
    todoRepository.saveTodoList(todos);

    //menssagem de desfazer a exclusão do item
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: TextStyle(
            color: const Color.fromARGB(255, 119, 119, 119),
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          backgroundColor: Color.fromRGBO(167, 99, 221, 1),
          onPressed: () {
            setState(
              () {
                todos.insert(deletedTodoPos!, deletedTodo!);
              },
            );
            todoRepository.saveTodoList(todos);
          },
        ),
        //duração da mensagem
        duration: const Duration(seconds: 5),
      ),
    );
  }

  //Dialogo para confirmar exclusão de todos os itens
  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Color.fromRGBO(167, 99, 221, 1),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            child: Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

  //deleta a lista por completo
  void deleteAllTodos() {
    setState(
      () {
        todos.clear();
      },
    );
    todoRepository.saveTodoList(todos);
  }
}
