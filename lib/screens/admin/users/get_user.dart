import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class GetUsers extends StatefulWidget {
  const GetUsers({Key? key}) : super(key: key);

  @override
  State<GetUsers> createState() => _GetUsersState();
}

class _GetUsersState extends State<GetUsers> {
  var _deleted=false;
  final CollectionReference _getUsers =
      FirebaseFirestore.instance.collection('users');
  late Stream<QuerySnapshot> _streamUsersList;

  void _updateUser(String uid, String name) async {
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(uid);
    documentReference.update({'username': name});
  }

  void _showDialog(String uid, String name) {
    TextEditingController getName = TextEditingController(text: name);
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Edit Username"),
            content: TextFormField(
              controller: getName,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    _updateUser(uid, getName.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Submit")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }


  void _deleteAuth(String name,String pass)async{
    try{final userCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: name, password:pass );
    User? user=userCredentials.user;
    await user?.delete();
    FirebaseAuth.instance.signOut();
    setState(() {
      _deleted=true;

    });}catch(e){
      print("no user");
    }


  }
  void _deleteDoc(String name)async{
    await FirebaseFirestore.instance.collection('users').doc(name).delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    _streamUsersList = _getUsers.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _streamUsersList,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Text("Error${snapshot.error}");
          }
          if (snapshot.connectionState == ConnectionState.active) {
            return snapshot.data!.docs.isEmpty
                ? const Center(
                    child: Text("No active Users.",style: TextStyle(color: Colors.white),),
                  )
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(snapshot.data!.docs[index]['username']),
                          subtitle: Text(snapshot.data!.docs[index]['email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final DocumentReference documentReference =
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(snapshot.data!.docs[index].id);
                                  final DocumentSnapshot doc =
                                      await documentReference.get();
                                  if (doc.exists) {
                                    String name = doc.get('username');
                                    _showDialog(
                                        snapshot.data!.docs[index].id, name);
                                  }
                                  else{
                                    print("error");
                                  }
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(onPressed: (){
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text("Are you sure?"),
                                  action:SnackBarAction(
                                    label: "Yes",
                                    onPressed: (){
                                      _deleteAuth(snapshot.data!.docs[index]['email'], snapshot.data!.docs[index]['password']);
                                      _deleteDoc(snapshot.data!.docs[index].id);
                                    },
                                  ) ,)
                                );

                              }, icon:
                              const Icon(Icons.delete),)
                            ],
                          ),
                        ),
                      );
                    });
          } else {
            return const Center(child: Text("Loading..."));
          }
        });
  }
}
