import 'package:guard_app/screens/main/auth.dart';
import 'package:guard_app/screens/admin/change_admin_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdminHome extends StatefulWidget {
  const AdminHome(
      {required this.admin,
      required this.pass,
      required this.changePass,
      Key? key})
      : super(key: key);
  final void Function(String s) admin;
  final String pass;
  final void Function(String s) changePass;

  @override
  State<AdminHome> createState() => _AdminHomeState();

}



class _AdminHomeState extends State<AdminHome> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2DEDB),

      appBar: AppBar(
        backgroundColor:Colors.teal ,
        automaticallyImplyLeading: false,
        title: const Text(
          'Admin Home',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to log out?"),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Logout"),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AuthScreen(
                                      admin: widget.admin,
                                      pass: widget.pass,
                                      changePass: widget.changePass,
                                    )),
                          );
                          // Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.teal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: const BoxDecoration(
                  color: Colors.white70,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(400))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 50,
                    children: [
                      GestureDetector(
                        child: itemDashboard('Password',
                            CupertinoIcons.lock_fill, Colors.deepOrange),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeAdminPass(
                                    widget.changePass, widget.pass)),
                          );
                        },
                      ),
                      GestureDetector(
                        child: itemDashboard('Users',
                            CupertinoIcons.person_2_alt, Colors.green),
                        onTap: () {
                          Navigator.pushNamed(context, '/users');
                        },
                      ),
                      GestureDetector(
                        child: itemDashboard('Incidents',
                            CupertinoIcons.envelope_fill, Colors.purple),
                        onTap: () {
                          Navigator.pushNamed(context, '/viewIncidents');
                        },
                      ),
                      GestureDetector(
                        child: itemDashboard('Guard Tour', CupertinoIcons.search_circle,
                            Colors.brown),
                        onTap: (){
                          Navigator.pushNamed(context, '/guardPatrol');
                        },
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  itemDashboard(String title, IconData iconData, Color background) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 5),
                  color: Theme.of(context).primaryColor.withOpacity(.2),
                  spreadRadius: 2,
                  blurRadius: 5)
            ]),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: Colors.white)),
            const SizedBox(height: 8),
            Text(title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium)
          ],
        ),
      );
}
