import 'package:guard_app/screens/user/incidents/showincidents.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guard_app/widgets/user_image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final _form = GlobalKey<FormState>();
  final formatter = DateFormat.yMd();
  File? _selectedImage1;
  var _enteredtitle = '';
  var _entereddesc = '';
  var _username = '';
  //final String date = DateTime.now();
  //final  _entereddate = date.formattedDate;
  final _firebase = FirebaseAuth.instance;

  //String get formattedDate {
  //return formatter.format(date);
  DateTime date = DateTime.now();

  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  //}

  void _hello() async {
    _form.currentState!.save();
    if (_enteredtitle == '') {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Title empty',
          ),
        ),
      );
      return;
    } else if (_entereddesc == '') {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'description empty',
          ),
        ),
      );
      return;
    }
    else if (_selectedImage1 == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image empty',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sent Successfully',
          ),
        ),
      );
      _form.currentState?.reset();
    }
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('incident_report_images')
          .child('$date.jpg');
      await storageRef.putFile(_selectedImage1!);
      final imageUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('incidents').add({
        'title': _enteredtitle,
        'desc': _entereddesc,
        'image_url': imageUrl,
        'date': formattedDate,
        'username': userData.data()!['username'],
        'time': Timestamp.now(),
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB1DCDA),
      appBar: AppBar(
        backgroundColor: Colors.teal[300],
        elevation: 4,
        title: const Text('Complaints'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              width: 200,
            ),
            Card(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserImagePicker(
                          onPickImage: (pickedImage) {
                            _selectedImage1 = pickedImage;
                          },
                        ),

                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Title'),
                          onSaved: (value) {
                            _enteredtitle = value!;
                          },
                        ),
                        TextFormField(
                          decoration:
                          const InputDecoration(labelText: 'Description'),
                          onSaved: (value) {
                            _entereddesc = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _hello,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StateHome()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 197, 249, 244)),
              ),
              child: const Text('Click to see incidents reported'),
            ),
          ],
        ),
      ),
    );
  }
}
