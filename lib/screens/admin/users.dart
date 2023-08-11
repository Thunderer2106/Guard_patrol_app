import 'package:guard_app/screens/admin/users/add_user.dart';
import 'package:guard_app/screens/admin/users/get_user.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Users"),
        backgroundColor: Colors.teal[300],
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFB1DCDA),
      body: const GetUsers(),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return const AddNewUser();
                });
          },
          backgroundColor: Colors.teal[300],
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
