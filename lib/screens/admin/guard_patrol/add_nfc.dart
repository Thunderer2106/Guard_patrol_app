
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class AddNfc extends StatefulWidget {
  const AddNfc({required this.addNfc, Key? key}) : super(key: key);
  final Function(String name, String code) addNfc;

  @override
  State<AddNfc> createState() => _AddNfcState();
}

class _AddNfcState extends State<AddNfc> {
  final TextEditingController _nfcCode = TextEditingController();
  final TextEditingController _nfcName = TextEditingController();
  var _isWritten = false;
  var nfcResult = '';
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  void dispose() {
    _nfcCode.dispose();
    _nfcName.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void ndefWrite(String code) {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText(code.toString()),

      ]);

      try {
        await ndef.write(message);
        result.value = 'Success';
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
              _isWritten = true;
            }));

        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var done = _isWritten;
    return AlertDialog(
      title: const Text("Add New"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nfcName,
            decoration: const InputDecoration(labelText: 'NFC Name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter Something';
              }
            },
          ),
          TextFormField(
            controller: _nfcCode,
            decoration: const InputDecoration(labelText: 'NFC Code'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter Something';
              }
            },
          ),
        ],
      ),
      actions: [
        if (!_isWritten)
          ElevatedButton(
              onPressed: () {
                String code = _nfcCode.text;
                String name = _nfcName.text;
                if (name.isEmpty || code.isEmpty) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Should not be Empty!")));
                } else {
                  setState(() {
                    _isWritten = false;
                  });
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Writing to NFC"),
                          content: FutureBuilder<bool>(
                              future: NfcManager.instance.isAvailable(),
                              builder: (context, ss) => ss.data != true
                                  ? const Center(
                                      child: Text("NFC not turned on"),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          // constraints: const BoxConstraints.expand(),
                                          decoration: BoxDecoration(
                                              border: Border.all()),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 50),
                                          margin: const EdgeInsets.all(4),
                                          child:
                                              ValueListenableBuilder<dynamic>(
                                            valueListenable: result,
                                            builder: (context, value, _) => Text(
                                                '${value ?? 'Not Written'}'),
                                          ),
                                        ),
                                        ValueListenableBuilder<dynamic>(
                                          valueListenable: result,
                                          builder: (context, value, _) =>
                                              value == 'Success'
                                                  ? Container(
                                                margin: const EdgeInsets.all(4),
                                                child: const Text("Done!",
                                                        style: TextStyle(
                                                            color: Colors.grey)),
                                                  )
                                                  : ElevatedButton(
                                                      onPressed: () {
                                                        ndefWrite(code);
                                                      },
                                                      child:
                                                          const Text("WRITE"),
                                                    ),
                                        ),
                                        TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },

                                            label: const Text("Go Back"), icon: const Icon(Icons.arrow_back),),


                                      ],
                                    )),
                        );
                      });
                }
              },
              child: const Text("OK")),
        if (_isWritten || done)
          Container(
            margin: const EdgeInsets.all(4),

            child: const Text(
              "Done!",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ElevatedButton(
            onPressed: () {
              if (_isWritten) {
                String code = _nfcCode.text;
                String name = _nfcName.text;
                widget.addNfc(name, code);
              }
              Navigator.of(context).pop();
            },
            child: const Text("Go Back"))
      ],
    );
  }
}
