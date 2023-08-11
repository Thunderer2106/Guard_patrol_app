import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompletedIncidents extends StatefulWidget {
  const CompletedIncidents({Key? key}) : super(key: key);

  @override
  State<CompletedIncidents> createState() => _CompletedIncidentsState();
}

class _CompletedIncidentsState extends State<CompletedIncidents> {
  final CollectionReference _getIncidents =
      FirebaseFirestore.instance.collection('completed');
  late Stream<QuerySnapshot> _streamIncidentsList;

  Future<void> _deleteRec(String id)async{
    await FirebaseFirestore.instance
        .collection("completed")
        .doc( id)
        .delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    _streamIncidentsList = _getIncidents.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: _streamIncidentsList,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Text("Error${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.active) {
          return Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Completed",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: snapshot.data!.docs.isEmpty?
                const Center(child: Text("No Completed Incidents",
                  style: TextStyle(
                    color: Colors.white,
                  ),

                )):ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(snapshot.data!.docs[index]['title']),
                        subtitle: Text(snapshot.data!.docs[index]['date']),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                        ),
                        trailing: IconButton(icon: const Icon(Icons.delete),
                          onPressed: ()async{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete"),
                                  content: const Text("Are you sure you want to Delete"),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text("Yes"),
                                      onPressed: () {
                                       _deleteRec(snapshot.data!.docs[index].id);
                                        Navigator.pop(context); // Close the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );


                          },
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      Text(snapshot.data!.docs[index]['title']),
                                  content: Column(
                                    children: [
                                      Container(
                                        alignment:
                                        Alignment.topLeft,
                                        child: Image.network(
                                            snapshot.data!
                                                .docs[index]
                                            ['image_url']),
                                      ),
                                      Text(snapshot.data!.docs[index]['desc']),
                                      Text("Reported by:${snapshot.data!
                                          .docs[index]['username']}"),
                                      Text("Reported on:${snapshot.data!
                                          .docs[index]['date']}"),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: (){
                                            Navigator.pop(context);

                                        },
                                        child: const Text("Ok")),
                                  ],
                                );
                              });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const Center(child:Text("Loading..."));
      },
    );
  }
}
