import 'package:guard_app/screens/admin/incident_report/completed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingIncidents extends StatefulWidget {
  const PendingIncidents({Key? key}) : super(key: key);

  @override
  State<PendingIncidents> createState() => _PendingIncidentsState();
}

class _PendingIncidentsState extends State<PendingIncidents> {
  final CollectionReference _getIncidents =
  FirebaseFirestore.instance.collection('incidents');
  late Stream<QuerySnapshot> _streamIncidentsList;

  @override
  void initState() {
    // TODO: implement initState
    _streamIncidentsList = _getIncidents.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String>docId=[];
    return StreamBuilder<QuerySnapshot>(
      stream: _streamIncidentsList,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Text("Error${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.active) {

          return Column(
            children: [
              const SizedBox(height: 10,),
              const Text("Pending",

                style: TextStyle(

                  color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600

                ),


              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: snapshot.data!.docs.isEmpty?
                const Center(child: Text("No pending Incidents",
                  style: TextStyle(
                    color: Colors.white,
                  ),

                )):ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    docId.add(snapshot.data!.docs[index].id);
                    print(docId[index]);
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          Card(
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.red),
                              title: Text(snapshot.data!.docs[index]['title']),
                              subtitle:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(snapshot.data!.docs[index]['date']),
                                  const Text("Tap to view in detail")
                                ],
                              ) ,
                              trailing: GestureDetector(
                                onTap: ()  {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: const Text("Are you sure to mark this as Completed"),
                                    duration: const Duration(seconds: 10),
                                    action: SnackBarAction(
                                      label: "YES",
                                      onPressed: () async {
                                        final DocumentSnapshot sourceDoc = await FirebaseFirestore.instance
                                            .collection('incidents')
                                            .doc( snapshot.data!.docs[index].id)
                                            .get();
                                        Map<String, dynamic> documentData = sourceDoc.data() as Map<String, dynamic>;
                                        await FirebaseFirestore.instance
                                            .collection('completed')
                                            .doc( snapshot.data!.docs[index].id)
                                            .set(documentData);
                                        await FirebaseFirestore.instance
                                            .collection("incidents")
                                            .doc( snapshot.data!.docs[index].id)
                                            .delete();
                                      },
                                    ),
                                  ));

                                },
                                child: const Icon(Icons.done),
                              ),
                              onTap: (){
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
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Ok")),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ),
                        ],
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
