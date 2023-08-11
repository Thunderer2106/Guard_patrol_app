import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';



class WriteToNfc extends StatefulWidget {
  const WriteToNfc(this.code,this.chkW,{super.key});
  final String code;
  final void chkW;

  @override
  State<StatefulWidget> createState() => WriteToNfcState();
}

class WriteToNfcState extends State<WriteToNfc> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  var done=false;

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: const Text("Writing to NFC"),
      content:FutureBuilder<bool>(
      future:NfcManager.instance.isAvailable(),
      builder:(context,ss)=>ss.data!=true?const Center(child: Text("NFC not turned on"),):
       Column(
        mainAxisSize: MainAxisSize.min,
          children: [

            Container(
                // constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(border: Border.all()),
               padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 50),
              margin: const EdgeInsets.all(4),
              child: ValueListenableBuilder<dynamic>(
                valueListenable: result,
                builder: (context, value, _) =>
                    Text('${value ?? 'Not Written'}'),


              ),
            ),
            if(!done)
            ElevatedButton(onPressed: (){_ndefWrite(widget.code);}, child:  const Text("WRITE")),
            if(done)
              const Text("Done"),
            ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: const Text("Go Back")),

          ],
      )

      ),
    );

  }


  void _ndefWrite(String code) {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText(code.toString()),
        NdefRecord.createUri(Uri.parse('https://flutter.dev')),
        NdefRecord.createMime(
            'text/plain', Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternal(
            'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success';
        setState(() {
          done=true;
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
