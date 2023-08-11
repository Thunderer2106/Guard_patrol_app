import 'dart:io';
import 'package:guard_app/screens/admin/adminDashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen(
      {super.key,
      required this.admin,
      required this.pass,
      required this.changePass});

  final void Function(String s) admin;
  final String pass;
  final void Function(String s) changePass;

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {

  final _form = GlobalKey<FormState>();

  var _isAdmin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  void _userSubmit() async {
    final isValid = _form.currentState!.validate();
    print("submitted");

    if (!isValid) {
      // show error message ...
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (!_isAdmin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isAuthenticating = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Credentials'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),

          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 2,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 36.0, horizontal: 24.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Guard Patrolling App",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 35.0,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          Text(
                            "Login to Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300),
                          )
                        ]),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB1DCDA),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!_isAdmin)
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFe7edeb),
                              hintText: "E-mail",
                              prefixIcon: Icon(
                                Icons.mail,
                                color: Colors.grey[600],
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          const SizedBox(height: 10,),
                          TextFormField(
                            obscureText: true,
                            validator: (value) {
                              if (value == null) {
                                return 'Invalid Password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:const  Color(0xFFe7edeb),
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.key,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        const SizedBox(height: 20.0),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating && _isAdmin)
                          ElevatedButton(
                            onPressed: () {
                              print("hello");
                              final isValid = _form.currentState!.validate();

                              if (!isValid ||
                                  !_isAdmin && _selectedImage == null) {
                                // show error message ...
                                return;
                              }
                              _form.currentState!.save();
                              if (_enteredPassword == widget.pass) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminHome(
                                            admin: widget.admin,
                                            pass: widget.pass,
                                            changePass: widget.changePass,
                                          )),
                                );
                                widget.admin(_enteredPassword);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Wrong Password"),
                                  duration: Duration(seconds: 3),
                                ));
                              }

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: const Text(
                              'Login as Admin',
                            ),
                          ),
                        if (!_isAdmin&&!_isAuthenticating)
                          ElevatedButton(onPressed: _userSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: const Text("Login as User")),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _form.currentState?.reset();
                                _isAdmin = !_isAdmin;
                              });
                            },
                            child:
                                Text(_isAdmin ? 'User Login' : 'Admin Login'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   backgroundColor: Theme.of(context).colorScheme.primary,
    //   body: SingleChildScrollView(
    //     child: Container(
    //         constraints: BoxConstraints(
    //           maxHeight: MediaQuery.of(context).size.height,
    //           maxWidth: MediaQuery.of(context).size.width,
    //         ),
    //         decoration: BoxDecoration(
    //           gradient: LinearGradient(
    //             colors: [
    //               Colors.blue[800]!,
    //               Colors.blue[600]!,
    //             ],
    //             begin: Alignment.topLeft,
    //             end: Alignment.centerRight,
    //           ),
    //         ),
    //         child: Form(
    //           key: _form,
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               const Expanded(
    //                 flex: 2,
    //                 child: Padding(
    //                   padding: EdgeInsets.symmetric(
    //                       vertical: 36.0, horizontal: 24.0),
    //                   child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.end,
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Text(
    //                           "Guard Patrolling App",
    //                           style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: 46.0,
    //                               fontWeight: FontWeight.w500),
    //                         ),
    //                         Padding(padding: EdgeInsets.only(top: 20.0)),
    //                         Text(
    //                           "Ready to Patrol?",
    //                           style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: 40.0,
    //                               fontWeight: FontWeight.w300),
    //                         )
    //                       ]),
    //                 ),
    //               ),
    //               Expanded(
    //                 flex: 5,
    //                 child: Container(
    //                   width: double.infinity,
    //                   decoration: const BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.only(
    //                         topLeft: Radius.circular(40),
    //                         topRight: Radius.circular(40)),
    //                   ),
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     crossAxisAlignment: CrossAxisAlignment.center,
    //                     children: [
    //                       if (!_isAdmin)
    //                         TextFormField(
    //                           keyboardType: TextInputType.emailAddress,
    //                           decoration: InputDecoration(
    //                             border: OutlineInputBorder(
    //                               borderRadius: BorderRadius.circular(8.0),
    //                               borderSide: BorderSide.none,
    //                             ),
    //                             filled: true,
    //                             fillColor: const Color(0xFFe7edeb),
    //                             hintText: "E-mail",
    //                             prefixIcon: Icon(
    //                               Icons.mail,
    //                               color: Colors.grey[600],
    //                             ),
    //                           ),
    //                           autocorrect: false,
    //                           validator: (value) {
    //                             if (value == null ||
    //                                 value.trim().isEmpty ||
    //                                 !value.contains('@')) {
    //                               return 'Please enter a valid email address.';
    //                             }
    //
    //                             return null;
    //                           },
    //                           onSaved: (value) {
    //                             _enteredEmail = value!;
    //                           },
    //                         ),
    //                       if (!_isAdmin)
    //                         TextFormField(
    //                           decoration: const InputDecoration(
    //                               labelText: 'Email Address'),
    //                           autocorrect: false,
    //                           textCapitalization: TextCapitalization.none,
    //                           validator: (value) {
    //                             if (value == null ||
    //                                 value.trim().isEmpty ||
    //                                 !value.contains('@')) {
    //                               return 'Please enter a valid email address.';
    //                             }
    //
    //                             return null;
    //                           },
    //                           onSaved: (value) {
    //                             _enteredEmail = value!;
    //                           },
    //                         ),
    //                       TextFormField(
    //                         decoration:
    //                         const InputDecoration(labelText: 'Password'),
    //                         obscureText: true,
    //                         validator: (value) {
    //                           if (value == null) {
    //                             return 'Invalid Password ';
    //                           }
    //                           return null;
    //                         },
    //                         onSaved: (value) {
    //                           _enteredPassword = value!;
    //                         },
    //                       ),
    //                       const SizedBox(height: 12),

    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         )),
    //   ),
    // );
  }
}
