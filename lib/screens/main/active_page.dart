import 'package:guard_app/screens/admin/adminDashboard.dart';
import 'package:guard_app/screens/admin/guard_patrol_admin.dart';
import 'package:guard_app/screens/main/auth.dart';
import 'package:guard_app/screens/user/user_dashboard.dart';
import 'package:guard_app/screens/loading/splash.dart';
import 'package:guard_app/screens/admin/view_incidents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../admin/users.dart';

class ActivePage extends StatefulWidget {
  const ActivePage({Key? key}) : super(key: key);

  @override
  State<ActivePage> createState() => _ActivePageState();
}

class _ActivePageState extends State<ActivePage> {
  var adminScreen = false;
  String pass = '';

  void adminPass() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('admin').get();
    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('adminPass')
          .get();

      setState(() {
        pass = documentSnapshot.get('pass');
      });
    } else {
      setState(() {
        pass = 'admin';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    adminPass();
  }



  void _changePass(String s) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('admin').get();
    if (querySnapshot.size > 0) {

      DocumentReference documentReference=FirebaseFirestore.instance.collection('admin').doc('adminPass');
      documentReference.update({'pass':s});
      print("newpass change");
    } else {
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('admin');
      await collectionRef.doc('adminPass').set({'pass': s});
      print("newly set");
    }
setState(() {
  pass=s;
});

  }

  void adminPage(String password) {
    print("check");
    if (pass == password) {
      print("yes$adminScreen");
      setState(() {
        adminScreen = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid"),
        duration: Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/admin': (context) => AdminHome(
              admin: adminPage,
              pass: pass,
              changePass: _changePass,
            ),
        '/users': (context) => const Users(),
        '/viewIncidents': (context) => const ViewIncidents(),
        '/guardPatrol': (context) => const GuardPatrolAdmin(),
      },
      title: 'Guard patrolling App',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return const UserHome();
            }

            if (adminScreen) {
              return AdminHome(
                admin: adminPage,
                pass: pass,
                changePass: _changePass,
              );
            }
            // return const TestLo();
            // return const GuardPatrolAdmin();
            return AuthScreen(
              admin: adminPage,
              pass: pass,
              changePass: _changePass,
            );
            // return const ViewIncidents();
          }),
    );
  }
}
