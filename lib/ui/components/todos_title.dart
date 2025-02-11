import 'package:flutter/material.dart';

class ToDoTitle extends StatelessWidget {
  const ToDoTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 50,
        fontWeight: FontWeight.w800,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}