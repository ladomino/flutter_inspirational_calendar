import 'package:flutter_inspirational_calendar/data/todo.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// An object that controls a list of [Todo].
class TodoList extends Notifier<List<Todo>> {
  //Initial state - state is a list of Todos.
  @override
  List<Todo> build() => [
        const Todo(id: 'todo-0', description: 'Smile today'),
        const Todo(id: 'todo-1', description: 'Go for a walk'),
      ];

  // Create a new list with the old state list and new Todo.
  void add(String description) {
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
      ),
    ];
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: !todo.completed,
            description: todo.description,
          )
        else
          todo,
    ];
  }

  void edit({required String id, required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: todo.completed,
            description: description,
          )
        else
          todo,
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}