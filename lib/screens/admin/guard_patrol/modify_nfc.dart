import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ModifyNfc extends StatefulWidget {
  final String name;
  final String index;
  final String code;
  final Function(String name, String code, String index) changeNfc;
  final bool isWritten;
  const ModifyNfc(
      {required this.isWritten,
      required this.index,
      required this.name,
      required this.code,
      required this.changeNfc,
      Key? key})
      : super(key: key);

  @override
  State<ModifyNfc> createState() => _ModifyNfcState();
}

class _ModifyNfcState extends State<ModifyNfc> {
  late TextEditingController _nfcCode;
  late TextEditingController _nfcName;
  ValueNotifier<dynamic> result = ValueNotifier(null);
  var _isWritten = false;
  String valueInText = "WRITE";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit ${(widget.name)}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nfcName,
            decoration: const InputDecoration(labelText: 'NFC Name'),
          ),
          TextFormField(
            controller: _nfcCode,
            decoration: const InputDecoration(labelText: 'NFC Code'),
          ),
        ],
      ),
      actions: [
        if (!_isWritten)
          ElevatedButton(
              onPressed: () {
                String code = _nfcCode.text;
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      var isDone = false;
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
                                        decoration:
                                            BoxDecoration(border: Border.all()),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 50),
                                        margin: const EdgeInsets.all(4),
                                        child: ValueListenableBuilder<dynamic>(
                                          valueListenable: result,
                                          builder: (context, value, _) =>
                                              Text('${value ?? 'Not Written'}'),
                                        ),
                                      ),
                                      ValueListenableBuilder<dynamic>(
                                        valueListenable: result,
                                        builder: (context, value, _) =>
                                            value == 'Success'
                                                ? const Text("Done!",
                                                    style: TextStyle(
                                                        color: Colors.grey))
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      ndefWrite(code);
                                                    },
                                                    child: const Text("WRITE"),
                                                  ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Go Back")),
                                    ],
                                  )),
                      );
                    });
              },
              child: const Text("Ok")),
        if (_isWritten)
          const Text("Done!", style: TextStyle(color: Colors.grey)),
        ElevatedButton(
            onPressed: () {
              if (_isWritten) {
                String code = _nfcCode.text;
                String name = _nfcName.text;
                widget.changeNfc(name, code, widget.index);
              }
              Navigator.pop(context);
            },
            child: const Text("Go back"))
      ],
    );
  }

  @override
  void dispose() {
    _nfcCode.dispose();
    _nfcName.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    _nfcCode = TextEditingController(text: widget.code ?? '');
    _nfcName = TextEditingController(text: widget.name ?? '');
    _isWritten = widget.isWritten;

    // TODO: implement initState
    super.initState();
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
        setState(() {
          valueInText = "DONE!";
        });

        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}
