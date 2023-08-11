import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatrolList extends StatefulWidget {
  const PatrolList({Key? key}) : super(key: key);

  @override
  State<PatrolList> createState() => _PatrolListState();
}

class _PatrolListState extends State<PatrolList> {
  final CollectionReference _getPatrol =
      FirebaseFirestore.instance.collection('guardPatrol');
  late Stream<QuerySnapshot> _streamGetPatrol;

  @override
  void initState() {
    // TODO: implement initState
    _streamGetPatrol = _getPatrol.snapshots();
    super.initState();
  }

  void _resetDoc(String tagName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('nfcTag')
        .where('tagName', isEqualTo: tagName)
        .get();
    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      FirebaseFirestore.instance.collection('nfcTag').doc(documentSnapshot.id).update({
        'status': false,
      });
    }
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('guardPatrol')
        .where('room', isEqualTo: tagName)
        .get();
    if (querySnapshot1.size > 0) {
      DocumentSnapshot documentSnapshot1 = querySnapshot1.docs.first;

      FirebaseFirestore.instance.collection('guardPatrol').doc(documentSnapshot1.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _streamGetPatrol,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return Text("error${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.active) {
          return snapshot.data!.docs.isEmpty
              ? const Center(
                  child: Text(
                    "No content to display.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(

                        title: Text(snapshot.data!.docs[index]['room']
                            .toString()
                            .toUpperCase()),
                        subtitle: Text(snapshot.data!.docs[index]['date']),
                        trailing: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title:  Text("${snapshot.data!.docs[index]['room']}"),
                                      content:
                                           Text("This will mark the ${snapshot.data!.docs[index]['room']}as unscanned"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              _resetDoc(snapshot
                                                  .data!.docs[index]['room']);
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("Ok")),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("No")),

                                      ],
                                    );
                                  });
                            }),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Patrol Info"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Checkpoint: ${snapshot.data!.docs[index]['room']}"),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "Date: ${snapshot.data!.docs[index]['date']}"),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "Time: ${snapshot.data!.docs[index]['time']}"),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "Done by: ${snapshot.data!.docs[index]['username']}"),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK"))
                                  ],
                                );
                              });
                        },
                      ),
                    );
                  },
                );
        } else {
          return const Center(
            child: Text("Loading..."),
          );
        }
      },
    );
  }
}
