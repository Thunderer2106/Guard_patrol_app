import 'package:guard_app/screens/user/guard_patrol/scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HomePatrol extends StatefulWidget {
  const HomePatrol({Key? key}) : super(key: key);

  @override
  State<HomePatrol> createState() => _HomePatrolState();
}

class _HomePatrolState extends State<HomePatrol> {
  final CollectionReference _getIncidents =
      FirebaseFirestore.instance.collection('nfcTag');
  late Stream<QuerySnapshot> _streamIncidentsList;

  Map<String, bool> rooms = {'key':false};



  void setRoom(String s){
    setState(() {
      rooms[s]=true;
    });
  }


  @override
  void initState() {
    _streamIncidentsList = _getIncidents.snapshots();
    super.initState();
  }

  // Future<void> openNfcSettings() async {
  //   // ignore: deprecated_member_use
  //   if (await canLaunch('app-settings:')) {
  //     // ignore: deprecated_member_use
  //     await launch('app-settings:');
  //   } else {
  //     throw 'Could not open NFC settings.';
  //   }
  // }
  //
  // void showNfcDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Turn On NFC'),
  //         content:
  //             Text('NFC is currently turned off. Do you want to turn it on?'),
  //         actions: [
  //           TextButton(
  //             child: Text('No'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Yes'),
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               await openNfcSettings();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }



  @override
  Widget build(BuildContext context) {
    List<String> docId = [];
    return Scaffold(
      backgroundColor: const Color(0xFFB2DEDB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Scan Tags',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                  "NFC Tags",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      docId.add(snapshot.data!.docs[index].id);
                      return Center(
                        child: Column(
                          children: [
                            Card(
                              child: ListTile(
                                leading: (snapshot.data!.docs[index]['status'])?const CircleAvatar(backgroundColor: Colors.green,):
                                const CircleAvatar(backgroundColor: Colors.red),
                                  title: Text(
                                      snapshot.data!.docs[index]['tagName']),
                                  subtitle:  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if(snapshot.data!.docs[index]['status']!=true)
                                        const Text("Tap to Scan"),
                                      if(snapshot.data!.docs[index]['status']==true)
                                      const Text("Scanned!"),
                                    ],
                                  ),
                                  onTap: () {
                                    if(snapshot.data!.docs[index]['status']!=true) {
                                      showDialog(context: context, builder:(BuildContext context){return NFCTest(setRoom,snapshot.data!.docs[index]['tagName']);} );

                                    }
                                  }),
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
      ),
    );
  }
}
