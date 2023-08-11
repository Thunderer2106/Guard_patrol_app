import 'package:guard_app/screens/admin/adminDashboard.dart';
import 'package:flutter/material.dart';

class ChangeAdminPass extends StatefulWidget {
  const ChangeAdminPass(this.changePass, this.pass, {Key? key})
      : super(key: key);
  final void Function(String s) changePass;
  final String pass;

  @override
  State<ChangeAdminPass> createState() => _ChangeAdminPassState();
}

class _ChangeAdminPassState extends State<ChangeAdminPass> {
  final _form = GlobalKey<FormState>();
  var _enteredPass = '';
  var _newPass = '';
  var _checkNew = '';
  var _isChanged = false;

  void _onSubmit() {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    if (_enteredPass != widget.pass) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Existing Password Wrong',
          ),
        ),
      );
    } else if (_newPass != _checkNew) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Both Password doesn\'t match',
          ),
        ),
      );
    } else {
      setState(() {
        _isChanged = true;
      });
      widget.changePass(_newPass);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: const Text("Change Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Enter Old Password'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == '') {
                                return 'Invalid';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPass = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'New Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == '') {
                                return 'Invalid ';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _newPass = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Verify New Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == '') {
                                return 'Invalid';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _checkNew = value!;
                            },
                          ),
                          if (_isChanged)
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Changed Successfully',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          if (!_isChanged)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              onPressed: _onSubmit,
                              child: const Text(
                                'Change Password',
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/admin');
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Go Back"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
