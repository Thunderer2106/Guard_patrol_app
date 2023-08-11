import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class NFCTest extends StatefulWidget {
  const NFCTest(this.setRoom,this.value,{super.key});
  final void Function(String s) setRoom;
  final String value;

  @override
  State<NFCTest> createState() => _NFCTestState();
}

class _NFCTestState extends State<NFCTest> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  final formatter = DateFormat.yMd();
  DateTime date = DateTime.now();

  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  final CollectionReference _getNfc =
      FirebaseFirestore.instance.collection('nfcTag');
  dynamic room;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result.addListener(() {
      NfcTag a = result.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Scanning ${widget.value}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            child: FutureBuilder<bool>(
              builder: (context, ss) => Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.vertical,
                children: [
                  SingleChildScrollView(
                    child: ValueListenableBuilder<dynamic>(
                      valueListenable: result,
                      builder: (context, value, _) => Column(
                        children: [

                          Center(
                            child: Container(

                                decoration: BoxDecoration(border: Border.all()),

                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                margin: const EdgeInsets.all(10),
                                child: value != null && room!=null
                                    ? Text("Successfully scanned $room")
                                    : const Text("Scan Pending")),
                          )
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _tagRead, child: const Text('Tag Read')),
                  TextButton.icon(
                      onPressed: (){Navigator.of(context).pop(); }, icon: const Icon(Icons.arrow_back),
                      label: const Text('Go back')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tagRead() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      final ndefMessage = tag.data['ndef']['cachedMessage'];
      final record = ndefMessage['records'][0];
      final payload = record['payload'];
      final text = utf8.decode(payload);
      result.value = text.substring(3, text.length);
      await Firebase.initializeApp();
      final db = FirebaseFirestore.instance;
      room = await db
          .collection('nfcTag')
          .where('tagCode', isEqualTo: result.value)
          .get()
          .then((snapshot) {
        return snapshot.docs.first.data()['tagName'];
      });
      NfcManager.instance.stopSession();
    });
    if(room!=null)
    {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      await FirebaseFirestore.instance.collection('guardPatrol').add({
      'room' : room,
      'date': formattedDate,
      'username': userData.data()!['username'],
      'time': Timestamp.now(),
      });
      widget.setRoom(room);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('nfcTag')
          .where('tagName', isEqualTo: room)
          .get();
      if (querySnapshot.size > 0) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        FirebaseFirestore.instance.collection('nfcTag').doc(documentSnapshot.id).update({
          'status': true,
        });
      }

    }

  }






}
