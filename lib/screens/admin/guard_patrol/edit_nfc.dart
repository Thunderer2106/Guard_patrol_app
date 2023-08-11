import 'package:guard_app/screens/admin/guard_patrol/add_nfc.dart';
import 'package:guard_app/screens/admin/guard_patrol/modify_nfc.dart';
import 'package:guard_app/screens/admin/guard_patrol/write_to_nfc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditNfc extends StatefulWidget {
  const EditNfc({Key? key}) : super(key: key);

  @override
  State<EditNfc> createState() => _EditNfcState();
}

class _EditNfcState extends State<EditNfc> {
  WriteToNfcState my=WriteToNfcState();

  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('nfcTag');
  late Stream<QuerySnapshot> _streamNfcTags;

  var isWritten=false;

  @override
  void initState() {
    // TODO: implement initState
    _streamNfcTags = collectionReference.snapshots();

    super.initState();
  }



  void editNfc(String name,String code,String index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ModifyNfc(name: name,code:code,index: index, changeNfc: changeNfc,isWritten:false);
        });
  }

  void changeNfc(String name, String code, String ind) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('nfcTag').doc(ind);
    documentReference.update({'tagCode': code, 'tagName': name});
  }

  void delete(String ind) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('nfcTag').doc(ind);
    documentReference.delete();
  }

  void addNfc(String name, String code) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('nfcTag');
    collectionReference.add({'tagCode': code, 'tagName': name,'status':false});
    setState(() {
      my.done=false;
    });

  }

  void addNfcAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddNfc(addNfc: addNfc);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit NFC"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/guardPatrol');
          },
        ),
      ),
      backgroundColor: const Color(0xFFB1DCDA),
      body: StreamBuilder(
          stream: _streamNfcTags,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("Error${snapshot.error}");
            }
            if (snapshot.connectionState != ConnectionState.active) {
              return const Center(
                child: Text("Loading..."),
              );
            }
            return snapshot.data!.docs.isEmpty
                ? const Center(
                    child: Text(
                      "No Tags Set.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(snapshot.data!.docs[index]['tagName']),
                        subtitle: Text(snapshot.data!.docs[index]['tagCode']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  editNfc(snapshot.data!.docs[index]['tagName'],snapshot.data!.docs[index]['tagCode'],snapshot.data!.docs[index].id);
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {
                                  delete(snapshot.data!.docs[index].id);
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      );
                    },
                  );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: addNfcAlert,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
