import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AddNewUser extends StatefulWidget {
  const AddNewUser({Key? key}) : super(key: key);

  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _isAuthenticating = false;
  var _isAdded = false;

  void _userSubmit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
      print(userCredentials.user!.uid);
      await FirebaseFirestore.instance.collection('users').doc(userCredentials.user!.uid).set(
          {'username':_enteredUsername,'email':_enteredEmail,'password':_enteredPassword});

      setState(() {

        _isAdded = true;
        _isAuthenticating = false;
        _firebase.signOut();
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isAuthenticating = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Failed Try again'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Add New User",),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username',),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.trim().length < 4) {
                    return 'Less than 4 characters';
                  }
                },
                onSaved: (value) {
                  _enteredUsername = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Invalid Email' ;
                  }

                  return null;
                },
                onSaved: (value) {
                  _enteredEmail = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null||value.trim().length<6) {
                    return 'Should be more than 6 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredPassword = value!;
                },
              ),

            ],
          ),
        ),
      ),
      actions: [
        if (_isAuthenticating) const CircularProgressIndicator(),
        if (_isAdded)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isAdded = false;
              });
              _form.currentState?.reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
            ),
            child: const Text(
              'Added!Click to add New',
            ),
          ),
        if (!_isAuthenticating && !_isAdded)
          ElevatedButton(
            onPressed: _userSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text(
              'Add New',
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
           child: const Text("Back"),
        )


      ],
    );
  }
}
