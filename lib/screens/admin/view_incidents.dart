import 'package:guard_app/screens/admin/incident_report/completed.dart';
import 'package:guard_app/screens/admin/incident_report/pending.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewIncidents extends StatefulWidget {
  const ViewIncidents({Key? key}) : super(key: key);

  @override
  State<ViewIncidents> createState() => _ViewIncidentsState();
}

class _ViewIncidentsState extends State<ViewIncidents> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[300],
        elevation: 4,
        title: const Text("Incident Reports"),
      ),
      backgroundColor: const Color(0xFFB1DCDA),
      body: const Center(
        child:  Column(
          children: [
            Expanded(
              child: PendingIncidents(),
            ),
            Expanded(child: CompletedIncidents()),
          ],
        )
      ),
    );
  }
}
