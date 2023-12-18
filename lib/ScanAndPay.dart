import 'package:bankapi/Dashboard.dart';
import 'package:flutter/material.dart';
import 'Menu.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanAndPay extends StatefulWidget {
  @override
  _ScanAndPayState createState() => _ScanAndPayState();
}

class _ScanAndPayState extends State<ScanAndPay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Scan & Pay'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            },
          )),
      drawer: Menu(),
      body: Center(),
    );
  }
}
