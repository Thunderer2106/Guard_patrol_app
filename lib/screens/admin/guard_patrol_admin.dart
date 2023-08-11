import 'package:guard_app/screens/admin/guard_patrol/patrol_list.dart';
import 'package:guard_app/screens/loading/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'guard_patrol/edit_nfc.dart';


class GuardPatrolAdmin extends StatefulWidget {
  const GuardPatrolAdmin({Key? key}) : super(key: key);




  @override
  State<GuardPatrolAdmin> createState() => _GuardPatrolAdminState();
}
class _GuardPatrolAdminState extends State<GuardPatrolAdmin> {
  final CollectionReference _getPatrol=FirebaseFirestore.instance.collection('guardpatrol');
  late Stream<QuerySnapshot>_streamGetPatrol;

  @override
  void initState() {
    _streamGetPatrol=_getPatrol.snapshots();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal[300],
          elevation: 4,
          title: const Text("Guard patrol"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
        ),
      backgroundColor: const Color(0xFFB1DCDA),
      body:const PatrolList(),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: (){
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context)=>const EditNfc()));
          },
          backgroundColor: Colors.teal[300],
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit)
        ),

      ),
    );
  }
}

