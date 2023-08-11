import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListIncidents extends StatefulWidget {
  const ListIncidents({Key? key}) : super(key: key);

  @override
  State<ListIncidents> createState() => _ListIncidentsState();
}

class _ListIncidentsState extends State<ListIncidents> {
  final CollectionReference _getIncidents =
  FirebaseFirestore.instance.collection('incidents');
  late Stream<QuerySnapshot> _streamIncidentsList;

  @override
  void initState() {
    _streamIncidentsList = _getIncidents.snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> docId = [];
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
                "Incidents",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: snapshot.data!.docs.isEmpty
                    ? const Center(
                    child: Text(
                      "No pending Incidents.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ))
                    : ListView.builder(
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
                              title: Text(
                                  snapshot.data!.docs[index]['title']),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      snapshot.data!.docs[index]['date']),
                                  const Text("Tap to view in detail")
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(snapshot
                                            .data!.docs[index]['title']),
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
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(snapshot.data!
                                                .docs[index]['desc']),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                                'Reported by:${snapshot.data!.docs[index]['username']}'),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                'Reported on:${snapshot.data!.docs[index]['date']}'),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop();
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
        return const Center(child: Text("Loading..."));
      },
    );
  }
}
